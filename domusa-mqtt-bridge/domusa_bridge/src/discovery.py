import json
import os

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
    
    # -------------------------------------------------
    # FEHLERDIAGNOSE
    # -------------------------------------------------
    {
        "uid": "error_active",
        "name": "DOMUSA Fehler aktiv",
        "key": "error_active",
        "component": "binary_sensor",
        "value_template": (
            "{{ 'ON' if value_json.error_active | bool else 'OFF' }}"
        ),
        "icon": "mdi:alert-circle",
        "entity_category": "diagnostic",
    },
    {
        "uid": "error_codes",
        "name": "DOMUSA Fehlercodes",
        "key": "error_codes",
        "icon": "mdi:alert",
        "entity_category": "diagnostic",
    },
    {
        "uid": "error_description",
        "name": "DOMUSA Fehlerbeschreibung",
        "key": "error_description",
        "icon": "mdi:text-box-search",
        "entity_category": "diagnostic",
    },



    
    # -------------------------------------------------
    # KONFIGURATION – TYP 19
    # -------------------------------------------------
    {
        "uid": "config_acs_enabled",
        "name": "Warmwasserfreigabe",
        "key": "m_acs_p63",
        "component": "binary_sensor",
        "value_template": (
            "{{ 'ON' if value_json.m_acs_p63 | bool else 'OFF' }}"
        ),
        "icon": "mdi:water-boiler",
        "entity_category": "diagnostic",
    },
    {
        "uid": "config_sgready_enabled",
        "name": "SG-Ready-Funktion aktiviert",
        "key": "m_sgready_p201",
        "component": "binary_sensor",
        "value_template": (
            "{{ 'ON' if value_json.m_sgready_p201 | bool else 'OFF' }}"
        ),
        "icon": "mdi:solar-power",
        "entity_category": "diagnostic",
    },
    {
        "uid": "config_night_mode",
        "name": "Nachtmodus",
        "key": "m_noche_p17",
        "component": "binary_sensor",
        "value_template": (
            "{{ 'ON' if value_json.m_noche_p17 | bool else 'OFF' }}"
        ),
        "icon": "mdi:weather-night",
        "entity_category": "diagnostic",
    },
    {
        "uid": "config_buffer_mode",
        "name": "Puffermodus",
        "key": "m_buffer_p121",
        "component": "binary_sensor",
        "value_template": (
            "{{ 'ON' if value_json.m_buffer_p121 | bool else 'OFF' }}"
        ),
        "icon": "mdi:storage-tank",
        "entity_category": "diagnostic",
    },
    {
        "uid": "config_heat_cool_hysteresis",
        "name": "Hysterese Heizen/Kühlen",
        "key": "hyst_c_f_p06",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:thermometer",
        "entity_category": "diagnostic",
    },
    {
        "uid": "config_acs_hysteresis",
        "name": "Warmwasser-Hysterese",
        "key": "hyst_acs_p07",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:water-thermometer",
        "entity_category": "diagnostic",
    },
    {
        "uid": "config_buffer_hysteresis",
        "name": "Puffer-Hysterese",
        "key": "hyst_buffer_p122",
        "unit": "°C",
        "icon": "mdi:thermometer-water",
        "entity_category": "diagnostic",
    },
    {
        "uid": "heating_circuit_pump",
        "name": "Heizkreispumpe",
        "key": "salidas_hp_10_c63",
        "component": "binary_sensor",
        "value_template": (
            "{{ 'ON' if value_json.salidas_hp_10_c63 | bool else 'OFF' }}"
        ),
        "icon": "mdi:pump",
        "entity_category": "diagnostic",
    },

    
    # -------------------------------------------------
    # ZÄHLER – TYP 22
    # -------------------------------------------------
    {
        "uid": "compressor_starts",
        "name": "Verdichterstarts",
        "key": "contadores.cont_n_comp",
        "value_template": (
            "{{ value_json.contadores.cont_n_comp }}"
        ),
        "icon": "mdi:counter",
        "entity_category": "diagnostic",
    },
    {
        "uid": "compressor_runtime",
        "name": "Verdichterlaufzeit",
        "key": "contadores.cont_h_comp_c50",
        "value_template": (
            "{{ value_json.contadores.cont_h_comp_c50 }}"
        ),
        "device_class": "duration",
        "unit": "h",
        "state_class": "total",
        "icon": "mdi:timer-outline",
        "entity_category": "diagnostic",
    },
    {
        "uid": "defrost_count",
        "name": "Abtauvorgänge",
        "key": "contadores.cont_n_defrost",
        "value_template": (
            "{{ value_json.contadores.cont_n_defrost }}"
        ),
        "icon": "mdi:snowflake-melt",
        "entity_category": "diagnostic",
    },
    {
        "uid": "energy_statistics",
        "name": "Energiedaten",
        "key": "contadores",
        "value_template": (
            "{{ 'verfügbar' if value_json.contadores is mapping "
            "else 'nicht verfügbar' }}"
        ),
        "json_attributes_template": (
            "{{ value_json.contadores | tojson "
            "if value_json.contadores is mapping else '{}' }}"
        ),
        "icon": "mdi:chart-box",
        "entity_category": "diagnostic",
    },
        # -------------------------------------------------
    # TAGESENERGIE UND COP – TYP 22
    # -------------------------------------------------
    {
        "uid": "daily_production",
        "name": "Tagesproduktion",
        "key": "contadores",
        "value_template": (
            "{{ value_json.get('contadores', {}).get("
            "'prod_dia_' ~ now().day) }}"
        ),
        "device_class": "energy",
        "unit": "kWh",
        "state_class": "total_increasing",
        "icon": "mdi:chart-bar",
    },
    {
        "uid": "daily_renewable",
        "name": "Erneuerbare Tagesenergie",
        "key": "contadores",
        "value_template": (
            "{{ value_json.get('contadores', {}).get("
            "'renov_dia_' ~ now().day) }}"
        ),
        "device_class": "energy",
        "unit": "kWh",
        "state_class": "total_increasing",
        "icon": "mdi:leaf",
    },
    {
        "uid": "daily_consumption",
        "name": "Tagesverbrauch",
        "key": "contadores",
        "value_template": (
            "{{ value_json.get('contadores', {}).get("
            "'consum_dia_' ~ now().day) }}"
        ),
        "device_class": "energy",
        "unit": "kWh",
        "state_class": "total_increasing",
        "icon": "mdi:flash",
    },
    {
        "uid": "daily_cop",
        "name": "Tages-COP",
        "key": "contadores",
        "value_template": (
            "{% set counters = value_json.get('contadores', {}) %}"
            "{% set day = now().day %}"
            "{% set production = counters.get('prod_dia_' ~ day, 0) | float(0) %}"
            "{% set consumption = counters.get('consum_dia_' ~ day, 0) | float(0) %}"
            "{{ (production / consumption) | round(2) "
            "if consumption > 0 else none }}"
        ),
        "state_class": "measurement",
        "icon": "mdi:chart-line",
    },
]
    
