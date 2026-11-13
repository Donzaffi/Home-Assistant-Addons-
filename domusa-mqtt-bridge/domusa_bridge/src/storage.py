
import json
import os


class Storage:
    DEVICE_FILE = "/data/device.json"
    DEVICES_FILE = "/data/devices.json"

    async def get_devices(self):
        """
        Load all stored DOMUSA installations.

        Prefer the new multi-device file.
        Fall back to the legacy single-device file.
        """

        # Load the new multi-device storage.
        if os.path.exists(self.DEVICES_FILE):
            try:
                with open(self.DEVICES_FILE, "r") as f:
                    devices = json.load(f)

                if isinstance(devices, list):
                    return self._validate_devices(devices)

            except (OSError, json.JSONDecodeError) as ex:
                print(f"Storage error reading devices.json: {ex}")

        # Migrate the legacy single-device storage.
        if os.path.exists(self.DEVICE_FILE):
            try:
                with open(self.DEVICE_FILE, "r") as f:
                    device = json.load(f)

                if isinstance(device, dict):
                    devices = self._validate_devices([device])

                    if devices:
                        print(
                            "Legacy device.json loaded successfully"
                        )
                        return devices

            except (OSError, json.JSONDecodeError) as ex:
                print(f"Storage error reading device.json: {ex}")

        return []

    def _validate_devices(self, devices):
        """
        Validate and deduplicate device entries.
        """

        valid_devices = []
        seen_ids = set()

        for device in devices:
            if not isinstance(device, dict):
                continue

            cid = device.get("id")

            if cid is None:
                continue

            cid = str(cid).strip()

            if not cid or cid in seen_ids:
                continue

            device = dict(device)
            device["id"] = cid

            if not device.get("name"):
                device["name"] = cid

            seen_ids.add(cid)
            valid_devices.append(device)

        return valid_devices

    async def save_devices(self, devices):
        """
        Save all DOMUSA installations.
        """

        valid_devices = self._validate_devices(devices)

        if not valid_devices:
            raise ValueError(
                "Cannot save an empty DOMUSA device list"
            )

        try:
            with open(self.DEVICES_FILE, "w") as f:
                json.dump(
                    valid_devices,
                    f,
                    indent=2,
                    ensure_ascii=False
                )

            print(
                f"Storage: Saved {len(valid_devices)} DOMUSA installation(s)"
            )

        except OSError as ex:
            print(f"Storage error saving devices: {ex}")
            raise

    async def get_device(self):
        """
        Backward-compatible helper returning the first device.
        """

        devices = await self.get_devices()
        return devices[0] if devices else None

    async def save_device(self, device):
        """
        Backward-compatible helper for single-device storage.
        """

        await self.save_devices([device])
