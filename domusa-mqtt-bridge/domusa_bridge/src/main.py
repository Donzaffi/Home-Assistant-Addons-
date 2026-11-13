
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


async def poll_once(api, state, device, lock):
    """
    Fetch and publish the complete DOMUSA status.

    The lock prevents regular polling and command-triggered
    refreshes from running concurrently for the same device.
    """

    cid = device["id"]
    name = device.get("name") or cid

    async with lock:
        log(f"Polling {name} ({cid})...")

        # Fetch runtime state and configuration.
        estado = await api.get_estado(cid)
        config = await api.get_config(cid)

        # Merge runtime state and configuration.
        full_data = dict(estado or {})

        if config:
            for key, value in config.items():
                if key not in full_data:
                    full_data[key] = value

        # Fetch counters and energy statistics.
        contadores = await api.get_contadores(cid)

        if isinstance(contadores, dict) and contadores:
            full_data["contadores"] = contadores
            log(f"{name}: counter data retrieved successfully")
        else:
            log(f"Warning: no counter data received for {name}")

        if not full_data:
            log(f"Warning: no data received for {name} ({cid})")
            return False

        # Add error information.
        error_summary = get_error_summary(full_data)
        full_data.update(error_summary)

        if error_summary["error_active"]:
            log(
                f"{name}: DOMUSA ERROR: "
                f"{error_summary['error_description']}"
            )
        else:
            log(f"{name}: no active DOMUSA errors")

        # Publish the complete status.
        log(
            f"{name}: publishing "
            f"{len(full_data)} top-level fields"
        )

        await state.publish(full_data)

        return True


async def poll_loop(api, state, device, cfg, lock):
    """
    Continuously poll one DOMUSA installation.
    """

    cid = device["id"]
    name = device.get("name") or cid
    interval = cfg.get("poll_interval", 60)

    while True:
        try:
            await poll_once(api, state, device, lock)

        except Exception as ex:
            log(f"Polling error for {name} ({cid}): {ex}")

        await asyncio.sleep(interval)


async def main():
    log("Initializing Domusa MQTT Bridge...")

    with open("/data/options.json", "r") as f:
        config = json.load(f)

    # Initialize API and authentication.
    auth = Auth(
        config["username"],
        config["password"]
    )

    api = DomusaAPI(auth)
    storage = Storage()

    # Discover installations from the DOMUSA cloud API.
    devices = await api.get_calderas()

    if devices:
        # Save the latest cloud device list.
        await storage.save_devices(devices)

        log(
            f"Discovered {len(devices)} installation(s) "
            "from DOMUSA cloud"
        )

    else:
        # Fall back to previously stored installations.
        log(
            "Warning: no installations received from DOMUSA cloud. "
            "Trying local storage..."
        )

        devices = await storage.get_devices()

        if devices:
            log(
                f"Using {len(devices)} stored DOMUSA installation(s)"
            )
        else:
            raise RuntimeError(
                "No DOMUSA installations found in cloud "
                "or local storage"
            )

    log(
        f"Found {len(devices)} DOMUSA installation(s): "
        + ", ".join(
            f"{d.get('name', d['id'])} [{d['id']}]"
            for d in devices
        )
    )

    # Establish one shared MQTT connection.
    mqtt = MQTT(
        host=config.get("mqtt_host", "core-mosquitto"),
        port=config.get("mqtt_port", 1883),
        user=config.get("mqtt_user"),
        password=config.get("mqtt_password")
    )

    await mqtt.connect()

    # Create one state manager and polling lock per installation.
    tasks = []
    refresh_callbacks = {}

    for device in devices:
        cid = device["id"]
        name = device.get("name") or cid

        log(f"Initializing {name} ({cid})")

        state = StateManager(mqtt, device)
        discovery = Discovery(mqtt, device)

        # Publish Home Assistant MQTT discovery.
        await discovery.publish()

        # Separate lock for each installation.
        poll_lock = asyncio.Lock()

        # Create a callback for immediate status refresh.
        async def refresh_status(
            api=api,
            state=state,
            device=device,
            lock=poll_lock
        ):
            return await poll_once(
                api,
                state,
                device,
                lock
            )

        refresh_callbacks[str(cid)] = refresh_status

        # Start polling this installation.
        tasks.append(
            poll_loop(
                api,
                state,
                device,
                config,
                poll_lock
            )
        )

    # One router handles commands for all installations.
    router = Router(
        api,
        mqtt,
        devices,
        refresh_callbacks=refresh_callbacks
    )

    tasks.append(router.listen())

    log("All DOMUSA installations initialized")

    await asyncio.gather(*tasks)


if __name__ == "__main__":
    asyncio.run(main())