# -------------------------------------------------
# STEUERUNGEN – MQTT NUMBER
# -------------------------------------------------
NUMBER_CONTROLS = [
    {
        "uid": "control_dhw_target",
        "name": "Warmwasser Solltemperatur einstellen",
        "key": "st_acs_p04",
        "min": 40,
        "max": 65,
        "step": 1,
        "unit": "°C",
        "icon": "mdi:water-thermometer",
    },
    {
        "uid": "control_buffer_target",
        "name": "Puffer Solltemperatur einstellen",
        "key": "st_buffer_c_p123",
        "min": 25,
        "max": 50,
        "step": 1,
        "unit": "°C",
        "icon": "mdi:water-boiler",
    },
    {
        "uid": "control_heat_cool_hysteresis",
        "name": "Hysterese Heizen/Kühlen einstellen",
        "key": "hyst_c_f_p06",
        "min": 5,
        "max": 11,
        "step": 1,
        "unit": "°C",
        "icon": "mdi:thermometer",
    },
    {
        "uid": "control_acs_hysteresis",
        "name": "Warmwasser-Hysterese einstellen",
        "key": "hyst_acs_p07",
        "min": 5,
        "max": 10,
        "step": 1,
        "unit": "°C",
        "icon": "mdi:water-thermometer",
    },
    {
        "uid": "control_buffer_hysteresis",
        "name": "Puffer-Hysterese einstellen",
        "key": "hyst_buffer_p122",
        "min": 5,
        "max": 11,
        "step": 1,
        "unit": "°C",
        "icon": "mdi:thermometer-water",
    },
]


# -------------------------------------------------
# STEUERUNGEN – MQTT SELECT
# -------------------------------------------------
SG_READY_OPTIONS = ["0"] + [
    str(value) for value in range(40, 66)
]

