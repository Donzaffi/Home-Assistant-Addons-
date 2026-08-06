import aiohttp


class Auth:
    BASE = "https://ic-api-app.azurewebsites.net/api"

    def __init__(self, username, password):
        self.username = username
        self.password = password

        self.token = None
        self.refresh_token = None

    def invalidate_token(self):
        self.token = None

    async def get_token(self):
        # Vorhandenen Token verwenden
        if self.token:
            return self.token

        # Falls kein Access-Token vorhanden ist,
        # zuerst Refresh versuchen
        if self.refresh_token:
            token = await self.perform_refresh()
            if token:
                return token

        # Ansonsten neu einloggen
        return await self.login()

    async def login(self):
        headers = {
            "Content-Type": "application/json"
        }

        url = f"{self.BASE}/v1/auth/login"

        payload = {
            "username": self.username,
            "password": self.password,
            "langDevice": "de"
        }

        print(f"DEBUG: Login {url}")

        async with aiohttp.ClientSession(headers=headers) as session:
            async with session.post(url, json=payload) as response:

                if response.status != 200:
                    print(f"Login fehlgeschlagen ({response.status})")
                    return None

                data = await response.json()

                self.token = data.get("token")
                self.refresh_token = data.get("refreshToken")

                return self.token

    async def perform_refresh(self):
        headers = {
            "Authorization": f"Bearer {self.refresh_token}",
            "Content-Type": "application/json"
        }

        url = f"{self.BASE}/v1/auth/refresh"

        print("DEBUG: Refresh Token")

        async with aiohttp.ClientSession(headers=headers) as session:
            async with session.get(url) as response:

                if response.status == 200:
                    data = await response.json()

                    self.token = data.get("token")

                    if data.get("refreshToken"):
                        self.refresh_token = data.get("refreshToken")

                    return self.token

                print(f"Refresh fehlgeschlagen ({response.status})")

                self.token = None
                self.refresh_token = None

                return await self.login()
