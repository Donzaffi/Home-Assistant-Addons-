
import asyncio
import json
import sys
import os

sys.path.append(os.path.dirname(os.path.realpath(__file__)))

from error_codes import get_error_summary
from auth import Auth
from api import DomusaAPI
from mqtt import MQTT
from discovery import Discovery
from state import StateManager
from router import Router
from storage import Storage


def log(msg):
    print(f"DEBUG: {msg}")
    sys.stdout.flush()


async def poll_loop(api, state, device, cfg):
    while True:
        try:
            log("Starting data polling...")

            # Fetch runtime state and configuration
            estado = await api.get_estado(device["id"])
            config = await api.get_config(device["id"])

            # Merge runtime state and configuration
            full_data = dict(estado or {})

            if config:
                for key, value in config.items():
                    if key not in full_data:
                        full_data[key] = value

            # Fetch counters and energy statistics (API type 22)
            contadores = await api.get_contadores(device["id"])

            if isinstance(contadores, dict) and contadores:
                full_data["contadores"] = contadores
                log("Counter and energy data retrieved successfully")
            else:
                log("Warning: No counter data received from the API")

            # Add error information
            if full_data:
                error_summary = get_error_summary(full_data)
                full_data.update(error_summary)

                if error_summary["error_active"]:
                    log("DOMUSA ERROR: " + error_summary["error_description"])
                else:
                    log("No active DOMUSA errors")

                # Publish all available data to MQTT
                log(f"Publishing data to MQTT ({len(full_data)} top-level fields)")
                await state.publish(full_data)

            else:
                log("Warning: No data received from the API")

        except Exception as ex:
            log(f"Polling error: {ex}")

        await asyncio.sleep(cfg.get("poll_interval", 60))


async def main():
    log("Initializing...")

    with open("/data/options.json", "r") as f:
        config = json.load(f)

    auth = Auth(config["username"], config["password"])
    api = DomusaAPI(auth)

    storage = Storage()
    device = await storage.get_device()

    if not device:
        device = await api.get_caldera()

        if not device:
            raise RuntimeError("No DOMUSA device found.")

        await storage.save_device(device)

    mqtt = MQTT(
        host=config.get("mqtt_host", "core-mosquitto"),
        port=1883,
        user=config.get("mqtt_user"),
        password=config.get("mqtt_password")
    )

    await mqtt.connect()

    discovery = Discovery(mqtt, device)
    await discovery.publish()

    state = StateManager(mqtt, device)
    router = Router(api, mqtt, device)

    await asyncio.gather(
        poll_loop(api, state, device, config),
        router.listen()
    )


if __name__ == "__main__":
    asyncio.run(main())
