
import aiohttp
import json


class DomusaAPI:

    def __init__(self, auth):
        self.base = "https://ic-api-app.azurewebsites.net/api"
        self.auth = auth

    async def _request(self, method, url, payload=None):
        token = await self.auth.get_token()

        if not token:
            print("API request aborted: No valid token available")
            return None

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
                    headers=headers,
                    json=payload
                ) as response:

                    if 200 <= response.status < 300:
                        body = await response.text()
                        return json.loads(body) if body.strip() else {}

                    if response.status not in (401, 440):
                        print(f"HTTP {response.status} for {url}")
                        return None

                    print("Token expired or invalid -> Refreshing token")

                new_token = await self.auth.refresh_after_unauthorized(token)

                if not new_token:
                    print("API request failed: Unable to refresh the token")
                    return None

                retry_headers = {
                    "Authorization": f"Bearer {new_token}",
                    "Content-Type": "application/json"
                }

                async with session.request(
                    method,
                    url,
                    headers=retry_headers,
                    json=payload
                ) as retry_response:

                    if 200 <= retry_response.status < 300:
                        body = await retry_response.text()
                        return json.loads(body) if body.strip() else {}

                    print(
                        f"Retry failed ({retry_response.status}) for {url}"
                    )
                    return None

        except (aiohttp.ClientError, TimeoutError) as ex:
            print(f"API network error: {ex}")
            return None

        except Exception as ex:
            print(f"API error: {ex}")
            return None

    async def _get(self, url):
        return await self._request("GET", url)

    async def _put(self, url, payload):
        result = await self._request("PUT", url, payload)
        return result is not None

    async def get_calderas(self):
        """
        Return all Domusa installations available to the account.
        """

        url = f"{self.base}/v1/usuario/calderas/aliases"
        data = await self._get(url)

        devices = []

        if isinstance(data, dict):
            for alias, value in data.items():

                if isinstance(value, dict):
                    cid = value.get("idcaldera") or alias

                    name = (
                        value.get("alias")
                        or value.get("nombre")
                        or value.get("name")
                        or str(alias)
                    )
                else:
                    cid = alias
                    name = str(alias)

                if cid is None:
                    continue

                devices.append({
                    "id": str(cid),
                    "name": str(name),
                    "alias": str(alias)
                })

        elif isinstance(data, list):
            for index, value in enumerate(data):

                if not isinstance(value, dict):
                    continue

                cid = value.get("idcaldera") or value.get("id")

                if cid is None:
                    continue

                name = (
                    value.get("alias")
                    or value.get("nombre")
                    or value.get("name")
                    or f"Domusa {index + 1}"
                )

                devices.append({
                    "id": str(cid),
                    "name": str(name),
                    "alias": str(name)
                })

        # Remove duplicates while preserving API order.
        unique_devices = []
        seen_ids = set()

        for device in devices:
            if device["id"] not in seen_ids:
                seen_ids.add(device["id"])
                unique_devices.append(device)

        return unique_devices

    async def get_caldera(self):
        """
        Backward-compatible helper returning the first installation.
        """

        devices = await self.get_calderas()
        return devices[0] if devices else None

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

    async def put_estado(self, cid, payload):
        return await self._put(
            f"{self.base}/v2/calderas/{cid}/estado",
            payload
        )

    async def put_config(self, cid, payload):
        return await self._put(
            f"{self.base}/v2/calderas/{cid}/configuracion",
            payload
        )
