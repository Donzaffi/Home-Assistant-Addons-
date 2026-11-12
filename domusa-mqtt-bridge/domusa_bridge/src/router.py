
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

    def __init__(self, api, mqtt, device):
        self.api = api
        self.mqtt = mqtt
        self.device = device

        cid = device["id"]
        self.command_topic = f"domusa/{cid}/set"
        self.result_topic = f"domusa/{cid}/set/result"

    def validate(self, parameter, value):

        if parameter not in self.CONFIG_PARAMETERS | self.ESTADO_PARAMETERS:
            return False, "Parameter is not allowed"

        if isinstance(value, bool) or not isinstance(value, (int, float)):
            return False, "Value must be a number"

        if not math.isfinite(value):
            return False, "Value must be finite"

        # Heating and buffer hysteresis: integer from 5 to 11.
        if parameter in ("hyst_c_f_p06", "hyst_buffer_p122"):
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

    async def publish_result(self, result):
        await self.mqtt.publish(
            self.result_topic,
            json.dumps(result, ensure_ascii=False)
        )

    async def handle_command(self, payload):

        # Decode and parse the MQTT payload.
        try:
            command = json.loads(payload.decode("utf-8"))

        except (UnicodeDecodeError, json.JSONDecodeError):
            await self.publish_result({
                "success": False,
                "error": "Invalid JSON payload"
            })
            return

        # Ensure the payload is a JSON object.
        if not isinstance(command, dict):
            await self.publish_result({
                "success": False,
                "error": "Payload must be a JSON object"
            })
            return

        parameter = command.get("parameter")
        value = command.get("value")

        if not isinstance(parameter, str):
            await self.publish_result({
                "success": False,
                "error": "Missing or invalid parameter"
            })
            return

        # Validate the requested parameter and value.
        valid, error = self.validate(parameter, value)

        if not valid:
            await self.publish_result({
                "success": False,
                "parameter": parameter,
                "error": error
            })
            return

        cid = self.device["id"]
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
            await self.publish_result({
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
            await self.publish_result({
                "success": False,
                "parameter": parameter,
                "value": value,
                "error": "Write accepted, but read-back verification failed"
            })
            return

        actual_value = current_data[parameter]

        # Compare the requested value with the actual device value.
        if actual_value != value:
            await self.publish_result({
                "success": False,
                "parameter": parameter,
                "requested_value": value,
                "actual_value": actual_value,
                "error": "Read-back value does not match requested value"
            })
            return

        # Publish successful write confirmation.
        await self.publish_result({
            "success": True,
            "parameter": parameter,
            "value": actual_value
        })

        print(f"DEBUG: Parameter {parameter} updated to {actual_value}")

    async def listen(self):
        await self.mqtt.subscribe(self.command_topic)

        print(
            f"DEBUG: Listening for DOMUSA commands on "
            f"{self.command_topic}"
        )

        async for message in self.mqtt.messages:
            topic = str(message.topic)

            if topic != self.command_topic:
                continue

            try:
                await self.handle_command(message.payload)

            except Exception as ex:
                print(f"ERROR: Command processing failed: {ex}")

                try:
                    await self.publish_result({
                        "success": False,
                        "error": "Internal command processing error"
                    })

                except Exception as publish_error:
                    print(
                        "ERROR: Unable to publish command result: "
                        f"{publish_error}"
                    )
