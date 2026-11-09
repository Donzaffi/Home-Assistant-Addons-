import json

SENSORS = [
    # -------------------------------------------------
    # TEMPERATUREN – STATUSPARAMETER C00 BIS C09
    # -------------------------------------------------
    {
        "uid": "evaporator_temperature",
        "name": "Verdampfertemperatur",
        "key": "s_evap_c00",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:thermometer",
    },
    {
        "uid": "discharge_temperature",
        "name": "Verdichter-Austrittstemperatur",
        "key": "s_discharge_c01",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:thermometer",
    },
    {
        "uid": "outside_temperature",
        "name": "Außentemperatur",
        "key": "s_ext_c02",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:thermometer",
    },
    {
        "uid": "suction_temperature",
        "name": "Sauggastemperatur",
        "key": "s_suction_c03",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:thermometer",
    },
    {
        "uid": "heat_exchanger_temperature",
        "name": "Wärmetauschertemperatur",
        "key": "s_condens_c06",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:thermometer",
    },
    {
        "uid": "return_temperature",
        "name": "Wasserrücklauf",
        "key": "s_ret_hp_c07",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:radiator",
    },
    {
        "uid": "flow_temperature",
        "name": "Wasservorlauf",
        "key": "s_ida_hp_c08",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:radiator",
    },
    {
        "uid": "dhw_temperature",
        "name": "Warmwassertemperatur",
        "key": "s_acs_c09",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:water-thermometer",
    },
    {
        "uid": "buffer_temperature",
        "name": "Puffertemperatur",
        "key": "s_buffer_c57",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:thermometer-water",
        "entity_category": "diagnostic",
    },

    # -------------------------------------------------
    # TEMPERATURDIFFERENZ UND BERECHNETE WERTE
    # -------------------------------------------------
    {
        "uid": "suction_evaporation_delta",
        "name": "Delta T Sauggas / Verdampfung",
        "key": "dt_hp_c11",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:thermometer",
    },
    {
        "uid": "evaporation_calculated",
        "name": "Verdampfungstemperatur",
        "key": "s_evap_calc_c27",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:calculator",
        "entity_category": "diagnostic",
    },
    {
        "uid": "condensation_calculated",
        "name": "Kondensationstemperatur berechnet",
        "key": "s_cond_calc_c28",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:calculator",
        "entity_category": "diagnostic",
    },
    {
        "uid": "ipm_temperature",
        "name": "IPM-Modultemperatur",
        "key": "s_ipm_c22",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:thermometer",
        "entity_category": "diagnostic",
    },

    # -------------------------------------------------
    # ELEKTRISCHE WERTE
    # -------------------------------------------------
    {
        "uid": "input_voltage",
        "name": "Eingangsspannung",
        "key": "volt_ac_c23",
        "device_class": "voltage",
        "unit": "V",
        "icon": "mdi:flash",
    },
    {
        "uid": "ipm_voltage",
        "name": "IPM-Spannung",
        "key": "volt_dc_c24",
        "device_class": "voltage",
        "unit": "V",
        "icon": "mdi:flash",
        "entity_category": "diagnostic",
    },
    {
        "uid": "compressor_current",
        "name": "Verdichterstrom",
        "key": "curr_comp_c21",
        "device_class": "current",
        "unit": "A",
        "icon": "mdi:current-ac",
    },

    # -------------------------------------------------
    # WASSERKREIS
    # -------------------------------------------------
    {
        "uid": "water_flow",
        "name": "Wasserdurchfluss",
        "key": "s_q_c10",
        "unit": "L/min",
        "icon": "mdi:water-pump",
    },
    {
        "uid": "pump_c1_speed",
        "name": "Umwälzpumpe C1 Drehzahl",
        "key": "pwm_c1_c51",
        "unit": "%",
        "icon": "mdi:pump",
        "entity_category": "diagnostic",
    },

    # -------------------------------------------------
    # KÄLTEKREIS
    # -------------------------------------------------
    {
        "uid": "high_pressure",
        "name": "Kältekreis Hochdruck",
        "key": "s_pralta_c13",
        "device_class": "pressure",
        "unit": "bar",
        "value_template": (
            "{{ (value_json.s_pralta_c13 | float * 10) | round(2) }}"
        ),
        "icon": "mdi:gauge",
        "entity_category": "diagnostic",
    },
    {
        "uid": "low_pressure",
        "name": "Kältekreis Niederdruck",
        "key": "s_prbaja_c14",
        "device_class": "pressure",
        "unit": "bar",
        "value_template": (
            "{{ (value_json.s_prbaja_c14 | float * 10) | round(2) }}"
        ),
        "icon": "mdi:gauge",
        "entity_category": "diagnostic",
    },
    {
        "uid": "compressor_frequency",
        "name": "Verdichterfrequenz Ist",
        "key": "freq_c15",
        "device_class": "frequency",
        "unit": "Hz",
        "icon": "mdi:sine-wave",
    },
    {
        "uid": "compressor_frequency_target",
        "name": "Verdichterfrequenz Soll",
        "key": "st_freq_c20",
        "device_class": "frequency",
        "unit": "Hz",
        "icon": "mdi:sine-wave",
        "entity_category": "diagnostic",
    },
    {
        "uid": "eev_position",
        "name": "Elektronisches Expansionsventil",
        "key": "eev_c18",
        "unit": "°",
        "icon": "mdi:valve",
        "entity_category": "diagnostic",
    },

    # -------------------------------------------------
    # LÜFTER
    # -------------------------------------------------
    {
        "uid": "fan1_rpm",
        "name": "Lüfter 1 Drehzahl",
        "key": "rpm_vent1_c16",
        "unit": "rpm",
        "icon": "mdi:fan",
        "entity_category": "diagnostic",
    },
    {
        "uid": "fan2_rpm",
        "name": "Lüfter 2 Drehzahl",
        "key": "rpm_vent2_c17",
        "unit": "rpm",
        "icon": "mdi:fan",
        "entity_category": "diagnostic",
    },

    # -------------------------------------------------
    # BETRIEBSZUSTAND & SOLLWERTE
    # -------------------------------------------------
    {
        "uid": "operation_state",
        "name": "Betriebszustand Wärmepumpe",
        "key": "estado_func_c52",
        "icon": "mdi:state-machine",
        "value_template": (
            "{% set map={0:'Warten',1:'Warmwasser',2:'Heizen',3:'Kühlen'} %}"
            "{{ map.get(value_json.estado_func_c52 | int, 'Unbekannt') }}"
        ),
    },
    {
        "uid": "zone1_demand",
        "name": "Zone 1 Wärmeanforderung",
        "key": "demanda_zona1",
        "icon": "mdi:home-thermometer",
    },
    {
        "uid": "hotwater_active",
        "name": "Warmwasserbetrieb aktiv",
        "key": "m_estadoacs",
        "icon": "mdi:water-boiler",
    },
    {
        "uid": "heat_demand",
        "name": "Wärmepumpenanforderung",
        "key": "demanda_hp",
        "icon": "mdi:radiator",
    },
    {
        "uid": "buffer_target",
        "name": "Puffer Soll",
        "key": "st_buffer_c_p123",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:water-boiler",
    },


    # -------------------------------------------------
    # SG READY – BINÄRE EINGÄNGE
    # -------------------------------------------------
    {
        "uid": "sg_ready_c61",
        "name": "SG Ready Eingang C61",
        "key": "entradas_hp_5_c61",
        "component": "binary_sensor",
        "value_template": (
            "{{ 'ON' if value_json.entradas_hp_5_c61 | bool else 'OFF' }}"
        ),
        "icon": "mdi:solar-power",
    },
    {
        "uid": "sg_ready_c60",
        "name": "SG Ready Eingang C60",
        "key": "entradas_hp_7_c60",
        "component": "binary_sensor",
        "value_template": (
            "{{ 'ON' if value_json.entradas_hp_7_c60 | bool else 'OFF' }}"
        ),
        "icon": "mdi:solar-power",
    },

    # -------------------------------------------------
    # SOLLTEMPERATUREN – TYP 17
    # -------------------------------------------------
    {
        "uid": "heating_target",
        "name": "Heizung Solltemperatur",
        "key": "st_c_p02",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:radiator",
    },
    {
        "uid": "cooling_target",
        "name": "Kühlung Solltemperatur",
        "key": "st_f_p03",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:snowflake",
    },
    {
        "uid": "dhw_target",
        "name": "Warmwasser Solltemperatur",
        "key": "st_acs_p04",
        "device_class": "temperature",
        "unit": "°C",
        "value_template": (
            "{{ value_json.st_acs_p04 "
            "if value_json.st_acs_p04 is not none "
            "and value_json.st_acs_p04 != -255 else 'None' }}"
        ),
        "icon": "mdi:water-thermometer",
    },

    # -------------------------------------------------
    # ALARME
    # -------------------------------------------------
    {
        "uid": "alarm",
        "name": "Alarm",
        "key": "alarma",
        "icon": "mdi:alert",
    },
    {
        "uid": "sub_alarm",
        "name": "Unteralarm",
        "key": "sub_alarma",
        "icon": "mdi:alert-circle",
    },
]

