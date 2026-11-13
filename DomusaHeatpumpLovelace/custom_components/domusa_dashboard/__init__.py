"""DOMUSA Dashboard integration."""

from __future__ import annotations

import logging
from collections.abc import Iterable
from typing import Any

from homeassistant.config_entries import ConfigEntry
from homeassistant.core import Event, HomeAssistant, callback
from homeassistant.helpers.entity_registry import (
    EVENT_ENTITY_REGISTRY_UPDATED,
    RegistryEntry,
    async_get as async_get_entity_registry,
)

from .const import BRIDGE_SENSOR_UIDS, BRIDGE_UNIQUE_ID_PREFIX, DOMAIN

_LOGGER = logging.getLogger(__name__)

DATA_ENTRIES = "entries"
DATA_ENTITIES = "entities_by_device"
DATA_REGISTRY_UNSUB = "registry_unsub"
DATA_YAML_LOADED = "yaml_loaded"


def _async_discover_bridge_entities(
    hass: HomeAssistant,
) -> dict[str, dict[str, str]]:
    """Find registered DOMUSA Bridge entities by their stable unique IDs.

    The Bridge unique ID format is:
        domusa_<device_id>_<sensor_uid>

    Entity IDs and friendly names are deliberately not used for discovery.
    """
    registry = async_get_entity_registry(hass)
    discovered: dict[str, dict[str, str]] = {}

    entries: Iterable[RegistryEntry] = sorted(
        registry.entities.values(),
        key=lambda item: item.entity_id,
    )

    for entity in entries:
        unique_id = entity.unique_id

        if not unique_id.startswith(BRIDGE_UNIQUE_ID_PREFIX):
            continue

        if entity.disabled_by is not None:
            continue

        matched_uid = next(
            (
                uid
                for uid in BRIDGE_SENSOR_UIDS
                if unique_id.endswith(f"_{uid}")
            ),
            None,
        )
        if matched_uid is None:
            continue

        device_id = unique_id[
            len(BRIDGE_UNIQUE_ID_PREFIX) : -(len(matched_uid) + 1)
        ]
        if not device_id:
            continue

        device_entities = discovered.setdefault(device_id, {})
        if matched_uid in device_entities:
            _LOGGER.warning(
                "Duplicate DOMUSA Bridge UID '%s' found for device '%s'; "
                "keeping entity '%s' and ignoring '%s'",
                matched_uid,
                device_id,
                device_entities[matched_uid],
                entity.entity_id,
            )
            continue

        device_entities[matched_uid] = entity.entity_id

    return discovered


@callback
def _async_refresh_discovery(hass: HomeAssistant) -> None:
    """Refresh the cached entity mapping for all active integration entries."""
    domain_data: dict[str, Any] | None = hass.data.get(DOMAIN)
    if domain_data is None:
        return

    discovered = _async_discover_bridge_entities(hass)
    domain_data[DATA_ENTITIES] = discovered

    entity_count = sum(len(entities) for entities in discovered.values())
    _LOGGER.debug(
        "Discovered %d DOMUSA Bridge entities across %d device(s)",
        entity_count,
        len(discovered),
    )


def _async_ensure_runtime(hass: HomeAssistant) -> dict[str, Any]:
    """Create shared runtime data and subscribe to registry updates once."""
    domain_data = hass.data.setdefault(
        DOMAIN,
        {
            DATA_ENTRIES: {},
            DATA_ENTITIES: {},
            DATA_REGISTRY_UNSUB: None,
            DATA_YAML_LOADED: False,
        },
    )

    if domain_data[DATA_REGISTRY_UNSUB] is None:
        domain_data[DATA_REGISTRY_UNSUB] = hass.bus.async_listen(
            EVENT_ENTITY_REGISTRY_UPDATED,
            lambda event: _async_refresh_discovery(hass),
        )

    _async_refresh_discovery(hass)
    return domain_data


async def async_setup(hass: HomeAssistant, config: dict) -> bool:
    """Set up the integration from YAML."""
    domain_data = _async_ensure_runtime(hass)
    domain_data[DATA_YAML_LOADED] = True
    return True


async def async_setup_entry(hass: HomeAssistant, entry: ConfigEntry) -> bool:
    """Set up DOMUSA Dashboard from a config entry."""
    domain_data = _async_ensure_runtime(hass)
    domain_data[DATA_ENTRIES][entry.entry_id] = {}
    _async_refresh_discovery(hass)
    return True


async def async_unload_entry(hass: HomeAssistant, entry: ConfigEntry) -> bool:
    """Unload DOMUSA Dashboard from a config entry."""
    domain_data: dict[str, Any] | None = hass.data.get(DOMAIN)
    if domain_data is None:
        return True

    domain_data[DATA_ENTRIES].pop(entry.entry_id, None)

    if not domain_data[DATA_ENTRIES] and not domain_data[DATA_YAML_LOADED]:
        unsubscribe = domain_data[DATA_REGISTRY_UNSUB]
        if unsubscribe is not None:
            unsubscribe()
        hass.data.pop(DOMAIN, None)

    return True
