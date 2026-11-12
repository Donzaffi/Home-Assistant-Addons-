
import aiohttp


class DomusaAPI:

    def __init__(self, auth):
        self.base = "https://ic-api-app.azurewebsites.net/api"
        self.auth = auth

    async def _request(self, method, url):
        # Retrieve the token for the initial API request.
        token = await self.auth.get_token()

        if not token:
            print("API request aborted: No valid token available")
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
                        print(f"HTTP {response.status} for {url}")
                        return {}

                    print("Token expired or invalid -> Refreshing token")

                # Perform the token refresh outside the initial response context.
                new_token = await self.auth.refresh_after_unauthorized(token)

                if not new_token:
                    print(
                        "API request failed: "
                        "Unable to refresh the token"
                    )
                    return {}

                retry_headers = {
                    "Authorization": f"Bearer {new_token}",
                    "Content-Type": "application/json"
                }

                # Retry the API request exactly once.
                async with session.request(
                    method,
                    url,
                    headers=retry_headers
                ) as retry_response:

                    if retry_response.status == 200:
                        return await retry_response.json()

                    print(
                        f"Retry failed "
                        f"({retry_response.status}) for {url}"
                    )
                    return {}

        except (aiohttp.ClientError, TimeoutError) as ex:
            print(f"API network error: {ex}")
            return {}

        except Exception as ex:
            print(f"API error: {ex}")
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

    async def get_contadores(self, cid):
        return await self._get(
            f"{self.base}/v2/calderas/{cid}/contadores"
        )
