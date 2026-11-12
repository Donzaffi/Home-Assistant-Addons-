import aiomqtt


class MQTT:
    def __init__(self, host, port, user, password):
        self.host = host
        self.port = port
        self.user = user
        self.password = password
        self.client = None

    async def connect(self):
        print(f"DEBUG: Connecting to MQTT {self.host} as user {self.user}...")

        self.client = aiomqtt.Client(
            hostname=self.host,
            port=self.port,
            username=self.user,
            password=self.password
        )

        await self.client.__aenter__()
        print("DEBUG: MQTT connection established")

    async def subscribe(self, topic):
        if self.client is None:
            raise RuntimeError("MQTT client is not connected")

        await self.client.subscribe(topic)
        print(f"DEBUG: Subscribed to {topic}")

    @property
    def messages(self):
        if self.client is None:
            raise RuntimeError("MQTT client is not connected")

        return self.client.messages
    async def publish(self, topic, payload, qos=0, retain=False):
        if self.client is None:
            raise RuntimeError("MQTT client is not connected")

        await self.client.publish(
            topic,
            payload,
            qos=qos,
            retain=retain
        )

    async def disconnect(self):
        if self.client is not None:
            await self.client.__aexit__(None, None, None)
            self.client = None
            print("DEBUG: MQTT connection closed")
