class Router:
    """
    Read-only Addon.

    Router bleibt nur als Platzhalter bestehen,
    damit die übrige Struktur unverändert bleibt.
    """

    def __init__(self, api, mqtt, device):
        self.api = api
        self.mqtt = mqtt
        self.device = device

    async def listen(self):
        # Keine MQTT-Kommandos mehr verarbeiten.
        return
