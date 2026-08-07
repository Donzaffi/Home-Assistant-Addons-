import json

SENSORS = [

    #
    # Temperaturen
    #
    {
        "uid": "outside_temperature",
        "name": "Außentemperatur",
        "key": "s_ext_c02",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:thermometer"
    },
    {
        "uid": "evaporator_temperature",
        "name": "Verdampfer",
        "key": "s_evap_c00",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:thermometer"
    },
    {
        "uid": "discharge_temperature",
        "name": "Verdichterausgang",
        "key": "s_discharge_c01",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:thermometer"
    },
    {
        "uid": "suction_temperature",
        "name": "Sauggas",
        "key": "s_suction_c03",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:thermometer"
    },
    {
        "uid": "condenser_temperature",
        "name": "Verflüssiger",
        "key": "s_condens_c06",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:thermometer"
    },
    {
        "uid": "flow_temperature",
        "name": "Vorlauf",
        "key": "s_ida_hp_c08",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:radiator"
    },
    {
        "uid": "return_temperature",
        "name": "Rücklauf",
        "key": "s_ret_hp_c07",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:radiator"
    },
    {
        "uid": "dhw_temperature",
        "name": "Warmwasser",
        "key": "s_acs_c09",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:water-thermometer"
    },
    {
        "uid": "dhw_target_temperature",
        "name": "Warmwasser Soll",
        "key": "st_activa_acs",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:water-thermometer"
    },
    {
        "uid": "buffer_target_temperature",
        "name": "Puffer Soll",
        "key": "st_buffer_c_p123",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:thermometer-water"
    },
    {
        "uid": "ambient_target_temperature",
        "name": "Raum Soll",
        "key": "st_amb_p05",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:home-thermometer"
    },
    {
        "uid": "heating_target_temperature",
        "name": "Heizung Soll",
        "key": "st_activa_c_f",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:radiator"
    },
    {
        "uid": "delta_temperature",
        "name": "Delta T",
        "key": "dt_hp_c11",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:thermometer"
    },
    {
        "uid": "ipm_temperature",
        "name": "IPM",
        "key": "s_ipm_c22",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:thermometer",
        "entity_category": "diagnostic"
    },
    {
        "uid": "t6_temperature",
        "name": "T6",
        "key": "s_t6_c25",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:thermometer",
        "entity_category": "diagnostic"
    },
    {
        "uid": "ambient_t2_temperature",
        "name": "Raumfühler T2",
        "key": "s_amb_t2_c26",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:home-thermometer",
        "entity_category": "diagnostic"
    },
    {
        "uid": "evaporator_calculated_temperature",
        "name": "Verdampfer berechnet",
        "key": "s_evap_calc_c27",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:calculator",
        "entity_category": "diagnostic"
    },

    {
        "uid": "buffer_temperature",
        "name": "Puffer",
        "key": "s_buffer_c57",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:thermometer-water",
        "entity_category": "diagnostic"
    },
    {
        "uid": "boiler_temperature",
        "name": "Kessel",
        "key": "s_cald_c59",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:boiler",
        "entity_category": "diagnostic"
    },
    {
        "uid": "otc_temperature",
        "name": "OTC Temperatur",
        "key": "s_otc_c58",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:thermometer-chevron-up",
        "entity_category": "diagnostic"
    },
    {
        "uid": "outside_zone_temperature",
        "name": "Außenfühler Zone",
        "key": "s_zonaext_c75",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:thermometer"
    },

    {
        "uid": "condensing_temperature",
        "name": "Verflüssiger berechnet",
        "key": "s_cond_calc_c28",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:thermometer-water",
        "entity_category": "diagnostic"
    },
    

    #
    # Elektrik
    #
    {
        "uid": "ac_voltage",
        "name": "AC Spannung",
        "key": "volt_ac_c23",
        "device_class": "voltage",
        "unit": "V",
        "icon": "mdi:flash"
    },
    {
        "uid": "dc_voltage",
        "name": "DC Spannung",
        "key": "volt_dc_c24",
        "device_class": "voltage",
        "unit": "V",
        "icon": "mdi:flash"
    },
    {
        "uid": "compressor_current",
        "name": "Kompressorstrom",
        "key": "curr_comp_c21",
        "device_class": "current",
        "unit": "A",
        "icon": "mdi:current-ac"
    },
    {
        "uid": "phase_current",
        "name": "Phasenstrom",
        "key": "curr_ph_comp",
        "device_class": "current",
        "unit": "A",
        "icon": "mdi:current-ac"
    },

    {
        "uid": "thermal_power",
        "name": "Wärmeleistung",
        "key": "s_q_c10",
        "device_class": "power",
        "unit": "kW",
        "icon": "mdi:heat-wave"
    },

    #
    # Kältekreis
    #
    {
        "uid": "high_pressure",
        "name": "Hochdruck",
        "key": "s_pralta_c13",
        "unit": "MPa",
        "icon": "mdi:gauge",
        "entity_category": "diagnostic"
    },
    {
        "uid": "low_pressure",
        "name": "Niederdruck",
        "key": "s_prbaja_c14",
        "unit": "MPa",
        "icon": "mdi:gauge",
        "entity_category": "diagnostic"
    },
    {
        "uid": "compressor_frequency",
        "name": "Kompressorfrequenz",
        "key": "freq_c15",
        "device_class": "frequency",
        "unit": "Hz",
        "icon": "mdi:sine-wave"
    },
    {
        "uid": "compressor_frequency_target",
        "name": "Kompressor Sollfrequenz",
        "key": "st_freq_c20",
        "device_class": "frequency",
        "unit": "Hz",
        "icon": "mdi:sine-wave",
        "entity_category": "diagnostic"
    },
    {
        "uid": "eev_position",
        "name": "EEV",
        "key": "eev_c18",
        "unit": "steps",
        "icon": "mdi:valve",
        "entity_category": "diagnostic"
    },
    {
        "uid": "pwm",
        "name": "PWM",
        "key": "pwm_c1_c51",
        "unit": "%",
        "icon": "mdi:percent",
        "entity_category": "diagnostic"
    },
    {
        "uid": "compressor_pwm_raw",
        "name": "PWM Rohwert",
        "key": "s_pwm_c1",
        "icon": "mdi:pulse",
        "entity_category": "diagnostic"
    },

    #
    # Lüfter
    #
    {
        "uid": "fan1_rpm",
        "name": "Lüfter 1",
        "key": "rpm_vent1_c16",
        "unit": "rpm",
        "icon": "mdi:fan",
        "entity_category": "diagnostic"
    },
    {
        "uid": "fan2_rpm",
        "name": "Lüfter 2",
        "key": "rpm_vent2_c17",
        "unit": "rpm",
        "icon": "mdi:fan",
        "entity_category": "diagnostic"
    },

    #
    # Betrieb
    #

    {
        "uid": "operation_state",
        "name": "Betriebszustand",
        "key": "estado_func_c52",
        "icon": "mdi:state-machine",
        "value_template":
            "{% set map={0:'Standby',1:'Warmwasser',2:'Heizen',3:'Warmwasser + Heizen',4:'Kühlen'} %}"
            "{{ map.get(value_json.estado_func_c52|int,'Unbekannt') }}"
    },

    {
        "uid": "zone1_demand",
        "name": "Zone 1 Anforderung",
        "key": "demanda_zona1",
        "icon": "mdi:home-thermometer"
    },
    {
        "uid": "zone2_demand",
        "name": "Zone 2 Anforderung",
        "key": "demanda_zona2",
        "icon": "mdi:home-thermometer"
    },
    {
        "uid": "zone3_demand",
        "name": "Zone 3 Anforderung",
        "key": "demanda_zona3",
        "icon": "mdi:home-thermometer"
    },
    {
        "uid": "hotwater_active",
        "name": "Warmwasser aktiv",
        "key": "m_estadoacs",
        "icon": "mdi:water-boiler"
    },
    {
        "uid": "boost_mode",
        "name": "Boost",
        "key": "func_boost",
        "icon": "mdi:rocket-launch"
    },
    {
        "uid": "manual_defrost",
        "name": "Manuelles Abtauen",
        "key": "manual_defrost_p28",
        "icon": "mdi:snowflake-melt"
    },
    {
        "uid": "grid_frequency",
        "name": "Netzfrequenz",
        "key": "e_freq",
        "device_class": "frequency",
        "unit": "Hz",
        "icon": "mdi:sine-wave"
    },
    {
        "uid": "frequency_stage",
        "name": "Frequenzstufe",
        "key": "m_freq",
        "icon": "mdi:speedometer"
    },
    {
        "uid": "heat_demand",
        "name": "Wärmeanforderung",
        "key": "demanda_hp",
        "icon": "mdi:radiator"
    },

    #
    # Zonen
    #

    {
        "uid": "room_target",
        "name": "Raum Soll",
        "key": "st_amb_p05",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:home-thermometer"
    },
    {
        "uid": "buffer_target",
        "name": "Puffer Soll",
        "key": "st_buffer_c_p123",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:water-boiler"
    },
    {
        "uid": "zone1_target",
        "name": "Zone 1 Soll",
        "key": "st_zona1_c_p158",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:home-floor-1"
    },
    {
        "uid": "zone2_target",
        "name": "Zone 2 Soll",
        "key": "st_zona2_c_p159",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:home-floor-2"
    },
    {
        "uid": "zone3_target",
        "name": "Zone 3 Soll",
        "key": "st_zona3_c_p160",
        "device_class": "temperature",
        "unit": "°C",
        "icon": "mdi:home-floor-3"
    },
    {
        "uid": "zone1_request",
        "name": "Zone 1 Anforderung",
        "key": "demanda_zona1",
        "icon": "mdi:home-floor-1"
    },
    {
        "uid": "zone2_request",
        "name": "Zone 2 Anforderung",
        "key": "demanda_zona2",
        "icon": "mdi:home-floor-2"
    },
    {
        "uid": "zone3_request",
        "name": "Zone 3 Anforderung",
        "key": "demanda_zona3",
        "icon": "mdi:home-floor-3"
    },
    
    {
        "uid": "alarm",
        "name": "Alarm",
        "key": "alarma",
        "icon": "mdi:alert"
    },
    {
        "uid": "sub_alarm",
        "name": "Unteralarm",
        "key": "sub_alarma",
        "icon": "mdi:alert-circle"
    }
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
            "model": "HTEC Pro 12"
        }

        for sensor in SENSORS:

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
                "icon": sensor.get("icon")
            }

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
            ):
                payload["state_class"] = "measurement"

            if "entity_category" in sensor:
                payload["entity_category"] = sensor["entity_category"]

            await self.mqtt.client.publish(
                f"homeassistant/sensor/domusa_{cid}_{sensor['uid']}/config",
                json.dumps(payload),
                retain=True
            )

