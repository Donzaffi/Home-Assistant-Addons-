import json


class StateManager:

    def __init__(self, mqtt, device):
        self.mqtt = mqtt
        self.device = device

        # Letzten veröffentlichten Zustand merken
        self._last_payload = None

    async def publish(self, data):
        """
        Veröffentlicht den aktuellen Status der Wärmepumpe.

        Es werden nur Änderungen veröffentlicht, um MQTT
        und Home Assistant unnötig zu entlasten.
        """

        if not isinstance(data, dict):
            return

        topic = f"domusa/{self.device['id']}/status"

        payload = json.dumps(
            data,
            ensure_ascii=False,
            separators=(",", ":")
        )

        # Nur senden wenn sich wirklich etwas geändert hat
        if payload == self._last_payload:
            return

        await self.mqtt.client.publish(
            topic,
            payload,
            retain=True
        )

        self._last_payload = payload

        print(
            f"State: {len(data)} Werte auf {topic} veröffentlicht."
        )
