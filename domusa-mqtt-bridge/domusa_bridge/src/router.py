
import asyncio
import json
import math


class Router:

    CONFIG_PARAMETERS = {
        "hyst_c_f_p06",
        "hyst_acs_p07",
        "hyst_buffer_p122",
        "m_c1_p20",
    }

    ESTADO_PARAMETERS = {
        "st_acs_p04",
        "st_buffer_c_p123",
        "st_sg2_c_p202",
        "st_sgon_c_p203",
        "st_sg2_acs_p206",
        "st_sgon_acs_p207",
    }

    def __init__(
        self,
        api,
        mqtt,
        devices,
        refresh_callbacks=None
    ):
        self.api = api
        self.mqtt = mqtt

        self.devices = {
            str(device["id"]): device
            for device in devices
            if isinstance(device, dict) and device.get("id") is not None
        }

        self.refresh_callbacks = refresh_callbacks or {}

        self.command_topics = {
            cid: f"domusa/{cid}/set"
            for cid in self.devices
        }

        self.result_topics = {
            cid: f"domusa/{cid}/set/result"
            for cid in self.devices
        }

    def validate(self, parameter, value):

        if parameter not in self.CONFIG_PARAMETERS | self.ESTADO_PARAMETERS:
            return False, "Parameter is not allowed"

        if isinstance(value, bool) or not isinstance(value, (int, float)):
            return False, "Value must be a number"

        if not math.isfinite(value):
            return False, "Value must be finite"

        # DHW target temperature: integer from 40 to 65.
        if parameter == "st_acs_p04":
            if not isinstance(value, int) or not 40 <= value <= 65:
                return False, "st_acs_p04 must be an integer from 40 to 65"

        # Buffer target temperature: integer from 25 to 50.
        elif parameter == "st_buffer_c_p123":
            if not isinstance(value, int) or not 25 <= value <= 50:
                return False, "st_buffer_c_p123 must be an integer from 25 to 50"

        # Heating and buffer hysteresis: integer from 5 to 11.
        elif parameter in ("hyst_c_f_p06", "hyst_buffer_p122"):
            if not isinstance(value, int) or not 5 <= value <= 11:
                return False, f"{parameter} must be an integer from 5 to 11"

        # DHW hysteresis: integer from 5 to 10.
        elif parameter == "hyst_acs_p07":
            if not isinstance(value, int) or not 5 <= value <= 10:
                return False, "hyst_acs_p07 must be an integer from 5 to 10"

        # Operating mode: 0, 1 or 2.
        elif parameter == "m_c1_p20":
            if not isinstance(value, int) or value not in (0, 1, 2):
                return False, "m_c1_p20 must be 0, 1 or 2"

        # Heating SG-Ready setpoints.
        elif parameter in ("st_sg2_c_p202", "st_sgon_c_p203"):
            if value != 0 and not 40 <= value <= 65:
                return False, "Heating SG-Ready setpoint must be 0 or 40 to 65"

        # DHW SG-Ready setpoints.
        elif parameter in ("st_sg2_acs_p206", "st_sgon_acs_p207"):
            if value != 0 and not 40 <= value <= 65:
                return False, "DHW SG-Ready setpoint must be 0 or 40 to 65"

        return True, None

    async def publish_result(self, cid, result):
        topic = self.result_topics[cid]

        await self.mqtt.publish(
            topic,
            json.dumps(result, ensure_ascii=False)
        )

    async def handle_command(self, cid, payload):

        # Decode and parse the MQTT payload.
        try:
            command = json.loads(payload.decode("utf-8"))

        except (UnicodeDecodeError, json.JSONDecodeError, AttributeError):
            await self.publish_result(cid, {
                "success": False,
                "error": "Invalid JSON payload"
            })
            return

        # Ensure the payload is a JSON object.
        if not isinstance(command, dict):
            await self.publish_result(cid, {
                "success": False,
                "error": "Payload must be a JSON object"
            })
            return

        parameter = command.get("parameter")
        value = command.get("value")

        if not isinstance(parameter, str):
            await self.publish_result(cid, {
                "success": False,
                "error": "Missing or invalid parameter"
            })
            return

        # Validate the requested parameter and value.
        valid, error = self.validate(parameter, value)

        if not valid:
            await self.publish_result(cid, {
                "success": False,
                "parameter": parameter,
                "error": error
            })
            return

        request_data = {parameter: value}

        # Select the correct DOMUSA API endpoint.
        if parameter in self.CONFIG_PARAMETERS:
            success = await self.api.put_config(cid, request_data)
            read_method = self.api.get_config

        else:
            success = await self.api.put_estado(cid, request_data)
            read_method = self.api.get_estado

        # Stop if the PUT request failed.
        if not success:
            await self.publish_result(cid, {
                "success": False,
                "parameter": parameter,
                "value": value,
                "error": "DOMUSA API rejected the write request"
            })
            return

        # Allow the controller time to apply the new value.
        await asyncio.sleep(1)

        # Read back the parameter to verify the resulting device value.
        current_data = await read_method(cid)

        if not isinstance(current_data, dict) or parameter not in current_data:
            await self.publish_result(cid, {
                "success": False,
                "parameter": parameter,
                "value": value,
                "error": "Write accepted, but read-back verification failed"
            })
            return

        actual_value = current_data[parameter]

        # Compare the requested value with the actual device value.
        if actual_value != value:
            await self.publish_result(cid, {
                "success": False,
                "parameter": parameter,
                "requested_value": value,
                "actual_value": actual_value,
                "error": "Read-back value does not match requested value"
            })
            return

        # Refresh the complete Home Assistant status immediately.
        status_updated = False
        status_error = None

        refresh_status = self.refresh_callbacks.get(cid)

        if refresh_status is not None:
            try:
                status_updated = await refresh_status()

                if not status_updated:
                    status_error = "No status data received during refresh"

            except Exception as ex:
                status_error = str(ex)
                print(
                    f"ERROR: Immediate status refresh failed "
                    f"for {cid}: {ex}"
                )

        # Publish successful write confirmation.
        result = {
            "success": True,
            "parameter": parameter,
            "value": actual_value,
            "status_updated": status_updated
        }

        if status_error:
            result["status_error"] = status_error

        await self.publish_result(cid, result)

        print(
            f"DEBUG: DOMUSA {cid}: "
            f"Parameter {parameter} updated to {actual_value}"
        )

    async def listen(self):

        # Subscribe to the exact command topic of every installation.
        for cid, topic in self.command_topics.items():
            await self.mqtt.subscribe(topic)

            print(
                f"DEBUG: Listening for DOMUSA commands "
                f"for {cid} on {topic}"
            )

        # Process commands from all installations.
        async for message in self.mqtt.messages:
            topic = str(message.topic)

            cid = None

            for device_id, command_topic in self.command_topics.items():
                if topic == command_topic:
                    cid = device_id
                    break

            if cid is None:
                continue

            try:
                await self.handle_command(cid, message.payload)

            except Exception as ex:
                print(
                    f"ERROR: Command processing failed "
                    f"for {cid}: {ex}"
                )

                try:
                    await self.publish_result(cid, {
                        "success": False,
                        "error": "Internal command processing error"
                    })

                except Exception as publish_error:
                    print(
                        "ERROR: Unable to publish command result: "
                        f"{publish_error}"
                    )