REMOVED_SENSOR_UIDS = [
    "zone2_demand",
    "zone3_demand",
    "boost_mode",
    "manual_defrost",
]


class Discovery:

    def __init__(self, mqtt, device):
        self.mqtt = mqtt
        self.device = device

    async def publish(self):
        cid = self.device["id"]

        dev_info = {
            "identifiers": [f"domusa_htec_{cid}"],
            "name": "Domusa HTEC",
            "manufacturer": "Domusa",
            "model": "HTEC Pro 12",
        }

        for uid in REMOVED_SENSOR_UIDS:
            topic = f"homeassistant/sensor/domusa_{cid}_{uid}/config"
            await self.mqtt.client.publish(topic, "", retain=True)

        for sensor in SENSORS:
            component = sensor.get("component", "sensor")

            payload = {
                "name": sensor["name"],
                "unique_id": f"domusa_{cid}_{sensor['uid']}",
                "device": dev_info,
                "state_topic": f"domusa/{cid}/status",
                "availability_topic": f"domusa/{cid}/availability",
                "value_template": sensor.get(
                    "value_template",
                    f"{{{{ value_json.{sensor['key']} }}}}"
                ),
                "icon": sensor.get("icon"),
            }

            if component == "binary_sensor":
                payload["payload_on"] = "ON"
                payload["payload_off"] = "OFF"

            if "unit" in sensor:
                payload["unit_of_measurement"] = sensor["unit"]

            if "device_class" in sensor:
                payload["device_class"] = sensor["device_class"]

            if sensor.get("device_class") in (
                "temperature",
                "current",
                "voltage",
                "power",
                "frequency",
                "pressure",
            ):
                payload["state_class"] = "measurement"

            if "entity_category" in sensor:
                payload["entity_category"] = sensor["entity_category"]

            topic = f"homeassistant/{component}/domusa_{cid}_{sensor['uid']}/config"

            await self.mqtt.client.publish(
                topic,
                json.dumps(payload),
                retain=True,
            )
