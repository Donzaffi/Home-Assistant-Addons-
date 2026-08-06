import aiohttp
import time

class Auth:
    BASE = "https://ic-api-app.azurewebsites.net/api"

    def __init__(self, username, password):
        self.username = username
        self.password = password
        self.token = None
        self.refresh_token = None
        self.expires_at = 0

    def invalidate_token(self):
        self.token = None
        self.expires_at = 0

    async def get_token(self):
        # Wenn ein Token existiert und noch min. 5 Minuten gültig ist
        if self.token and time.time() < (self.expires_at - 300):
            return self.token
        
        # Wenn wir einen Refresh-Token haben, versuche das Refresh
        if self.refresh_token:
            return await self.perform_refresh()
        
        # Ansonsten kompletter Login
        return await self.login()

    async def login(self):
        headers = {"Content-Type": "application/json"}
        url = f"{self.BASE}/v1/auth/login" 
        payload = {
            "username": self.username,
            "password": self.password,
            "langDevice": "de"
        }

        print(f"DEBUG: Versuche Login an {url}")
        
        async with aiohttp.ClientSession(headers=headers) as s:
            async with s.post(url, json=payload) as r:
                data = await r.json()
                
                if r.status == 200:
                    self.token = data.get("token")
                    self.refresh_token = data.get("refreshToken")
                    self.expires_at = time.time() + 3600 # 1 Stunde Gültigkeit
                    return self.token
                
                print(f"Fehler: Login schlug mit Status {r.status} fehl")
                return None

async def perform_refresh(self):
    headers = {
        "Authorization": f"Bearer {self.refresh_token}",
        "Content-Type": "application/json"
    }

    url = f"{self.BASE}/v1/auth/refresh"

    print("DEBUG: Refresh Access Token")

    async with aiohttp.ClientSession(headers=headers) as session:
        async with session.get(url) as r:

            if r.status == 200:
                data = await r.json()

                self.token = data.get("token")
                self.refresh_token = data.get(
                    "refreshToken",
                    self.refresh_token
                )

                return self.token

            print(f"Refresh fehlgeschlagen ({r.status})")

            self.refresh_token = None
            self.token = None

            return await self.login()
