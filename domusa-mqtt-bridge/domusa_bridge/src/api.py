import aiohttp


class DomusaAPI:

    def __init__(self, auth):
        self.base = "https://ic-api-app.azurewebsites.net/api"
        self.auth = auth

    async def _get_headers(self):
        token = await self.auth.get_token()

        return {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        }

    async def _request(self, method, url):
        headers = await self._get_headers()

        async with aiohttp.ClientSession(headers=headers) as session:

            async with session.request(method, url, timeout=10) as response:

                if response.status == 200:
                    return await response.json()

                if response.status in (401, 440):

                    print("Token abgelaufen -> Refresh")

                    self.auth.invalidate_token()

                    await self.auth.perform_refresh()

                    headers = await self._get_headers()

                    async with aiohttp.ClientSession(headers=headers) as retry:

                        async with retry.request(method, url, timeout=10) as retry_response:

                            if retry_response.status == 200:
                                return await retry_response.json()

                            print(
                                f"Retry fehlgeschlagen ({retry_response.status})"
                            )

                            return {}

                print(f"HTTP {response.status}")

                return {}

    async def _get(self, url):
        return await self._request("GET", url)

    async def get_caldera(self):
        url = f"{self.base}/v1/usuario/calderas/aliases"

        data = await self._get(url)

        if not isinstance(data, dict):
            return None

        if not data:
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
