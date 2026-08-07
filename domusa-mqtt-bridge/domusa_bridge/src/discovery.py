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
        "uid": "operation_mode",
        "name": "Betriebsmodus",
        "key": "m_hp_p01",
        "icon": "mdi:cog"
    },
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
        "uid": "grid_frequency",
        "name": "Netzfrequenz",
        "key": "e_freq",
        "device_class": "frequency",
        "unit": "Hz",
        "icon": "mdi:sine-wave"
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
                "name": f"Domusa {sensor['name']}",
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