SELECT_CONTROLS = [
    {
        "uid": "control_pump_c1_mode",
        "name": "Umwälzpumpe C1 Betriebsart",
        "key": "m_c1_p20",
        "options": [
            "Dauerbetrieb",
            "Normalbetrieb",
            "Intervallbetrieb",
        ],
        "value_template": (
            "{{ {0: 'Dauerbetrieb', "
            "1: 'Normalbetrieb', "
            "2: 'Intervallbetrieb'}.get("
            "value_json.get('m_c1_p20') | int(-1), '') }}"
        ),
        "command_template": (
            "{{ {'parameter': 'm_c1_p20', "
            "'value': {'Dauerbetrieb': 0, "
            "'Normalbetrieb': 1, "
            "'Intervallbetrieb': 2}[value]} | tojson }}"
        ),
        "icon": "mdi:pump",
    },
    {
        "uid": "control_sg2_heating",
        "name": "SG Ready Heizen Empfehlung",
        "key": "st_sg2_c_p202",
        "options": SG_READY_OPTIONS,
        "icon": "mdi:solar-power",
    },
    {
        "uid": "control_sgon_heating",
        "name": "SG Ready Heizen Anforderung",
        "key": "st_sgon_c_p203",
        "options": SG_READY_OPTIONS,
        "icon": "mdi:solar-power",
    },
    {
        "uid": "control_sg2_dhw",
        "name": "SG Ready Warmwasser Empfehlung",
        "key": "st_sg2_acs_p206",
        "options": SG_READY_OPTIONS,
        "icon": "mdi:water-boiler",
    },
    {
        "uid": "control_sgon_dhw",
        "name": "SG Ready Warmwasser Anforderung",
        "key": "st_sgon_acs_p207",
        "options": SG_READY_OPTIONS,
        "icon": "mdi:water-boiler",
    },



]

REMOVED_SENSOR_UIDS = [
    "zone2_demand",
    "zone3_demand",
    "boost_mode",
    "manual_defrost",
]




