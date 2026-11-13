
"""Data coordinator for the DOMUSA Dashboard integration."""

from __future__ import annotations

import logging
from datetime import timedelta
from typing import Any

from homeassistant.config_entries import ConfigEntry
from homeassistant.core import HomeAssistant
from homeassistant.helpers.update_coordinator import DataUpdateCoordinator

from .const import DOMAIN

_LOGGER = logging.getLogger(__name__)

# Shared runtime key defined in __init__.py.
DATA_ENTITIES = "entities_by_device"

# Map stable Bridge UIDs to dashboard data keys.
SENSOR_UID_TO_KEY = {
    "s_ext_c02": "outside_temperature",
    "s_ret_hp_c07": "return_temperature",
    "s_ida_hp_c08": "flow_temperature",
    "s_acs_c09": "dhw_temperature",
    "s_buffer_c57": "buffer_temperature",
    "s_q_c10": "water_flow",
    "pwm_c1_c51": "pump_c1_speed",
    "estado_func_c52": "operation_state",
    "demanda_zona1": "zone1_demand",
    "m_estadoacs": "hotwater_active",
    "demanda_hp": "heat_demand",
    "st_buffer_c_p123": "buffer_target",
    "st_c_p02": "heating_target",
    "st_f_p03": "cooling_target",
    "st_acs_p04": "dhw_target",
    "freq_c15": "compressor_frequency",
    "st_freq_c20": "compressor_frequency_target",
    "curr_comp_c21": "compressor_current",
    "s_evap_c00": "evaporator_temperature",
    "s_discharge_c01": "discharge_temperature",
    "s_suction_c03": "suction_temperature",
    "s_condens_c06": "condenser_temperature",
    "s_pralta_c13": "high_pressure",
    "s_prbaja_c14": "low_pressure",
    "rpm_vent1_c16": "fan_1_speed",
    "rpm_vent2_c17": "fan_2_speed",
    "heating_circuit_pump": "heating_circuit_pump",
}


class DomusaDataCoordinator(DataUpdateCoordinator[dict[str, Any]]):
    """Collect existing DOMUSA Bridge entity states for the dashboard."""

    def __init__(
        self,
        hass: HomeAssistant,
        config_entry: ConfigEntry,
    ) -> None:
        """Initialize the coordinator."""
        super().__init__(
            hass,
            _LOGGER,
            config_entry=config_entry,
            name="DOMUSA Dashboard",
            update_interval=timedelta(seconds=10),
        )

    async def _async_update_data(self) -> dict[str, Any]:
        """Read the current states of all discovered Bridge entities."""
        domain_data = self.hass.data.get(DOMAIN, {})
        discovered = domain_data.get(DATA_ENTITIES, {})

        result: dict[str, Any] = {}

        for device_id, device_entities in discovered.items():
            device_data: dict[str, Any] = {}

            for uid, dashboard_key in SENSOR_UID_TO_KEY.items():
                entity_id = device_entities.get(uid)

                if entity_id is None:
                    device_data[dashboard_key] = {
                        "entity_id": None,
                        "state": None,
                        "attributes": {},
                    }
                    continue

                state = self.hass.states.get(entity_id)

                if state is None:
                    device_data[dashboard_key] = {
                        "entity_id": entity_id,
                        "state": None,
                        "attributes": {},
                    }
                    continue

                device_data[dashboard_key] = {
                    "entity_id": entity_id,
                    "state": state.state,
                    "attributes": dict(state.attributes),
                }

            result[device_id] = device_data

        _LOGGER.debug(
            "Updated DOMUSA data for %d device(s)",
            len(result),
        )

        return result
