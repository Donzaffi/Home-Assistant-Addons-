import asyncio
import time

import aiohttp


class Auth:
    BASE = "https://ic-api-app.azurewebsites.net/api"

    # Beobachtete Token-Laufzeit: ca. 5 Tage.
    # Vorsorgliche Erneuerung 4 Stunden vor Ablauf.
    REFRESH_AFTER = (4 * 24 * 60 * 60) + (20 * 60 * 60)

    def __init__(self, username, password):
        self.username = username
        self.password = password

        self.token = None
        self.refresh_token = None

        self.token_created_at = None
        self._lock = asyncio.Lock()

    def invalidate_token(self):
        """Access-Token verwerfen, Refresh-Token behalten."""
        self.token = None
        self.token_created_at = None

    async def get_token(self):
        async with self._lock:
            # Vorhandenen Token verwenden, solange er noch
            # innerhalb des vorsorglichen Gültigkeitszeitraums liegt.
            if self.token and self.token_created_at is not None:
                age = time.monotonic() - self.token_created_at

                if age < self.REFRESH_AFTER:
                    return self.token

            # Token fehlt oder soll vorsorglich erneuert werden.
            return await self._refresh_or_login()

    async def login(self):
        """Neuen Access- und Refresh-Token anfordern."""
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

        try:
            timeout = aiohttp.ClientTimeout(total=15)

            async with aiohttp.ClientSession(
                headers=headers,
                timeout=timeout
            ) as session:

                async with session.post(url, json=payload) as response:
                    if response.status != 200:
                        print(f"Login fehlgeschlagen ({response.status})")
                        return None

                    data = await response.json()

            new_token = data.get("token")
            new_refresh_token = data.get("refreshToken")

            if not new_token:
                print("Login fehlgeschlagen: Kein Access-Token erhalten")
                return None

            self.token = new_token

            if new_refresh_token:
                self.refresh_token = new_refresh_token

            self.token_created_at = time.monotonic()

            print("DEBUG: Login erfolgreich")
            return self.token

        except (aiohttp.ClientError, asyncio.TimeoutError) as ex:
            print(f"Login Netzwerkfehler: {ex}")
            return None

        except Exception as ex:
            print(f"Login Fehler: {ex}")
            return None

    async def _perform_refresh(self):
        """Refresh ausführen. Wird nur innerhalb des Locks aufgerufen."""
        if not self.refresh_token:
            return None

        headers = {
            "Authorization": f"Bearer {self.refresh_token}",
            "Content-Type": "application/json"
        }

        url = f"{self.BASE}/v1/auth/refresh"

        print("DEBUG: Refresh Token")

        try:
            timeout = aiohttp.ClientTimeout(total=15)

            async with aiohttp.ClientSession(
                headers=headers,
                timeout=timeout
            ) as session:

                async with session.get(url) as response:
                    if response.status != 200:
                        print(f"Refresh fehlgeschlagen ({response.status})")

                        # Bei einer Ablehnung des Refresh-Tokens
                        # versuchen wir einen neuen Login.
                        if 400 <= response.status < 500:
                            self.refresh_token = None
                            return await self.login()

                        # Bei Server- oder Netzwerkproblemen
                        # Refresh-Token nicht verwerfen.
                        return None

                    data = await response.json()

            new_token = data.get("token")

            if not new_token:
                print("Refresh fehlgeschlagen: Kein Access-Token erhalten")
                return None

            self.token = new_token

            # Manche APIs rotieren den Refresh-Token.
            # Nur überschreiben, wenn tatsächlich einer geliefert wird.
            new_refresh_token = data.get("refreshToken")
            if new_refresh_token:
                self.refresh_token = new_refresh_token

            self.token_created_at = time.monotonic()

            print("DEBUG: Refresh erfolgreich")
            return self.token

        except (aiohttp.ClientError, asyncio.TimeoutError) as ex:
            print(f"Refresh Netzwerkfehler: {ex}")
            return None

        except Exception as ex:
            print(f"Refresh Fehler: {ex}")
            return None

    async def _refresh_or_login(self):
        """Refresh versuchen, andernfalls neu einloggen."""
        if self.refresh_token:
            token = await self._perform_refresh()

            if token:
                return token

            # Bei einem vorübergehenden Fehler bleibt der
            # Refresh-Token erhalten. Nicht sofort neu einloggen.
            return None

        return await self.login()

    async def refresh_after_unauthorized(self, failed_token):
        """
        Nach HTTP 401/440 erneuern.

        Wenn ein anderer paralleler Aufruf den Token bereits
        erneuert hat, wird dessen neuer Token wiederverwendet.
        """
        async with self._lock:
            if self.token and self.token != failed_token:
                return self.token

            self.invalidate_token()
            return await self._refresh_or_login()

    async def perform_refresh(self):
        """Kompatible öffentliche Refresh-Methode."""
        async with self._lock:
            self.invalidate_token()
            return await self._refresh_or_login()