class Discovery:

    def __init__(self, mqtt, device, language="en"):
        self.mqtt = mqtt
        self.device = device
        self.language = language if language in ("en", "de", "es") else "en"
        translations_path = os.path.join(
            os.path.dirname(os.path.realpath(__file__)),
            "translations",
            f"{self.language}.json",
        )
        try:
            with open(translations_path, "r", encoding="utf-8") as translation_file:
                self.translations = json.load(translation_file)
        except (OSError, json.JSONDecodeError) as ex:
            print(f"DEBUG: Could not load {self.language} translations: {ex}; using English")
            self.language = "en"
            fallback_path = os.path.join(
                os.path.dirname(os.path.realpath(__file__)), "translations", "en.json"
            )
            with open(fallback_path, "r", encoding="utf-8") as translation_file:
                self.translations = json.load(translation_file)

    def translated_name(self, uid, fallback):
        return self.translations.get("entities", {}).get(uid, fallback)

    def translated_state(self, group, key):
        return self.translations[group][key][self.language]

    async def publish(self):
        cid = self.device["id"]

        dev_info = {
            "identifiers": [f"domusa_htec_{cid}"],
            "name": "Domusa HTEC",
            "manufacturer": "Domusa",
            "model": "HTEC Pro 12",
        }

        state_topic = f"domusa/{cid}/status"
        command_topic = f"domusa/{cid}/set"
        availability_topic = f"domusa/{cid}/availability"

        # Remove obsolete sensor discovery entries
        for uid in REMOVED_SENSOR_UIDS:
            topic = f"homeassistant/sensor/domusa_{cid}_{uid}/config"
            await self.mqtt.client.publish(topic, "", retain=True)

        # Publish existing sensors without changing their unique IDs
        for sensor in SENSORS:
            component = sensor.get("component", "sensor")

            value_template = sensor.get(
                "value_template",
                f"{{{{ value_json.{sensor['key']} }}}}"
            )
            if sensor["uid"] == "operation_state":
                states = self.translations["states"]
                state_map = {
                    "0": states["0"][self.language],
                    "1": states["1"][self.language],
                    "2": states["2"][self.language],
                    "3": states["3"][self.language],
                }
                state_map_jinja = json.dumps(state_map, ensure_ascii=False)
                unknown = json.dumps(states["unknown"][self.language], ensure_ascii=False)
                value_template = (
                    "{% set map=" + state_map_jinja + " %}"
                    "{{ map.get(value_json.estado_func_c52 | int | string, " + unknown + ") }}"
                )
            elif sensor["uid"] == "energy_statistics":
                available = json.dumps(self.translated_state("availability", "available"), ensure_ascii=False)
                unavailable = json.dumps(self.translated_state("availability", "unavailable"), ensure_ascii=False)
                value_template = (
                    "{{ " + available + " if value_json.contadores is mapping else " + unavailable + " }}"
                )

            payload = {
                "name": self.translated_name(sensor["uid"], sensor["name"]),
                "unique_id": f"domusa_{cid}_{sensor['uid']}",
                "device": dev_info,
                "state_topic": state_topic,
                "availability_topic": availability_topic,
                "value_template": value_template,
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

            if "state_class" in sensor:
                payload["state_class"] = sensor["state_class"]

            if "entity_category" in sensor:
                payload["entity_category"] = sensor["entity_category"]

            if "json_attributes_template" in sensor:
                payload["json_attributes_topic"] = state_topic
                payload["json_attributes_template"] = (
                    sensor["json_attributes_template"]
                )

            topic = (
                f"homeassistant/{component}/"
                f"domusa_{cid}_{sensor['uid']}/config"
            )

            await self.mqtt.client.publish(
                topic,
                json.dumps(payload, ensure_ascii=False),
                retain=True,
            )

        # Publish adjustable number entities
        for control in NUMBER_CONTROLS:
            key = control["key"]

            value_template = (
                f"{{{{ value_json.{key} }}}}"
            )

            if key == "st_acs_p04":
                value_template = (
                    "{{ value_json.st_acs_p04 "
                    "if value_json.st_acs_p04 is not none "
                    "and value_json.st_acs_p04 != -255 else 'None' }}"
                )

            payload = {
                "name": self.translated_name(control["uid"], control["name"]),
                "unique_id": f"domusa_{cid}_{control['uid']}",
                "device": dev_info,
                "state_topic": state_topic,
                "command_topic": command_topic,
                "availability_topic": availability_topic,
                "value_template": value_template,
                "payload_reset": "None",
                "command_template": (
                    "{{ {'parameter': '" + key +
                    "', 'value': value | int} | tojson }}"
                ),
                "min": control["min"],
                "max": control["max"],
                "step": control["step"],
                "mode": "slider",
                "unit_of_measurement": control["unit"],
                "icon": control["icon"],
            }

            topic = (
                f"homeassistant/number/"
                f"domusa_{cid}_{control['uid']}/config"
            )

            await self.mqtt.client.publish(
                topic,
                json.dumps(payload, ensure_ascii=False),
                retain=True,
            )

        # Publish selectable entities
        for control in SELECT_CONTROLS:
            key = control["key"]
            options = control["options"]
            value_template = control.get(
                "value_template",
                f"{{{{ value_json.{key} | int | string }}}}"
            )

            command_template = control.get(
                "command_template",
                (
                    "{{ {'parameter': '" + key +
                    "', 'value': value | int} | tojson }}"
                )
            )

            if control["uid"] == "control_pump_c1_mode":
                pump_modes = self.translations["pump_modes"]
                labels = [pump_modes[str(index)][self.language] for index in range(3)]
                options = labels
                value_map = {str(index): label for index, label in enumerate(labels)}
                value_template = (
                    "{% set map=" + json.dumps(value_map, ensure_ascii=False) + " %}"
                    "{{ map.get(value_json.get('m_c1_p20') | int(-1) | string, '') }}"
                )
                reverse_map = {label: index for index, label in enumerate(labels)}
                command_template = (
                    "{{ {'parameter': 'm_c1_p20', 'value': "
                    + json.dumps(reverse_map, ensure_ascii=False)
                    + "[value]} | tojson }}"
                )

            payload = {
                "name": self.translated_name(control["uid"], control["name"]),
                "unique_id": f"domusa_{cid}_{control['uid']}",
                "device": dev_info,
                "state_topic": state_topic,
                "command_topic": command_topic,
                "availability_topic": availability_topic,
                "options": options,
                "value_template": value_template,
                "command_template": command_template,
                "icon": control["icon"],
            }

            topic = (
                f"homeassistant/select/"
                f"domusa_{cid}_{control['uid']}/config"
            )

            await self.mqtt.client.publish(
                topic,
                json.dumps(payload, ensure_ascii=False),
                retain=True,
            )
