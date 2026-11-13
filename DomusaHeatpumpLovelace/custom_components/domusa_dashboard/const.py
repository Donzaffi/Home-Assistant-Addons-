"""Constants for the DOMUSA Dashboard integration."""

DOMAIN = "domusa_dashboard"
NAME = "DOMUSA Dashboard"
VERSION = "0.1.0"

# Stable unique ID prefix used by the DOMUSA MQTT Bridge.
BRIDGE_UNIQUE_ID_PREFIX = "domusa_"

# Bridge sensor UID suffixes used by the initial dashboard entity discovery.
# The full Home Assistant unique_id also contains the DOMUSA device ID.
BRIDGE_SENSOR_UIDS = frozenset(
    {
        "s_ext_c02",       # Outdoor temperature
        "s_ret_hp_c07",    # Heat pump return temperature
        "s_ida_hp_c08",    # Heat pump flow temperature
        "s_acs_c09",       # Domestic hot water temperature
        "s_buffer_c57",    # Buffer temperature
        "s_q_c10",         # Water flow
        "pwm_c1_c51",      # Heating circuit pump speed
        "estado_func_c52", # Operating state
        "demanda_zona1",   # Heating zone demand
        "m_estadoacs",     # Domestic hot water active
        "demanda_hp",      # Heat pump demand
        "st_buffer_c_p123",# Buffer target temperature
        "st_c_p02",        # Heating target temperature
        "st_f_p03",        # Cooling target temperature
        "st_acs_p04",      # Domestic hot water target temperature
        "freq_c15",        # Compressor frequency
        "st_freq_c20",     # Compressor frequency target
        "curr_comp_c21",   # Compressor current
        "s_evap_c00",      # Evaporator temperature
        "s_discharge_c01", # Discharge temperature
        "s_suction_c03",   # Suction temperature
        "s_condens_c06",   # Condenser temperature
        "s_pralta_c13",    # High-side refrigerant pressure
        "s_prbaja_c14",    # Low-side refrigerant pressure
        "rpm_vent1_c16",   # Fan 1 speed
        "rpm_vent2_c17",   # Fan 2 speed
    }
)
