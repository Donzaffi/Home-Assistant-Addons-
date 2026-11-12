
import json


class StateManager:

    def __init__(self, mqtt, device):
        self.mqtt = mqtt
        self.device = device

        # Store the last published state
        self._last_payload = None

    async def publish(self, data):
        """
        Publish the current heat pump status.

        Only changed payloads are published to reduce
        unnecessary MQTT traffic and Home Assistant updates.
        """

        if not isinstance(data, dict):
            return

        status_topic = f"domusa/{self.device['id']}/status"
        availability_topic = f"domusa/{self.device['id']}/availability"

        payload = json.dumps(
            data,
            ensure_ascii=False,
            separators=(",", ":")
        )

        # Always report the device as online
        await self.mqtt.client.publish(
            availability_topic,
            "online",
            retain=True
        )

        # Publish only if the payload has changed
        if payload == self._last_payload:
            return

        await self.mqtt.client.publish(
            status_topic,
            payload,
            retain=True
        )

        self._last_payload = payload

        print(
            f"State: Published {len(data)} top-level fields to {status_topic}."
        )
