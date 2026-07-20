import asyncio

class CommandListener:
    def __init__(self, api, mqtt, device):
        self.api = api
        self.mqtt = mqtt
        self.device = device

    async def start(self):
        device_id = self.device["id"]

        async with self.mqtt.client.filtered_messages(f"domusa/{device_id}/set/#") as messages:
            await self.mqtt.client.subscribe(f"domusa/{device_id}/set/#")

            async for msg in messages:
                key = msg.topic.value.split("/")[-1]
                value = msg.payload.decode()
                
                print(f"Befehl erhalten: {key} mit Wert {value}. Steuerung aktuell deaktiviert.")
                
                # Control Heatpump. Read Only in the moment
                # await self.api.set_value(device_id, key, value)
