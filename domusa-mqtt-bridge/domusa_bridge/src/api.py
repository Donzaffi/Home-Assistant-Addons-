import aiohttp


class DomusaAPI:

    def __init__(self, auth):
        self.base = "https://ic-api-app.azurewebsites.net/api"
        self.auth = auth

    async def _request(self, method, url):
        # Token für den ersten API-Aufruf holen.
        token = await self.auth.get_token()

        if not token:
            print("API-Aufruf abgebrochen: Kein gültiger Token verfügbar")
            return {}

        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        }

        timeout = aiohttp.ClientTimeout(total=10)

        try:
            async with aiohttp.ClientSession(timeout=timeout) as session:

                async with session.request(
                    method,
                    url,
                    headers=headers
                ) as response:

                    if response.status == 200:
                        return await response.json()

                    if response.status not in (401, 440):
                        print(f"HTTP {response.status}")
                        return {}

                    print("Token abgelaufen oder ungültig -> Refresh")

                # Refresh außerhalb des ersten Response-Kontexts.
                new_token = await self.auth.refresh_after_unauthorized(token)

                if not new_token:
                    print("API-Aufruf fehlgeschlagen: Token-Erneuerung nicht möglich")
                    return {}

                retry_headers = {
                    "Authorization": f"Bearer {new_token}",
                    "Content-Type": "application/json"
                }

                # API-Aufruf genau einmal wiederholen.
                async with session.request(
                    method,
                    url,
                    headers=retry_headers
                ) as retry_response:

                    if retry_response.status == 200:
                        return await retry_response.json()

                    print(
                        f"Retry fehlgeschlagen ({retry_response.status})"
                    )
                    return {}

        except (aiohttp.ClientError, TimeoutError) as ex:
            print(f"API Netzwerkfehler: {ex}")
            return {}

        except Exception as ex:
            print(f"API Fehler: {ex}")
            return {}

    async def _get(self, url):
        return await self._request("GET", url)

    async def get_caldera(self):
        url = f"{self.base}/v1/usuario/calderas/aliases"

        data = await self._get(url)

        if not isinstance(data, dict) or not data:
            return None

        first_key = next(iter(data))

        return {
            "id": data[first_key].get(
                "idcaldera",
                first_key
            )
        }

    async def get_estado(self, cid):
        return await self._get(
            f"{self.base}/v2/calderas/{cid}/estado"
        )

    async def get_config(self, cid):
        return await self._get(
            f"{self.base}/v2/calderas/{cid}/configuracion"
        )
