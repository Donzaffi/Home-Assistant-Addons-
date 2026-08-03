#
# SPDX-FileCopyrightText: 2023-2026 Luca Bonissi <wallbox@bonissi.it>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

# Interface for MQTT and Home Assistant auto-discovery
#

$VERSION{MQTT}="1.9922";

#verbose(3,"Reloading MQTT library...\n");

@METER_MAP = (
  {meas => "Active.Power.ALL", topic => "METER_MQTT_POWER",      mult => "METER_MQTT_POWER_MULTIPLIER" },
  {meas => "Power.L1",         topic => "METER_MQTT_L1_POWER",   mult => "METER_MQTT_POWER_MULTIPLIER" },
  {meas => "Power.L2",         topic => "METER_MQTT_L2_POWER",   mult => "METER_MQTT_POWER_MULTIPLIER" },
  {meas => "Power.L3",         topic => "METER_MQTT_L3_POWER",   mult => "METER_MQTT_POWER_MULTIPLIER" },
  {meas => "Voltage.L1",       topic => "METER_MQTT_L1_VOLTAGE", mult => "METER_MQTT_VOLTAGE_MULTIPLIER" },
  {meas => "Voltage.L2",       topic => "METER_MQTT_L2_VOLTAGE", mult => "METER_MQTT_VOLTAGE_MULTIPLIER" },
  {meas => "Voltage.L3",       topic => "METER_MQTT_L3_VOLTAGE", mult => "METER_MQTT_VOLTAGE_MULTIPLIER" },
  {meas => "Current.L1",       topic => "METER_MQTT_L1_CURRENT", mult => "METER_MQTT_CURRENT_MULTIPLIER" },
  {meas => "Current.L2",       topic => "METER_MQTT_L2_CURRENT", mult => "METER_MQTT_CURRENT_MULTIPLIER" },
  {meas => "Current.L3",       topic => "METER_MQTT_L3_CURRENT", mult => "METER_MQTT_CURRENT_MULTIPLIER" },
);

@PV_MAP = (
  {meas => "power",            topic => "PV_MQTT_POWER",      mult => "PV_MQTT_POWER_MULTIPLIER" },
  {meas => "voltage",          topic => "PV_MQTT_VOLTAGE",    mult => "PV_MQTT_VOLTAGE_MULTIPLIER" },
  {meas => "current",          topic => "PV_MQTT_CURRENT",    mult => "PV_MQTT_CURRENT_MULTIPLIER" },
  {meas => "frequency",        topic => "PV_MQTT_FREQUENCY",  mult => "PV_MQTT_FREQUENCY_MULTIPLIER" },
  {meas => "energy",           topic => "PV_MQTT_ENERGY",     mult => "PV_MQTT_ENERGY_MULTIPLIER" },
  {meas => "efficiency",       topic => "PV_MQTT_EFFICIENCY", mult => "PV_MQTT_EFFICIENCY_MULTIPLIER" },
  {meas => "temperature",      topic => "PV_MQTT_TEMPERATURE",mult => "PV_MQTT_TEMPERATURE_MULTIPLIER" },
  {meas => "humidity",         topic => "PV_MQTT_HUMIDITY",   mult => "PV_MQTT_HUMIDITY_MULTIPLIER" },
);

@EV_MAP = (
  {meas => "soc",              topic => "EV_MQTT_SOC",          mult => "EV_MQTT_SOC_MULTIPLIER" },
  {meas => "socbms",           topic => "EV_MQTT_SOCBMS",       mult => "EV_MQTT_SOCBMS_MULTIPLIER" },
  {meas => "soh",              topic => "EV_MQTT_SOH",          mult => "EV_MQTT_SOH_MULTIPLIER" },
  {meas => "remain",           topic => "EV_MQTT_REMAIN",       mult => "EV_MQTT_REMAIN_MULTIPLIER" },
  {meas => "power",            topic => "EV_MQTT_POWER",        mult => "EV_MQTT_POWER_MULTIPLIER" },
  {meas => "voltage",          topic => "EV_MQTT_VOLTAGE",      mult => "EV_MQTT_VOLTAGE_MULTIPLIER" },
  {meas => "current",          topic => "EV_MQTT_CURRENT",      mult => "EV_MQTT_CURRENT_MULTIPLIER" },
  {meas => "energy",           topic => "EV_MQTT_ENERGY",       mult => "EV_MQTT_ENERGY_MULTIPLIER" },
  {meas => "charge",           topic => "EV_MQTT_CHARGE",       mult => "EV_MQTT_CHARGE_MULTIPLIER" },
  {meas => "regen",            topic => "EV_MQTT_REGEN",        mult => "EV_MQTT_REGEN_MULTIPLIER" },
  {meas => "recharged_ac",     topic => "EV_MQTT_RECHARGED_AC", mult => "EV_MQTT_RECHARGED_AC_MULTIPLIER" },
  {meas => "recharged_dc",     topic => "EV_MQTT_RECHARGED_DC", mult => "EV_MQTT_RECHARGED_DC_MULTIPLIER" },
  {meas => "cellvmin",         topic => "EV_MQTT_CELLVMIN",     mult => "EV_MQTT_CELLVMIN_MULTIPLIER" },
  {meas => "cellvmax",         topic => "EV_MQTT_CELLVMAX",     mult => "EV_MQTT_CELLVMAX_MULTIPLIER" },
  {meas => "cellvavg",         topic => "EV_MQTT_CELLVAVG",     mult => "EV_MQTT_CELLVAVG_MULTIPLIER" },
  {meas => "cellvdiff",        topic => "EV_MQTT_CELLVDIFF",    mult => "EV_MQTT_CELLVDIFF_MULTIPLIER" },
  {meas => "ac_power",         topic => "EV_MQTT_AC_POWER",     mult => "EV_MQTT_AC_POWER_MULTIPLIER" },
  {meas => "ac_voltage",       topic => "EV_MQTT_AC_VOLTAGE",   mult => "EV_MQTT_AC_VOLTAGE_MULTIPLIER" },
  {meas => "ac_current",       topic => "EV_MQTT_AC_CURRENT",   mult => "EV_MQTT_AC_CURRENT_MULTIPLIER" },
  {meas => "battemp",          topic => "EV_MQTT_BATTEMP",      mult => "EV_MQTT_BATTEMP_MULTIPLIER" },
  {meas => "battmin",          topic => "EV_MQTT_BATTMIN",      mult => "EV_MQTT_BATTMIN_MULTIPLIER" },
  {meas => "battmax",          topic => "EV_MQTT_BATTMAX",      mult => "EV_MQTT_BATTMAX_MULTIPLIER" },
  {meas => "outdoor",          topic => "EV_MQTT_OUTDOOR",      mult => "EV_MQTT_OUTDOOR_MULTIPLIER" },
  {meas => "indoor",           topic => "EV_MQTT_INDOOR",       mult => "EV_MQTT_INDOOR_MULTIPLIER" },
  {meas => "charging",         topic => "EV_MQTT_CHARGING",     mult => "" },
);


@GRID_MAP = (
  {meas => "energy_import",    topic => "GRID_MQTT_IMPORT",   mult => "GRID_MQTT_IMPORT_MULTIPLIER" },
  {meas => "energy_export",    topic => "GRID_MQTT_EXPORT",   mult => "GRID_MQTT_EXPORT_MULTIPLIER" },
  {meas => "energy_home",      topic => "HOME_MQTT_ENERGY",   mult => "HOME_MQTT_ENERGY_MULTIPLIER" },
);

@WALLBOX_RESULT = (
  {command=>"wallbox_set_mode", success=>"WALLBOX_MQTT_SET_MODE_RESULT_SUCCESS", error=>"WALLBOX_MQTT_SET_MODE_RESULT_ERROR",ecode=>201},
  {command=>"wallbox_set_limit",success=>"WALLBOX_MQTT_SET_LIMIT_RESULT_SUCCESS",error=>"WALLBOX_MQTT_SET_LIMIT_RESULT_ERROR",ecode=>202},
);

%HA_DISCOVERY = (
  wallbox => [
  {
    platform => "sensor",
    name => 'Power',
    unique_id => '{device_id}_power',
    device_class => 'power',
    state_class => 'measurement',
    unit_of_measurement => 'W',
    state_topic => '{topic_prefix}/{wallbox_base}/{device_id}/session',
    value_template => '{{ value_json.power | default(0) }}',
    icon => 'mdi:lightning-bolt',
  },
  
  {
    platform => "sensor",
    name => 'Power Average',
    unique_id => '{device_id}_power_average',
    device_class => 'power',
    state_class => 'measurement',
    unit_of_measurement => 'W',
    state_topic => '{topic_prefix}/{wallbox_base}/{device_id}/session',
    value_template => '{{ value_json.power_session_average | default(0) }}',
    icon => 'mdi:lightning-bolt-outline',
  },
  
  {
    platform => "sensor",
    name => 'Energy',
    unique_id => '{device_id}_energy',
    device_class => 'energy',
    state_class => 'total_increasing',
    unit_of_measurement => 'kWh',
    state_topic => '{topic_prefix}/{wallbox_base}/{device_id}/session',
    value_template => '{{ value_json.energy_session | default(0) }}',
    icon => 'mdi:battery-charging-high',
  },

  {
    platform => "sensor",
    name => 'Energy Lifetime',
    unique_id => '{device_id}_energy_timeout',
    device_class => 'energy',
    state_class => 'total_increasing',
    unit_of_measurement => 'kWh',
    state_topic => '{topic_prefix}/{wallbox_base}/{device_id}/limit',
    value_template => '{{ value_json.energy_global }}',
    suggested_display_precision => 0,
    icon => 'mdi:battery-clock',
  },

  {
    platform => "sensor",
    name => 'Current',
    unique_id => '{device_id}_current',
    device_class => 'current',
    state_class => 'measurement',
    unit_of_measurement => 'A',
    suggested_display_precision => 2,
    state_topic => '{topic_prefix}/{wallbox_base}/{device_id}/session',
    value_template => '{{ value_json.current | default(0) }}',
    icon => 'mdi:current-ac',
  },
  
  {
    platform => "sensor",
    name => 'Current Average',
    unique_id => '{device_id}_current_average',
    device_class => 'current',
    state_class => 'measurement',
    unit_of_measurement => 'A',
    suggested_display_precision => 2,
    state_topic => '{topic_prefix}/{wallbox_base}/{device_id}/session',
    value_template => '{{ value_json.current_session_average | default(0) }}',
    icon => 'mdi:current-ac',
  },

  {
    platform => "sensor",
    name => 'Voltage',
    unique_id => '{device_id}_voltage',
    device_class => 'voltage',
    state_class => 'measurement',
    unit_of_measurement => 'V',
    suggested_display_precision => 1,
    state_topic => '{topic_prefix}/{wallbox_base}/{device_id}/session',
    value_template => '{{ value_json.voltage | default(230) }}',
    icon => 'mdi:sine-wave',
  },

  {
    platform => "sensor",
    name => 'Temperature',
    unique_id => '{device_id}_temperature',
    device_class => 'temperature',
    unit_of_measurement => '°C',
    state_class => 'measurement',
    suggested_display_precision => 1,
    state_topic => '{topic_prefix}/{wallbox_base}/{device_id}/session',
    value_template => '{{ value_json.temperature }}',
  },
  
  
  {
    platform => "sensor",
    name => 'Offered Current',
    unique_id => '{device_id}_offered_current',
    device_class => 'current',
    state_class => 'measurement',
    unit_of_measurement => 'A',
    suggested_display_precision => 2,
    state_topic => '{topic_prefix}/{wallbox_base}/{device_id}/session',
    value_template => '{{ value_json.offered | default(0) }}',
    icon => 'mdi:current-ac',
  },
  
  {
    platform => "sensor",
    name => 'Offered Current Average',
    unique_id => '{device_id}_offered_current_average',
    device_class => 'current',
    state_class => 'measurement',
    unit_of_measurement => 'A',
    suggested_display_precision => 2,
    state_topic => '{topic_prefix}/{wallbox_base}/{device_id}/session',
    value_template => '{{ value_json.offered_session_average | default(0) }}',
    icon => 'mdi:current-ac',
  },
  
  {
    platform => "sensor",
    name => 'Time elapsed',
    unique_id => '{device_id}_elapsed',
    device_class => 'duration',
    state_class => 'measurement',
    unit_of_measurement => 's',
    suggested_display_precision => 0,
    state_topic => '{topic_prefix}/{wallbox_base}/{device_id}/session',
    value_template => '{{ value_json.elapsed_session | default(0) }}',
    icon => 'mdi:timer-outline',
  },
  
  {
    platform => "sensor",
    name => 'Time elapsed human',
    unique_id => '{device_id}_elapsed_human',
    state_topic => '{topic_prefix}/{wallbox_base}/{device_id}/session',
    value_template => '{{ value_json.elapsed_session_human | default(0) }}',
    icon => 'mdi:timer-star-outline',
  },
  
  {
    platform => "sensor",
    name => 'Status',
    unique_id => '{device_id}_status',
    state_topic => '{topic_prefix}/{wallbox_base}/{device_id}/status',
    value_template => '{{ value_json.status }}',
    icon => 'mdi:ev-station',
  },
  
  {
    platform => "binary_sensor",
    name => 'Connected',
    unique_id => '{device_id}_connected',
    device_class => 'plug',
    state_topic => '{topic_prefix}/{wallbox_base}/{device_id}/status',
    #value_template => '{{ "ON" if value_json.status in ["Charging", "SuspendedEV", "SuspendedEVSE"] else "OFF" }}',
    value_template => '{{ value_json.connected }}',
    payload_on => 1,
    payload_off => 0,
    icon => 'mdi:ev-plug-type2',
  },
  
  {
    platform => "binary_sensor",
    name => 'Charging',
    unique_id => '{device_id}_charging',
    device_class => 'battery_charging',
    state_topic => '{topic_prefix}/{wallbox_base}/{device_id}/charging',
    #value_template => '{{ "ON" if value_json.status == "Charging" else "OFF" }}',
    value_template => '{{ value_json.charging }}',
    payload_on => 1,
    payload_off => 0,
    icon => 'mdi:battery-charging',
  },

  {
    platform => "switch",
    name => 'Autostart',
    unique_id => '{device_id}_autostart',
    state_topic => '{topic_prefix}/{config_general}/AUTOSTART',
    command_topic => '{topic_prefix}/{config_general}/AUTOSTART',
    payload_on => 1,
    payload_off => 0,
    state_on => 1,
    state_off => 0,
    qos => 0,
    retain => false,
    icon => 'mdi:refresh-auto',
  },

  {
    platform => "number",
    name => 'Minimum charging current',
    entity_category => 'config',
    unique_id => '{device_id}_charging_minpower',
    state_topic => '{topic_prefix}/{config_profile}/_default',
    command_topic => '{topic_prefix}/{config_profile}/_default',
    value_template => '{{ value_json.CHARGING_MINPOWER | default(6) }}',
    command_template => '{"CHARGING_MINPOWER": {{ value }}}',
    min => 6,
    max => 32,
    step => 1,
    unit_of_measurement => 'A',
    device_class => 'current',
    mode => 'slider',
    icon => 'mdi:battery-10',
  },

  {
    platform => "switch",
    name => 'Add wallbox power to meter',
    entity_category => 'config',
    unique_id => '{device_id}_addwallboxpower',
    state_topic => '{topic_prefix}/{config_general}/ADD_WALLBOX_POWER_TO_METER',
    command_topic => '{topic_prefix}/{config_general}/ADD_WALLBOX_POWER_TO_METER',
    payload_on => 1,
    payload_off => 0,
    state_on => 1,
    state_off => 0,
    icon => 'mdi:battery-plus',
  },

  {
    platform => "switch",
    name => 'Use STOP as SUSPEND',
    entity_category => 'config',
    unique_id => '{device_id}_stopassuspend',
    state_topic => '{topic_prefix}/{config_general}/USE_STOP_AS_SUSPEND',
    command_topic => '{topic_prefix}/{config_general}/USE_STOP_AS_SUSPEND',
    payload_on => 1,
    payload_off => 0,
    state_on => 1,
    state_off => 0,
    icon => 'mdi:pause-box',
  },

  {
    platform => "switch",
    name => 'Arera 6.05/7.33 kW F3',
    entity_category => 'config',
    unique_id => '{device_id}_arera6k',
    state_topic => '{topic_prefix}/{config_grid}/arera6kw',
    command_topic => '{topic_prefix}/{config_grid}/arera6kw',
    value_template => '{{ value_json.ENABLE }}',
    command_template => '{"ENABLE": {{ value }}}',
    payload_on => 1,
    payload_off => 0,
    state_on => 1,
    state_off => 0,
    qos => 0,
    retain => false,
    icon => 'mdi:transmission-tower-import',
  },


  {
    platform => "sensor",
    name => 'Active profile',
    unique_id => '{device_id}_active_profile',
    state_topic => '{topic_prefix}/{wallbox_base}/{device_id}/limit',
    value_template => '{{ value_json.active_profile }}',
    icon => 'mdi:wrench-clock',
  },
  
  {
    platform => "sensor",
    name => 'Active (RFID) Tag',
    unique_id => '{device_id}_active_idtag',
    state_topic => '{topic_prefix}/{wallbox_base}/{device_id}/limit',
    value_template => '{{ value_json.active_idtag }}',
    icon => 'mdi:id-card',
  },

  {
    platform => "sensor",
    name => 'Transaction ID',
    unique_id => '{device_id}_transaction_id',
    state_topic => '{topic_prefix}/{wallbox_base}/{device_id}/session',
    value_template => '{{ value_json.transaction }}',
    icon => 'mdi:briefcase-arrow-left-right',
  },
  
  {
    platform => "select",
    name => 'START Active (ID)Tag',
    device_class => "enum",
    unique_id => '{device_id}_charging_profile',
    command_topic => '{topic_prefix}/{wallbox_base}/{device_id}/cmd/set_tag',
    command_template => '{"command":"set_tag","idTag": "{{ value }}" }',
    options => ['by RFID', 'by Current Limit', 'DYNAMIC', 'FIXED', 'POWER', 'ECO', 'SOLAR', 'SUSPEND'],
    state_topic => '{topic_prefix}/{wallbox_base}/{device_id}/limit',
    value_template => '{{ value_json.mqtt_tag }}',
    icon => 'mdi:tag-multiple',
  },

  {
    platform => "button",
    name => 'START Charging',
    unique_id => '{device_id}_charging_start',
    command_topic => '{topic_prefix}/{wallbox_base}/{device_id}/cmd/start',
    payload_press => '{"command": "start", "force": 1}',
    icon => 'mdi:play-circle',
  },

  {
    platform => "button",
    name => 'SUSPEND Charging',
    unique_id => '{device_id}_charging_suspend',
    command_topic => '{topic_prefix}/{wallbox_base}/{device_id}/cmd/start',
    payload_press => '{"command": "start", "idTag": "SUSPEND"}',
    icon => 'mdi:pause-circle',
  },

  {
    platform => "button",
    name => 'STOP Charging',
    unique_id => '{device_id}_charging_stop',
    command_topic => '{topic_prefix}/{wallbox_base}/{device_id}/cmd/stop',
    payload_press => '{"command": "stop", "force": 1}',
    icon => 'mdi:stop-circle',
  },
  
  {
    platform => "button",
    name => 'UNLOCK connector',
    unique_id => '{device_id}_unlock',
    command_topic => '{topic_prefix}/{wallbox_base}/{device_id}/cmd/unlock',
    payload_press => '{"command": "unlock", "force": 1}',
    icon => 'mdi:lock-open-remove',
  },
  
  {
    platform => "button",
    name => 'RESET Device (hard)',
    unique_id => '{device_id}_reset_hard',
    command_topic => '{topic_prefix}/{wallbox_base}/{device_id}/cmd/reset',
    payload_press => '{"command": "reset", "type": "Hard", "force": 1}',
    icon => 'mdi:restart-alert',
  },
  
  {
    platform => "button",
    name => 'RESET Device (soft)',
    unique_id => '{device_id}_reset_soft',
    command_topic => '{topic_prefix}/{wallbox_base}/{device_id}/cmd/reset',
    payload_press => '{"command": "reset", "type": "Soft", "force": 1}',
    icon => 'mdi:restart',
  },
  
  {
    platform => "number",
    name => 'START Current Limit',
    unique_id => '{device_id}_current_limit',
    command_topic => '{topic_prefix}/{wallbox_base}/{device_id}/cmd/set_limit',
    state_topic => '{topic_prefix}/{wallbox_base}/{device_id}/limit',
    value_template => '{{ value_json.mqtt_limit | default(-1) }}',
    min => -1,
    max => 32,
    step => 1,
    unit_of_measurement => 'A',
    device_class => 'current',
    mode => 'slider',
    command_template => '{"command":"set_limit","limit": {{ value }}}',
    icon => 'mdi:generator-stationary',
  },

  {
    platform => "number",
    name => 'FIXED current (HA-FIXED)',
    unique_id => '{device_id}_start_fixed_value',
    command_topic => '{topic_prefix}/{config_profile}/HA-FIXED',
    state_topic => '{topic_prefix}/{config_profile}/HA-FIXED',
    value_template => '{{ value_json.FIXED }}',
    min => 6,
    max => 32,
    step => 1,
    unit_of_measurement => 'A',
    device_class => 'current',
    mode => 'slider',
    command_template => '{"ENABLE": "FIXED", "FIXED": {{ value }}}',
    icon => 'mdi:car-battery',
  },

  {
    platform => "number",
    name => 'FIXED power (HA-POWER)',
    unique_id => '{device_id}_start_power_value',
    command_topic => '{topic_prefix}/{config_profile}/HA-POWER',
    state_topic => '{topic_prefix}/{config_profile}/HA-POWER',
    value_template => '{{ value_json.FIXED | replace("W","") | int }} ',
    min => 1400,
    max => 22000,
    step => 100,
    unit_of_measurement => 'W',
    device_class => 'power',
    mode => 'slider',
    command_template => '{"ENABLE": "POWER", "FIXED": "{{ value }}W" }',
    icon => 'mdi:power-plug-battery',
  },

  {
    platform => "number",
    name => 'Max Session Energy',
    min => 0,
    max => 200,
    step => 0.1,
    unique_id => '{device_id}_max_energy',
    command_topic => '{topic_prefix}/{wallbox_base}/{device_id}/cmd/max_energy',
    state_topic => '{topic_prefix}/{wallbox_base}/{device_id}/limit',
    value_template => '{{ value_json.mqtt_max_energy | default(0) }}',
    unit_of_measurement => 'kWh',
    device_class => 'energy',
    mode => 'slider',
    command_template => '{"command":"max_energy","energy": {{ value }}}',
    icon => 'mdi:battery-arrow-up-outline',
  },
  ],

  meter => [
  {
    platform => "sensor",
    name => 'Power',
    unique_id => '{device_id}_power',
    device_class => 'power',
    state_class => 'measurement',
    unit_of_measurement => 'W',
    state_topic => '{topic_prefix}/{meter_base}/meter',
    value_template => '{{ value_json.power }}',
    icon => 'mdi:home-lightning-bolt'
  },

  {
    platform => "sensor",
    name => 'Power Weighted Moving Average',
    unique_id => '{device_id}_power_average',
    device_class => 'power',
    state_class => 'measurement',
    unit_of_measurement => 'W',
    state_topic => '{topic_prefix}/{meter_base}/meter',
    value_template => '{{ value_json.power_average }}',
    icon => 'mdi:home-lightning-bolt-outline'
  },
  
  
  {
    platform => "sensor",
    name => 'Current',
    unique_id => '{device_id}_current',
    device_class => 'current',
    state_class => 'measurement',
    unit_of_measurement => 'A',
    suggested_display_precision => 2,
    state_topic => '{topic_prefix}/{meter_base}/meter',
    value_template => '{{ value_json.current }}',
    icon => 'mdi:current-ac'
  },
  
  {
    platform => "sensor",
    name => 'Voltage',
    unique_id => '{device_id}_voltage',
    device_class => 'voltage',
    state_class => 'measurement',
    unit_of_measurement => 'V',
    suggested_display_precision => 1,
    state_topic => '{topic_prefix}/{meter_base}/meter',
    value_template => '{{ value_json.voltage | default(230) }}',
    icon => 'mdi:sine-wave'
  },
  ], 

  ev => [
  {
    platform => "sensor",
    name => 'SOC',
    map => 'soc',
    unique_id => '{device_id}_aasoc_1soc',
    state_class => 'measurement',
    unit_of_measurement => '%',
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.soc }}',
    suggested_display_precision => 1,
    icon => 'mdi:battery-60',
  },

  {
    platform => "sensor",
    name => 'Charging efficiency',
    map => 'power',
    unique_id => '{device_id}_charging_efficiency',
    state_class => 'measurement',
    unit_of_measurement => '%',
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.efficiency }}',
    suggested_display_precision => 1,
    icon => 'mdi:water-percent',
  },

  {
    platform => "sensor",
    name => 'SOC BMS',
    map => 'socbms',
    unique_id => '{device_id}_aasoc_2bms',
    state_class => 'measurement',
    unit_of_measurement => '%',
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.socbms }}',
    suggested_display_precision => 1,
    icon => 'mdi:battery-arrow-up',
  },

  {
    platform => "sensor",
    name => 'Battery Power',
    map => 'power',
    unique_id => '{device_id}_battery_1power',
    device_class => 'power',
    state_class => 'measurement',
    unit_of_measurement => 'W',
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.power }}',
    icon => 'mdi:lightning-bolt',
  },

  {
    platform => "sensor",
    name => 'Battery Voltage',
    map => 'voltage',
    unique_id => '{device_id}_battery_2voltage',
    device_class => 'voltage',
    state_class => 'measurement',
    unit_of_measurement => 'V',
    suggested_display_precision => 1,
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.voltage }}',
    icon => 'mdi:flash-triangle',
  },

  {
    platform => "sensor",
    name => 'Battery Current',
    map => 'current',
    unique_id => '{device_id}_battery_3current',
    device_class => 'current',
    state_class => 'measurement',
    unit_of_measurement => 'A',
    suggested_display_precision => 2,
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.current }}',
    icon => 'mdi:current-dc',
  },

  {
    platform => "sensor",
    name => 'AC Power',
    map => 'ac_power',
    unique_id => '{device_id}_ac_1power',
    device_class => 'power',
    state_class => 'measurement',
    unit_of_measurement => 'W',
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.ac_power }}',
    icon => 'mdi:power-socket-eu',
  },

  {
    platform => "sensor",
    name => 'AC Voltage',
    map => 'ac_voltage',
    unique_id => '{device_id}_ac_2voltage',
    device_class => 'voltage',
    state_class => 'measurement',
    unit_of_measurement => 'V',
    suggested_display_precision => 1,
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.ac_voltage }}',
    icon => 'mdi:sine-wave',
  },

  {
    platform => "sensor",
    name => 'AC Current',
    map => 'ac_current',
    unique_id => '{device_id}_ac_3current',
    device_class => 'current',
    state_class => 'measurement',
    unit_of_measurement => 'A',
    suggested_display_precision => 2,
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.ac_current }}',
    icon => 'mdi:current-ac',
  },
  
  {
    platform => "sensor",
    name => 'Remain Energy',
    map => 'remain',
    unique_id => '{device_id}_energy_remain',
    device_class => 'energy',
    unit_of_measurement => 'kWh',
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.remain }}',
    icon => 'mdi:battery-charging-high',
  },

  {
    platform => "sensor",
    name => 'SOH (State Of Health)',
    map => 'soh',
    unique_id => '{device_id}_energy_soh',
    state_class => 'measurement',
    unit_of_measurement => '%',
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.soh }}',
    suggested_display_precision => 1,
    icon => 'mdi:bottle-tonic-plus-outline',
  },

  {
    platform => "sensor",
    name => 'Cumulative Energy Charged',
    map => 'charge',
    unique_id => '{device_id}_energy_charge',
    device_class => 'energy',
    state_class => 'total_increasing',
    unit_of_measurement => 'kWh',
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.charge }}',
    icon => 'mdi:battery-arrow-up-outline',
  },

  {
    platform => "sensor",
    name => 'Cumulative Energy Discharged',
    map => 'energy',
    unique_id => '{device_id}_energy_discharge',
    device_class => 'energy',
    state_class => 'total_increasing',
    unit_of_measurement => 'kWh',
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.energy }}',
    icon => 'mdi:battery-arrow-down-outline',
  },

  {
    platform => "sensor",
    name => 'Energy Regenerated',
    map => 'regen',
    unique_id => '{device_id}_energy_regen',
    device_class => 'energy',
    state_class => 'total_increasing',
    unit_of_measurement => 'kWh',
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.regen }}',
    icon => 'mdi:battery-sync',
  },

  {
    platform => "sensor",
    name => 'Energy AC Recharged',
    map => 'recharged_ac',
    unique_id => '{device_id}_energy_recharged_ac',
    device_class => 'energy',
    state_class => 'total_increasing',
    unit_of_measurement => 'kWh',
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.recharged_ac }}',
    icon => 'mdi:home-battery',
  },

  {
    platform => "sensor",
    name => 'Energy DC Recharged',
    map => 'recharged_dc',
    unique_id => '{device_id}_energy_recharged_dc',
    device_class => 'energy',
    state_class => 'total_increasing',
    unit_of_measurement => 'kWh',
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.recharged_dc }}',
    icon => 'mdi:car-battery',
  },

  {
    platform => "sensor",
    name => 'Cell Average Voltage',
    map => 'cellvavg',
    unique_id => '{device_id}_cell_1avg',
    device_class => 'voltage',
    state_class => 'measurement',
    unit_of_measurement => 'V',
    suggested_display_precision => 3,
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.cellvavg }}',
    icon => 'mdi:toy-brick',
  },

  {
    platform => "sensor",
    name => 'Cell Minimum Voltage',
    map => 'cellvmin',
    unique_id => '{device_id}_cell_3min',
    device_class => 'voltage',
    state_class => 'measurement',
    unit_of_measurement => 'V',
    suggested_display_precision => 3,
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.cellvmin }}',
    icon => 'mdi:toy-brick-minus-outline',
  },

  {
    platform => "sensor",
    name => 'Cell Maximum Voltage',
    map => 'cellvmax',
    unique_id => '{device_id}_cell_2max',
    device_class => 'voltage',
    state_class => 'measurement',
    unit_of_measurement => 'V',
    suggested_display_precision => 3,
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.cellvmax }}',
    icon => 'mdi:toy-brick-plus-outline',
  },

  {
    platform => "sensor",
    name => 'Cell Difference',
    map => 'cellvdiff',
    unique_id => '{device_id}_cell_4diff',
    device_class => 'voltage',
    state_class => 'measurement',
    unit_of_measurement => 'V',
    suggested_display_precision => 3,
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.cellvdiff }}',
    icon => 'mdi:arrow-split-horizontal',
  },

  {
    platform => "sensor",
    name => 'Battery Temperature',
    map => 'battemp',
    unique_id => '{device_id}_battery_4temperature',
    device_class => 'temperature',
    unit_of_measurement => '°C',
    state_class => 'measurement',
    suggested_display_precision => 1,
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.battemp }}',
  },

  {
    platform => "sensor",
    name => 'Battery Minimum Temperature',
    map => 'battmin',
    unique_id => '{device_id}_battery_6mintemp',
    device_class => 'temperature',
    unit_of_measurement => '°C',
    state_class => 'measurement',
    suggested_display_precision => 1,
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.battmin }}',
    icon => 'mdi:thermometer-minus',
  },

  {
    platform => "sensor",
    name => 'Battery Maximum Temperature',
    map => 'battmax',
    unique_id => '{device_id}_battery_5maxtemp',
    device_class => 'temperature',
    unit_of_measurement => '°C',
    state_class => 'measurement',
    suggested_display_precision => 1,
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.battmax }}',
    icon => 'mdi:thermometer-plus',
  },

  {
    platform => "sensor",
    name => 'Outdoor Temperature',
    map => 'outdoor',
    unique_id => '{device_id}_temp_outdoor',
    device_class => 'temperature',
    unit_of_measurement => '°C',
    state_class => 'measurement',
    suggested_display_precision => 1,
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.outdoor }}',
    icon => 'mdi:sun-thermometer',
  },

  {
    platform => "sensor",
    name => 'Indoor Temperature',
    map => 'indoor',
    unique_id => '{device_id}_temp_indoor',
    device_class => 'temperature',
    unit_of_measurement => '°C',
    state_class => 'measurement',
    suggested_display_precision => 1,
    state_topic => '{topic_prefix}/{ev_base}/{device_id}/status',
    value_template => '{{ value_json.indoor }}',
    icon => 'mdi:car-electric',
  },
  
  {
    platform => "number",
    name => 'SOC Limit',
    min => 0,
    max => 100,
    step => 1,
    unique_id => '{device_id}_aasoc_0max',
    command_topic => '{topic_prefix}/{config_ev}/{device_id}',
    state_topic => '{topic_prefix}/{config_ev}/{device_id}',
    value_template => '{{ value_json.EV_SOC_LIMIT | int }}',
    unit_of_measurement => '%',
    mode => 'slider',
    command_template => '{"EV_SOC_LIMIT": {{ value }}}',
    icon => 'mdi:battery-medium',
  },
  ],
);

sub MQTT_Power {
  my($power)=@_;
  if($MQTT_POWER_UNIT eq "kW") {
    $power*=0.001;
  }
  return($power);
}

sub MQTT_Energy {
  my($energy)=@_;
  if($MQTT_ENERGY_UNIT eq "kWh") {
    $energy*=0.001;
  }
  return($energy);
}

sub MQTT_Config {
  my ($topic, $message) = @_;
  if($mqtt_config>0) {
    $mqtt_config{$topic}=$message;
    return(1);
  }
  return(0);
}

# When reloading library, old callback still called, so simply make a sub call:

sub _config_callback {
  my ($topic, $message) = @_;
  my ($checktopic,$param,$section,$payload);
  $config_counter++;
  if(MQTT_Config($topic,$message)) { return; }
  if($mqtt_config_retain{$topic} eq $message) {
    if(!($topic=~m|/_active|)) {
      if($mqtt_config_once{$topic}>0) {
	$mqtt_config_once{$topic}--;
        verbose(11,"[$mqtt_config] As expected, received notification of topic '$topic' with the same content as published ($message)\n");
      }
      else {
        verbose(9,"[$mqtt_config] Warning: received notification of topic '$topic' with the same content as published ($message)\n");
      }
    }
    return;
  }
  verbose(11,"[$mqtt_config] Config $topic => $message\n");
  $checktopic=MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,MQTT_ConfigGeneralBase());
  $section=substr($topic,rindex($topic,"/")+1);
  if($message=~m/^\s*[\[\{]/s) {
    # JSON format, decode it
    eval {
      $payload=decode_json($message);
    };
    if(!defined($payload)) {
      verbose(5,"Error decoding JSON message '$message': $@\n");
      return;
    }
  }
  else {
    $payload=$message;
    if($message eq "null") { $payload=undef; }
  }
  if(substr($topic,0,length($checktopic)) eq $checktopic) {
    # General update, $section is the param
    UpdateIni("",{$section=>$payload});
  }
  else {
    # Real "section"
    if($section eq "_active") {
      verbose(5,"Could not update _active section\n");
      return;
    }
    if(ref($payload) ne "HASH") {
      verbose(5,"Only JSON HASH accepted to update section $section\n");
      return;
    }
    if($section eq "_default") {
      $section="";
    }
    UpdateIni($section,$payload);
  }
}

sub config_callback {
  _config_callback(@_);
}

sub FieldToPerl {
  my $field=shift;
  $field=~s/\.([a-zA-Z0-9_]+)/{$1}/g;
  return($field);
}

sub SplitTopicField {
  my($check)=@_;
  my($sq,$i,$field,$r);
  $sq=index($check,"[");
  $i=index($check,".");
  if($sq>0 && $sq<$i) {
    $i=$sq;
  }
  if($i>0) {
    $r=rindex($check,"/");
    if($i>$r) {
      $field=substr($check,$i);
      $check=substr($check,0,$i);
    }
  }
  return(($check,$field));
}

sub CheckTopic {
  my($topic,$check,$message,$multiplier)=@_;
  my($field,$i,$sq,$r,$value,$json,$fperl);
  # Split $check in topic and subfield[s]:
  ($check,$field)=SplitTopicField($check);
  if($topic ne $check) { return(undef); }
  if(!defined($multiplier)) { $multiplier=1; }
  if(length($field)==0) {
    # Simple value
    return($message*$multiplier);
  }
  # JSON format
  eval {
    $json = decode_json($message);
  };
  if(!defined($json)) {
    verbose(12,"ERROR decoding JSON meter message ($message): $@\n");
    return(undef);
  }
  $fperl=FieldToPerl($field);
  $value=eval("\$json->$fperl");
  if(!defined($value)) { return(undef); }
  return($value*$multiplier);
}


sub _meter_callback {
  my ($topic, $message) = @_;
  my ($value,$meas,$mult,$check,$i);
  verbose(15,"METER $topic => $message\n");
  for($i=0;$i<=$#METER_MAP;$i++) {
    $check=${$METER_MAP[$i]{topic}};
    if(length($check)>0) {
      $meas=$METER_MAP[$i]{meas};
      $mult=${$METER_MAP[$i]{mult}};
      if(defined($value=CheckTopic($topic,MQTT_ComposeTopic($METER_MQTT_PREFIX,$check),$message,$mult))) {
        verbose(15,"VALUE $meas ($check) => $value\n");
	$meter{$meas}=$value;
	$meter_counter++;
      }
    }
  }
}

sub meter_callback {
  _meter_callback(@_);
}

sub _pv_callback {
  my ($topic, $message) = @_;
  my ($value,$meas,$mult,$check,$i);
  verbose(15,"PV $topic => $message\n");
  for($i=0;$i<=$#PV_MAP;$i++) {
    $check=${$PV_MAP[$i]{topic}};
    if(length($check)>0) {
      $meas=$PV_MAP[$i]{meas};
      $mult=${$PV_MAP[$i]{mult}};
      if(defined($value=CheckTopic($topic,MQTT_ComposeTopic($PV_MQTT_PREFIX,$check),$message,$mult))) {
        verbose(15,"PV VALUE $meas ($check) => $value\n");
	$pv{$meas}=$value;
	$pv_counter++;
      }
    }
  }
}

sub pv_callback {
  _pv_callback(@_);
}

sub _ev_callback {
  my ($topic, $message) = @_;
  my ($value,$meas,$mult,$check,$i,$e);
  verbose(15,"EV $topic => $message\n");
  for($e=0;$e<=$#ev;$e++) {
    for($i=0;$i<=$#EV_MAP;$i++) {
      $check=EvParam($EV_MAP[$i]{topic},$ev[$e]);
      if(length($check)>0) {
	$meas=$EV_MAP[$i]{meas};
	$mult=EvParam($EV_MAP[$i]{mult},$ev[$e]);
	if(defined($value=CheckTopic($topic,MQTT_ComposeTopic(EvParam("EV_MQTT_PREFIX",$ev[$e]),$check),$message,$mult))) {
	  verbose(15,"EV VALUE $meas ($check) => $value\n");
	  $evmeas[$e]{$meas}=$value;
	  $ev_counter++;
	  $ev_counter[$e]++;
	}
      }
    }
  }
}

sub ev_callback {
  _ev_callback(@_);
}

sub _grid_callback {
  my ($topic, $message) = @_;
  my ($value,$meas,$mult,$check,$i);
  verbose(15,"GRID $topic => $message\n");
  for($i=0;$i<=$#GRID_MAP;$i++) {
    $check=${$GRID_MAP[$i]{topic}};
    if(length($check)>0) {
      $meas=$GRID_MAP[$i]{meas};
      $mult=${$GRID_MAP[$i]{mult}};
      if(defined($value=CheckTopic($topic,MQTT_ComposeTopic($PV_MQTT_PREFIX,$check),$message,$mult))) {
        verbose(15,"GRID VALUE $meas ($check) => $value\n");
	$grid{$meas}=$value;
	$grid_counter++;
      }
    }
  }
}

sub grid_callback {
  _grid_callback(@_);
}

sub GetEvIdx
{
  my($param)=@_;
  my($idx,$i);
  if(!defined($idx=$EV_MAP{$param})) {
    # Create EV_MAP cache:
    for($i=0;$i<=$#EV_MAP;$i++) {
      $EV_MAP{$EV_MAP[$i]{$topic}}=$i;
    }
    $idx=$EV_MAP{$param};
  }
  return($idx);
}

sub GetEvMeas
{
  my ($param,$e)=@_;
  my ($i,$idx);
  if(length(EvParam($param,$e))==0) {
    return(undef);
  }
  if(defined($idx=GetEvIdx($param))) {
    return($evmeas[$e]{$EV_MAP[$idx]{meas}});
  }
  return(undef);
}

sub SetTriggerMQTT {
  ($connector,$cmd)=@_;
  $mqtt_trigger{now}=time();
  $mqtt_trigger{connector}=$connector;
  $mqtt_trigger{command}=$cmd;
}

sub CheckTriggerMQTT {
  my ($payload)=@_;
  my ($err);
  my $maxtimeout=$QUEUE_DELAY_TIME*2;
  my $maxtimeout2=$WAITDATA_TIMEOUT*$QUEUE_WAIT*2;
  if($maxtimeout2>$maxtimeout) { $maxtimeout=$maxtimeout2; }
  verbose(19,"($maxtimeout) Trigger check $mqtt_trigger{now}...".(time()-$mqtt_trigger{now})."\n");
  if((time()-$mqtt_trigger{now})<=$maxtimeout) {
    if(!defined($mqtt)) { return(undef); }
    if($payload->{status}=~m/Accepted|Unlock/i) { $err=0; }
    else { $err=2; }
    wallbox_result($mqtt_trigger{connector},$mqtt_trigger{command},$payload->{status},$err,"");
    #undef($mqtt_trigger{now});
    return(1);
  }
  return(0);
}

sub wallbox_result {
  my ($connector,$cmdfunc,$status,$errcode,$errstr)=@_;
  my ($topic,%payload,$s,$now);
  $now=time();
  $s=$smart{$wallbox};
  $topic=MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,$MQTT_WALLBOX_BASE,Base($s->{WALLBOX_MQTT_BASE},$wallbox),$s->{"WALLBOX_MQTT_CONNECTOR${connector}_BASE"},$s->{WALLBOX_MQTT_CMD_BASE});
  $payload{connector}=$connector;
  $payload{command}=$cmdfunc;
  $payload{status}=$status;
  $payload{error}=$errcode;
  $payload{info}=$errstr;
  $payload{timestamp}=Zulu($now);
  $payload{timestamp_unix}=$now;
  MQTT_PublishValues($topic,"result",\%payload);
}

sub wallbox_cmd_start {
  my ($connector,$payload)=@_;
  my ($newOffered,$err,$info);
  if($payload->{restore}) {
    verbose(10,"Received MQTT restore request ($currTransaction)\n");
    $MQTT_STARTED=0;
    $MQTT_TAG="";
    wallbox_result($connector,$payload->{command},"Accepted",0,"Profile/card handling restore");
    MQTT_PublishLimit($wallbox,{});
    return;
  }
  if(length($currTransaction)==0 || $payload->{force} || $MQTT_STARTED || length($MQTT_TAG)>0) {
    if(length($payload->{idTag})>0) {
      # NO MORE USED, set now by set_tag command
      $MQTT_TAG=$payload->{idTag};
      $MQTT_STARTED=-1;
    }
    else {
      if(length($MQTT_TAG)>0) {
	# Use TAG/HA-profile
        $MQTT_STARTED=-1;
      }
      else {
        # Use HA-current if > 0 or other profile
        $MQTT_STARTED=1;
      }
    }
  }
  if(length($FIXED)>0) {
    $newOffered=$FIXED;
  }
  else {
    $newOffered=$WBMINPOWER;
  }
  if($MQTT_STARTED) {
    SetTriggerMQTT($connector,$payload->{command});
    $FORCE_STOP=0;
    verbose(10,"Received MQTT Start request ($currTransaction, newOffered=$newOffered [$FIXED])\n");
    $SUBSTATUS="";
    $err=SmartStart($newOffered,$currTransaction);
    if(length($err)>0) {
      ($err,$info)=split("\\|",$err);
      wallbox_result($connector,$payload->{command},$err,1,$info);
    }
  }
  else {
    my $errstr="Session $currTransaction not started by MQTT/HA and 'force' not specified";
    verbose(10,"MQTT Start request, but $errstr\n");
    wallbox_result($connector,$payload->{command},"Rejected",102,$errstr);
  }
  MQTT_PublishLimit($wallbox,{});
}

sub wallbox_cmd_stop {
  my ($connector,$payload)=@_;
  my ($newOffered,$err,$info);
  $newOffered=0;
  if($payload->{force}) { $newOffered.="force"; }
  verbose(10,"Received MQTT Stop request ($currTransaction, idTag=$TAG/$MQTT_TAG, force=$payload->{force})\n");
  if($MQTT_STARTED || $payload->{force} || length($MQTT_TAG)>0) {
    $FORCE_STOP=1;
    SetTriggerMQTT($connector,$payload->{command},2);
    $SUBSTATUS="";
    $err=StartStop($newOffered,0,$currTransaction);
    if(length($err)>0) {
      ($err,$info)=split("\\|",$err);
      wallbox_result($connector,$payload->{command},$err,2,$info);
    }
  }
  else {
    wallbox_result($connector,$payload->{command},"Rejected",102,"Session $currTransaction not started by MQTT/HA and 'force' not specified");
  }
  MQTT_PublishLimit($wallbox,{});
}

sub wallbox_cmd_unlock {
  my ($connector,$payload)=@_;
  my ($err,$info);
  SetTriggerMQTT($connector,$payload->{command},3);
  verbose(10,"Received MQTT Unlock request ($currTransaction, idTag=$TAG, force=$payload->{force})\n");
  $err=Unlock($connector,$payload->{force});
  if(length($err)>0) {
    ($err,$info)=split("\\|",$err);
    wallbox_result($connector,$payload->{command},$err,3,$info);
  }
}

sub wallbox_cmd_reset {
  my ($connector,$payload)=@_;
  my ($err,$info);
  SetTriggerMQTT($connector,$payload->{command},3);
  verbose(10,"Received MQTT Reset request ($currTransaction, idTag=$TAG, type=$payload->{type}, force=$payload->{force})\n");
  $err=Reset($payload->{type},$payload->{force});
  if(length($err)>0) {
    ($err,$info)=split("\\|",$err);
    wallbox_result($connector,$payload->{command},$err,3,$info);
  }
}

sub wallbox_cmd_set_limit {
  my ($connector,$payload)=@_;
  $MQTT_FIXED=$payload->{limit};
  if($MQTT_FIXED<0) { $MQTT_FIXED=""; }
  elsif(length($MQTT_FIXED)>0 && $MQTT_FIXED<$MINPOWER) {
    $MQTT_FIXED=0;
  }
  my ($info);
  if(length($MQTT_FIXED)==0) {
    $info="Disabling MQTT limit, restore profiles handling";
  }
  elsif($MQTT_FIXED<$MINPOWER) {
    $info="Charging suspended by MQTT, disabling profiles";
  }
  else {
    $info="Maximum current/power limit set to $MQTT_FIXED, disabling profiles";
  }
  verbose(10,"$info\n");
  wallbox_result($connector,$payload->{command},"Accepted",0,$info);
  MQTT_PublishLimit($wallbox,{});
}

sub wallbox_cmd_set_tag {
  my ($connector,$payload)=@_;
  my ($info);
  my @o=GetTagOptions();
  $MQTT_TAG=$payload->{idTag};
  if($MQTT_TAG eq $o[0]) {
    $MQTT_TAG="";
    $MQTT_STARTED=0;
  }
  elsif($MQTT_TAG eq $o[1]) {
    $MQTT_TAG="";
    $MQTT_STARTED=1;
  }
  elsif(length($MQTT_TAG)>0) {
    $MQTT_STARTED=-1;
  }
  elsif(defined($MQTT_TAG)) {
    $MQTT_STARTED=1;
  }
  else {
    $MQTT_STARTED=0;
  }
  if($MQTT_STARTED<0) {
    $info="Using $MQTT_TAG to select profile";
  }
  elsif($MQTT_STARTED>0 && $MQTT_FIXED>=0) {
    $info="Using $MQTT_FIXED fixed current, disabling profiles";
  }
  else {
    $info="Using $TAG ($card{$TAG}) to select profile";
  }
  verbose(10,"Set Tag command: $info\n");
  wallbox_result($connector,$payload->{command},"Accepted",0,$info);
  MQTT_PublishLimit($wallbox,{});
}

sub wallbox_cmd_reconf {
  my ($connector,$payload)=@_;
  MQTT_HA();
  MQTT_ChargeLog();
  MQTT_ReConf();
  wallbox_result($connector,$payload->{command},"Accepted",0,"Reconfiguring logs, config, and HA");
}

sub wallbox_cmd_trigger {
  my ($connector,$payload)=@_;
  my $message=$payload->{message};
  my ($info);
  SetTriggerMQTT($connector,$payload->{command});
  $info="Triggering remote message '$message'";
  verbose(11,"$info\n");
  my $uuid=GenUUID();
  $buffer="[2,\"$uuid\", \"TriggerMessage\", {\"requestedMessage\": \"$message\"}]";
  PushQueue($buffer);
}

sub wallbox_cmd_max_energy {
  my ($connector,$payload)=@_;
  $MQTT_MAX_ENERGY_SESSION=$payload->{energy};
  $MQTT_RESET_MAX_ENERGY=$payload->{reset_after_stop};
  SetMaxEnergy();
  my ($info);
  if(FixEnergy($MQTT_MAX_ENERGY_SESSION)==0) {
    if($ACTIVE_MAX_ENERGY_SESSION>0) {
      $info="Restored INI max energy session ($ACTIVE_MAX_ENERGY_SESSION)";
    }
    else {
      $info="Disabling max energy session limit";
    }
  }
  else {
    $info="Maximum energy for session set to $ACTIVE_MAX_ENERGY_SESSION (reset after stop=$MQTT_RESET_MAX_ENERGY)";
  }
  verbose(10,"$info\n");
  MQTT_PublishLimit($wallbox,{});
  wallbox_result($connector,$payload->{command},"Accepted",0,$info);
}

sub _wallbox_callback {
  my ($topic, $message) = @_;
  return if(MQTT_Config($topic,$message));
  # Available commands: start, stop, unlock, reset, set_limit
  my ($cmdfunc,$funcname,$s,$i,$json,$subtopic);
  $s=$smart{$wallbox};
  return if(!defined($s));
  if($topic=~m|/$s->{WALLBOX_MQTT_CMD_BASE}/|) {
    $i=rindex($topic,"/");
    if($i>0) {
      # Get connector, if available
      $subtopic=MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,$MQTT_WALLBOX_BASE,Base($s->{WALLBOX_MQTT_BASE},$wallbox),"(\S+?)",$s->{WALLBOX_MQTT_CMD_BASE},"");
      ($connector)=($topic=~m/$subtopic/);
      if(length($connector)==0) { $connector=1; }

      $cmdfunc=substr($topic,$i+1);
      $funcname="wallbox_cmd_$cmdfunc";
      if(defined(&$funcname)) {

        # Convert JSON message and check it is coherent
	eval {
	  $json=decode_json($message);
	};
	if(!defined($json)) {
	  my $err="ERROR decoding JSON meter message ($message): $@";
          verbose(12,"$err\n");
	  wallbox_result($connector,$cmdfunc,"Error",100,$err);
	  return;
	}
	elsif($cmdfunc ne $json->{command}) {
	  my $err="JSON command ($json->{command}) not coherent with topic ($cmdfunc)";
          verbose(12,"$err\n");
	  wallbox_result($connector,$cmdfunc,"Error",101,$err);
	  return;
	}
	eval {
	  &$funcname($connector,$json);
	};
      }
      else {
        if(!($topic=~m|/result|)) {
	  wallbox_result($connector,$cmdfunc,"Unknown",99,"Command '$cmdfunc' unknown");
        }
      }
    }
  }
}

sub wallbox_callback {
  _wallbox_callback(@_);
}

sub MQTT_WallboxResultBase {
  my ($wallbox,$conn)=@_;
  my ($s,$resbase);
  $s=$smart{$wallbox};
  if(length($s->{WALLBOX_MQTT_RESULT_BASE})>0) {
    return($s->{WALLBOX_MQTT_RESULT_BASE});
  }
  return($s->{"WALLBOX_MQTT_GET_CONNECTOR${conn}_BASE"});
}

sub _wallbox_getset_callback {
  my ($topic, $message) = @_;
  my($s,$i,$w);
  $s=$smart{$mqtt_wallbox};
  my $prefix=MQTT_ComposeTopic($s->{WALLBOX_MQTT_GET_BASE},MQTT_WallboxResultBase($mqtt_wallbox,$mqtt_conn),"");
  if(substr($topic,0,length($prefix)) eq "$prefix") {
    # OK, we got result. Check which command
    verbose(10,"Wallbox result ($mqtt_wallbox, connector=$mqtt_conn, subtopic=".substr($topic,length($prefix))."): $message\n");
    for($i=0;$i<=$#WALLBOX_RESULT;$i++) {
      $w=$WALLBOX_RESULT[$i];
      if(length($s->{$w->{error}})>0 && $topic eq MQTT_ComposeTopic($prefix,$s->{$w->{error}})) {
        wallbox_result($mqtt_conn,$w->{command},"Error",$w->{ecode},$message);
        last;
      }
      elsif(length($s->{$w->{success}})>0 && $topic eq MQTT_ComposeTopic($prefix,$s->{$w->{success}})) {
	if(length($s->{$w->{error}})==0 && $message=~m/error/i) {
          # More complicated, search for "error" string:
          wallbox_result($mqtt_conn,$w->{command},"Error",$w->{ecode},$message);
	}
	else {
          wallbox_result($mqtt_conn,$w->{command},"Success",0,$message);
	}
        last;
      }
    }
  }
}

sub wallbox_getset_callback {
  _wallbox_getset_callback(@_);
}

sub MQTT_SetLimit {
  my ($wallbox,$conn,$limit)=@_;
  my ($s);
  $s=$smart{$wallbox};
  if(length($s->{WALLBOX_MQTT_SET_LIMIT})>0) {
    $mqtt_wallbox=$wallbox;
    $mqtt_conn=$conn;
    verbose(12,"Setting current limit for $wallbox ($conn) to $limit\n");
    MQTT_Publish(MQTT_ComposeTopic($s->{WALLBOX_MQTT_GET_BASE},$s->{"WALLBOX_MQTT_CONNECTOR${conn}_BASE"},$s->{WALLBOX_MQTT_SET_LIMIT}),$limit);
  }
}


##################################


sub Base {
  my ($first,$second)=@_;
  if(length($first)==0) {
    $first=$second;
  }
  return($first);
}

sub MQTT_ConfigGeneralBase
{
  return(Base($MQTT_CONFIG_GENERAL_BASE,"config/general"));
}

sub MQTT_ConfigProfileBase
{
  return(Base($MQTT_CONFIG_PROFILE_BASE,"config/profile"));
}

sub MQTT_ConfigGridBase
{
  return(Base($MQTT_CONFIG_GRID_BASE,"config/grid"));
}

sub MQTT_ConfigBaseloadBase
{
  return(Base($MQTT_CONFIG_BASELOAD_BASE,"config/baseload"));
}

sub MQTT_ConfigWallboxBase
{
  return(Base($MQTT_CONFIG_WALLBOX_BASE,"config/wallbox"));
}

sub MQTT_ConfigEvBase
{
  return(Base($MQTT_CONFIG_EV_BASE,"config/ev"));
}

sub MQTT_ComposeTopic {
  # Pass topic and subtopic[s] as parameter, slash will be added as needed
  my @topic=@_;
  my ($i,$topic);
  $topic=$topic[0];
  for($i=1;$i<=$#topic;$i++) {
    if(substr($topic,-1) ne "/") { $topic.="/"; }
    $topic.=$topic[$i];
  }
  return($topic);
}

sub MQTT_Publish
{
  my ($topic,$payload)=@_;
  if(defined($mqtt)) {
    if(!defined($payload)) { $payload=""; } # Warning Use of uninitialized value $message in concatenation (.) or string at Net/MQTT/Simple.pm line 347.
    $mqtt->publish($topic,$payload);
  }
}

sub MQTT_Retain
{
  my ($topic,$payload)=@_;
  if(defined($mqtt)) {
    $mqtt->retain($topic,$payload);
    #verbose(12,"Retaining $topic => $payload\n");
  }
}

sub MQTT_Delete
{
  my ($topic)=@_;
  if(defined($mqtt)) {
    $mqtt->retain($topic,undef);
  }
}

sub MQTT_DeleteConfig {
  my ($topicbase)=@_;
  if(!defined($mqtt)) { return(undef); }

  if(substr($topicbase,-1) eq "#") {
    $topicbase=substr($topicbase,0,-1);
  }
  my($i);
  foreach $i (keys %mqtt_config)
  {
    if(length($mqtt_config_retain{$i})==0) {
      if(substr($i,0,length($topicbase)) eq $topicbase) {
	verbose(15,"DELETE=$topicbase <=> $i\n");
	$mqtt->retain($i,undef);
	delete($mqtt_config{$i});
      }
    }
  }
}

sub SessionTime {
  my $time=shift;
  my $s=substr(LTime($time+0),0,19);
  $s=~s/[-:]//g;
  $s=~s/ /-/g;
  return($s);
}


sub SessionPayload {
  my($session,$subsession,$StartTime,$EndTime,$kWh,$time,$As,$Ac,$timeAs,$PV,@f)=@_;
  my($avgkW,$avgA,$avgCUR);
  if($time>0) {
    $avgkW=sprintf("%.2f",$kWh*3600/$time)+0.0;
    if($timeAs==0) { $timeAs=$time; }
    $avgA=sprintf("%.2f",$As/$timeAs)+0.0;
    $avgCUR=sprintf("%.2f",$Ac/$timeAs)+0.0;
  }
  my %payload=(	"transaction"=>$session,"transaction_sub"=>$subsession,"timestart"=>($StartTime+0),"timestart_human"=>SessionTime($StartTime),"timeend"=>($EndTime+0),"timeend_human"=>SessionTime($EndTime),
		"kWh"=>$kWh,"session_time"=>$time,"session_time_human"=>TimeToHMS($time),"avgkW"=>$avgkW,"avgO"=>$avgA,"avgA"=>$avgCUR,"kWh_PV"=>$PV,"kWh_grid"=>(sprintf("%.3f",$kWh-$PV)+0.0));
  for($i=0;$i<=$#timeslot;$i++) {
    $payload{"kWh_$timeslot[$i]{name}"}=$f[$i];
  }
  if($kWh>0) {
    $payload{"percPV"}=sprintf("%.1f",$PV*100/$kWh)+0.0;
  }
  #verbose(11,"Publishing $session / $subsession\n");
  return(%payload);
}

sub ComposeSection {
  my ($priority,$smart,@params)=@_;
  my (%payload,$i);
  if(defined($priority)) {
    $payload{priority}=$priority;
  }
  unshift(@param,"name");
  for($i=0;$i<=$#params;$i++) {
    if(defined($smart->{$params[$i]})) {
      $payload{$params[$i]}=$smart->{$params[$i]};
    }
  }
  return(%payload);
}

sub MQTT_RetainDifferent
{
  my ($topic,$payload)=@_;
  if(!defined($payload)) { $payload="null"; }
  $mqtt_config_retain{$topic}=$payload;
  if(!$mqtt_config) {
    $mqtt_config_once{$topic}=1;
    verbose(12,"Publishing retain $topic => $payload\n");
    MQTT_Retain($topic,$payload);
    $mqtt_config=10;
    MQTT_Flush(\$config_counter);
    $mqtt_config=0;
  }
  elsif(defined($mqtt_config{$topic}) && $mqtt_config{$topic} ne $payload) {
    delete($mqtt_config{$topic});
  }
  if(exists($mqtt_config{$topic})) { 
    delete($mqtt_config{$topic});
  }
  else {
    MQTT_Retain($topic,$payload);
  }
}

sub MQTT_PublishLog
{
  my($topicstart,$session,$subsession,$session_start,$session_end,$energy,$time,$as,$ac,$timeas,$pv,@f)=@_;
  if(!defined($mqtt)) { return(undef); }

  my $subtopic=SessionTime($topicstart)."-$session";
  %payload=SessionPayload($session,$subsession,$session_start,$session_end,$energy,$time,$as,$ac,$timeas,$pv,@f);
  if($subsession eq "") { $subsession="total"; }
  MQTT_RetainDifferent(MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,$MQTT_SESSIONS_BASE,$subtopic,$subsession),encode_json(\%payload));
}

sub MQTT_Flush {
  my($counter)=@_;
  my $maxloops=100;
  # sleep a bit before
  sleep(0.5);
  while($maxloops>0) {
    $$counter=0;
    $maxloops--;
    # sleep a bit
    sleep(0.1);
    $mqtt->tick(0.1);
    if($$counter==0) {
      $maxloops=0;
    }
  }
}

sub MQTT_ChargeLog
{
  # Load charge.log:
  #TransID	StartTime StartTimeTxt	EndTime EndTimeTxt	TkWh	Ttime	TavgkW	kWh	time	avgkW	avgA	PV	F1	F2	F3	+Cost
  #210-4	1765207262 251208-16:21	1765207450 251208-16:24	5.219	4:01	1.30kW	0.101	0:03	1.93kW	10.00A	0	0.101	-	-
  my (%logmeas,$head,$tottime,$totas,$totac,$totenergy,$totpv,$session_start,$session_end,$time,@totf,$session,$lastsession);
  my ($i);
  if(!defined($mqtt)) { return(undef); }
  if(!$mqtt_config) { 
    $mqtt_config=1;
    %mqtt_config=();
    %mqtt_config_once=();
  }
  verbose(12,"Publishing sessions... $mqtt_config\n");
  my $topic=MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,$MQTT_SESSIONS_BASE,"")."#";
  $mqtt->subscribe($topic,\&config_callback);

  # To fill %mqtt_config hash
  MQTT_Flush(\$config_counter);
  $mqtt->unsubscribe($topic);
  
  if(open(F,$charge_log)) {
    $head=<F>;
    while(<F>) {
      chop;
      if(m/^#/) { next; }
      my($TransID,$StartTime,$EndTime,$TkWh,$Ttime,$TavgkW,$kWh,$time,$avgkW,$avgA,$PV,@f)=split("\t");
      my ($avgCUR);
      if($avgA=~m|/|) {
        ($avgA,$avgCUR)=split("/",$avgA);
      }
      else {
        $avgCUR=$avgA;
      }
      my ($session,$subsession)=split("-",$TransID);
      if($session ne $lastsession) {
        if(length($lastsession)>0) {
          MQTT_PublishLog($session_start,$lastsession,"",$session_start,$session_end,$totenergy,$tottime,$totas,$totac,$tottime,$totpv,@totf);
	}
        @totf=();
	$totas=$totac=$totenergy=$totpv=$tottime=0;
	$session_start=$StartTime+0;
      }
      $lastsession=$session;
      $session_end=$EndTime+0;
      $time=$EndTime-$StartTime;
      my $As=$avgA*$time;
      my $Ac=$avgCUR*$time;
      $tottime+=$time;
      $totas+=$As;
      $totac+=$Ac;
      $totpv+=$PV;
      $totenergy+=$kWh;
      for($i=0;$i<=$#timeslot;$i++) {
	$f[$i]+=0.0;
        $totf[$i]+=$f[$i];
      }
      $subsession=sprintf("%03d",$subsession);
      MQTT_PublishLog($session_start,$session,$subsession,$StartTime+0,$EndTime+0,$kWh+0,$time,$As,$Ac,$time,$PV+0,@f);
      $logmeas{transaction}=$TransID;
      $logmeas{transactionId}=$session;
      $logmeas{transactionSub}=$subsession;
      $logmeas{energy}=MQTT_Energy($kWh*1000);
      $logmeas{energy_pv}=MQTT_Energy($PV*1000);
      $logmeas{energy_grid}=$logmeas{energy}-$logmeas{energy_pv};
      if($logmeas{energy}>0) {
        $logmeas{energy_pvperc}=sprintf("%.1f",$logmeas{energy_pv}*100.0/$logmeas{energy})+0.0;
      }
      $logmeas{timestart_unix}=$StartTime+0;
      $logmeas{timestart}=Zulu($StartTime);
      $logmeas{timeend_unix}=$EndTime+0;
      $logmeas{timeend}=Zulu($EndTime);
      $logmeas{elapsed}=$time;
      $logmeas{elapsed_human}=TimeToHMS($time);
      if($time>0) {
        $logmeas{current_average}=sprintf("%.2f",$Ac/$time)+0;
        $logmeas{offered_average}=sprintf("%.2f",$As/$time)+0;
        $logmeas{power_average}=sprintf("%.0f",$kWh*3600000.0/$time)+0;
      }
    }
    $logmeas{power}=0;
    $logmeas{current}=0;
    $logmeas{offered}=0;
    $logmeas{voltage}=ActVoltFormatted();
    $logmeas{max_energy}=MQTT_Energy($ACTIVE_MAX_ENERGY_SESSION);
    if(length($lastsession)>0) {
      MQTT_PublishLog($session_start,$lastsession,"",$session_start,$session_end,$totenergy,$tottime,$totas,$totac,$tottime,$totpv,@totf);
      $logmeas{energy_session}=MQTT_Energy($totenergy*1000);
      $logmeas{energy_session_pv}=MQTT_Energy($totpv*1000);
      $logmeas{energy_session_grid}=$logmeas{energy}-$logmeas{energy_pv};
      if($logmeas{energy_session}>0) {
        $logmeas{energy_session_pvperc}=sprintf("%.1f",$logmeas{energy_session_pv}*100.0/$logmeas{energy_session})+0.0;
      }
      $logmeas{timestart_session_unix}=$session_start;
      $logmeas{timestart_session}=Zulu($session_start);
      $logmeas{elapsed_session}=$tottime;
      $logmeas{elapsed_session_human}=TimeToHMS($tottime);
      if($tottime>0) {
        $logmeas{current_session_average}=sprintf("%.2f",$totac/$tottime)+0;
        $logmeas{offered_session_average}=sprintf("%.2f",$totas/$tottime)+0;
        $logmeas{power_session_average}=sprintf("%.0f",$totenergy*3600000.0/$tottime)+0;
      }
    }
    if(!defined($lastmeasure{current})) {
      %lastmeasure=%logmeas;
    }
    close(F);
  }
  MQTT_PublishSession($wallbox,\%lastmeasure);
  MQTT_PublishStatus($wallbox,\%laststatus);
  MQTT_PublishCharging($wallbox,$STATUS eq "CHARGE"?1:0);
  #MQTT_PublishLimit($wallbox,{});
  # Delete existing no-more-retained topics:
  MQTT_DeleteConfig($topic);
  if($mqtt_config==1) { $mqtt_config=0; }
}

sub MQTT_Active {
  my($smart,$subtopic,@params)=@_;
  if(!defined($mqtt)) { return(undef); }
  if(!defined($smart)) { $smart=\%default; }
  %payload=ComposeSection(undef,$smart,@params);
  MQTT_RetainDifferent(MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,$subtopic,"_active"),encode_json(\%payload));
}

sub MQTT_ActiveGrid {
  MQTT_Active($smart{$currGrid},MQTT_ConfigGridBase(),@grid_params);
}

sub MQTT_ActiveProfile {
  MQTT_Active($smart{$currProfile},MQTT_ConfigProfileBase(),@profile_params);
}

sub MQTT_ActiveBaseload {
  MQTT_Active($smart{$currBaseload},MQTT_ConfigBaseloadBase(),@baseload_params);
}

sub MQTT_PublishSubValues {
  my($topic,$payload)=@_;
  my($i);
  if(ref($payload) ne "") {
    if(ref($payload) eq "HASH") {
      foreach $i (keys %{$payload}) {
        MQTT_PublishSubValues(MQTT_ComposeTopic($topic,$i),$payload->{$i});
      }
    }
    elsif(ref($payload) eq "ARRAY") {
      for($i=0;$i<=$#$payload;$i++) {
        MQTT_PublishSubValues(MQTT_ComposeTopic($topic,sprintf("%03d",$i)),$payload->[$i]);
      }
    }
  }
  else {
    MQTT_Publish($topic,$payload);
  }
}

sub MQTT_PublishValues {
  my($topicbase,$subtopic,$payload,$retain)=@_;
  if(!defined($mqtt)) { return(undef); }
  my($topic,$message);
  $topic=MQTT_ComposeTopic($topicbase,$subtopic);
  $message=(ref($payload) eq ""?$payload:encode_json($payload));
  if($retain) {
    MQTT_Retain($topic,$message);
  }
  else {
    MQTT_Publish($topic,$message);
  }
  if(length($MQTT_SINGLE_VALUES)>0 && ref($payload) ne "") {
    MQTT_PublishSubValues(MQTT_ComposeTopic($topicbase,"$subtopic$MQTT_SINGLE_VALUES"),$payload,$retain);
  }
}

sub MQTT_PublishMeter {
  my ($now,$power,$voltage,$current,$averagepower,$lineref,$voltageref,$currentref,$powerref)=@_;
  my (%payload,$i,$line);
  $now=Now($now); # Just in case $now is undefined
  if(($now-$MQTT_lastmeterpublish)<$MQTT_METER_INTERVAL) { return; }
  $MQTT_lastmeterpublish=$now;
  #verbose(10,"Publishing meter values: $power $voltage $current\n");
  $payload{power}=MQTT_Power($power+0.0);
  $payload{voltage}=$voltage+0.0;
  $payload{current}=$current+0.0;
  $payload{timestamp}=Zulu($now);
  $payload{timestamp_unix}=$now;
  if(defined($averagepower)) {
    $payload{power_average}=MQTT_Power($averagepower+0);
  }
  if(defined($lineref)) {
    for($i=0;$i<=$#$lineref;$i++) {
      $line="L$lineref->[$i]";
      if(length($voltageref->[$i])>0) { $payload{$line}{voltage}=$voltageref->[$i]+0.0; }
      if(length($currentref->[$i])>0) { $payload{$line}{current}=$currentref->[$i]+0.0; }
      if(length($powerref->[$i])>0) { $payload{$line}{power}=MQTT_Power($powerref->[$i]+0.0); }
    }
  }
  %lastmeter=%payload;
  MQTT_PublishValues(MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,$MQTT_METER_BASE),"meter",\%payload);
}

sub MQTT_PublishWallbox {
  my ($wallbox,$subtopic,$payload,$retain)=@_;
  my (%pay);
  %pay=%{$payload}; # We will delete "now" field, so make a copy
  if(!defined($mqtt)) { return(undef); }
  #2025-12-12 11:59:01.292969 - [RX0] <= [2, "9854260", "StartTransaction", {"connectorId": 1, "idTag": "878E33E4", "meterStart": 0, "timestamp": "2025-12-12T10:59:00.000Z"}]
  my $conn=$pay{connectorId};
  if($conn==0) { $conn=1; }
  if(length($pay{timestamp})==0) {
    $pay{timestamp}=Zulu($pay{now});
  }
  $pay{timestamp_unix}=Now($pay{now});
  delete($pay{now});
  MQTT_PublishValues(MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,$MQTT_WALLBOX_BASE,Base($smart{$wallbox}{WALLBOX_MQTT_BASE},$wallbox),$smart{$wallbox}{"WALLBOX_MQTT_CONNECTOR${conn}_BASE"}),
                    $subtopic,\%pay,$retain);
}

sub GetTagOptions
{
  my($i,@w,@o);
  @w=@{$HA_DISCOVERY{wallbox}};
  for($i=0;$i<=$#w;$i++) {
    if($w[$i]->{unique_id}=~m/_charging_profile/) {
      @o=@{$w[$i]->{options}};
      last;
    }
  }
  return(@o);
}

sub GetMQTTTag
{
  # Get options array:
  my @o=GetTagOptions();
  if(length($MQTT_TAG)==0) {
    if($MQTT_STARTED==0) {
      return($o[0]);
    }
    else {
      return($o[1]);
    }
  }
  return($MQTT_TAG);
}

sub MQTT_PublishLimit {
  my ($wallbox,$payload)=@_;
  if(length($currSet)>0 && $currSet>=0) { 
    $payload->{limit}=$currSet;
  }
  else {
    $payload->{limit}=$currOffered;
  }
  if(length($MQTT_FIXED)>0 && $MQTT_STARTED>0) {
    $payload->{active_profile}="MQTT/HA";
  }
  else {
    $payload->{active_profile}=$currProfile;
  }
  $payload->{mqtt_limit}=$MQTT_FIXED;
  if(length($MQTT_FIXED)==0) { $payload->{mqtt_limit}=-1; }
  $payload->{active_grid}=$currGrid;
  if(length($MQTT_TAG)>0) { 
    $payload->{active_idtag}=$MQTT_TAG;
    $payload->{active_idtag}.=" [card=$TAG";
    if(defined($card{$TAG})) {
      $payload->{active_idtag}.=" ($card{$TAG})";
    }
    $payload->{active_idtag}.="]";
  }
  else { 
    $payload->{active_idtag}=$TAG;
    if(defined($card{$TAG})) {
      $payload->{active_idtag}.=" ($card{$TAG})";
    }
  }
  $payload->{mqtt_tag}=GetMQTTTag();
  $payload->{active_baseload}=$currBaseload;
  $payload->{grid_limit}=MQTT_Power($GRID_LIMIT);
  $payload->{charging}=($STATUS eq "CHARGE"?1:0);
  $payload->{grid_limit_safe}=MQTT_Power($GRID_LIMIT_SAFE);
  if(length($globalwh)>0) {
    $payload->{energy_global}=MQTT_Energy($globalwh);
  }
  $payload->{mqtt_max_energy}=$MQTT_MAX_ENERGY_SESSION+0;
  $payload->{max_energy}=MQTT_Energy($ACTIVE_MAX_ENERGY_SESSION);
  MQTT_PublishWallbox($wallbox,"limit",$payload);

  # Check if we have to publish also session data
  $limit_interval=Now()-$last_limit_publish;
  if($limit_interval<100) { $limit_interval=100; }
  $limit_interval*=2;
  if(!$payload->{charging} && defined($lastmeasure{current}) && (Now()-$last_session_publish)>=$limit_interval) {
    MQTT_PublishSession($wallbox,\%lastmeasure);
  }
  $last_limit_publish=Now();
}

sub MQTT_PublishStatus {
  my ($wallbox,$payload)=@_;
  #2025-12-12 11:58:59.768600 - [RX0] <= [2, "5530672", "StatusNotification", {"connectorId": 1, "errorCode": "NoError", "info": "null", "status": "SuspendedEV", "vendorErrorCode": "0x0000"}]
  my $now=Now($payload->{now});
  %laststatus=%{$payload};
  # Disabling interval check, since publishing status depends only by StatusNotification event
  #if(($now-$MQTT_laststatuspublish)<$MQTT_STATUS_INTERVAL) { return; }
  $MQTT_laststatuspublish=$now;

  my $status=ShowStatus();
  $payload->{ocpp_status}=$payload->{status};
  $payload->{status}=$status;
  $payload->{connected}=$CONNSTATUS;
  MQTT_PublishWallbox($wallbox,"status",$payload,1);
  MQTT_PublishLimit($wallbox,{now=>$now});
}

sub MQTT_PublishStart {
  my ($wallbox,$payload)=@_;
  MQTT_PublishWallbox($wallbox,"transaction_start",$payload);
}

sub MQTT_PublishStop {
  my ($wallbox,$payload)=@_;
  # 2025-11-12 08:49:55.696938 - [RX2] <= [2, "0662406", "StopTransaction", {"meterStop": 34238, "idTag": "878E33E4", "timestamp": "2025-11-12T07:49:51.000Z", "transactionId": 200, "reason": "EVDisconnected"}]

  if(defined($meterStart)) {
    $payload->{meterStart}=$meterStart;
  }
  MQTT_PublishWallbox($wallbox,"transaction_stop",$payload);
}

sub MQTT_PublishSuspend {
  my ($wallbox,$payload)=@_;
  # 2025-11-12 08:49:55.696938 - [RX2] <= [2, "0662406", "StopTransaction", {"meterStop": 34238, "idTag": "878E33E4", "timestamp": "2025-11-12T07:49:51.000Z", "transactionId": 200, "reason": "EVDisconnected"}]

  if(defined($meterStart)) {
    $payload{meterStart}=$meterStart;
  }
  MQTT_PublishWallbox($wallbox,"transaction_stop",$payload);
}

sub MQTT_PublishCharging {
  my ($wallbox,$charging)=@_;
  my %payload=("charging"=>$charging);
  $MQTT_CHARGING=$charging;
  MQTT_PublishWallbox($wallbox,"charging",\%payload,1);
}

sub MQTT_PublishSession {
  my ($wallbox,$payload)=@_;
  $last_session_publish=Now();
  MQTT_PublishWallbox($wallbox,"session",$payload);
}

sub MQTT_PublishBoot {
  my ($wallbox,$payload)=@_;
  MQTT_PublishWallbox($wallbox,"boot",$payload,1);
}

sub MQTT_PublishSecurity {
  my ($wallbox,$payload)=@_;
  MQTT_PublishWallbox($wallbox,"security",$payload);
}

sub MQTT_PublishConfiguration {
  my ($wallbox,$payload)=@_;
  MQTT_PublishWallbox($wallbox,"configuration",$payload,1);
}

sub MQTT_PublishAvailability {
  my ($online)=@_;
  my($topics,$topicw,$topice,$i);
  $topics=MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,"availability");
  $topicw=MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,$MQTT_WALLBOX_BASE,Base($smart{$wallbox}{WALLBOX_MQTT_BASE},$wallbox),"availability");
  if(!$online) {
    # Go offline
    MQTT_Retain($topics,"offline");
    MQTT_Retain($topicw,"offline");
    for($i=0;$i<=$#ev;$i++) {
      $topice=MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,$MQTT_EV_BASE,Base($smart{$ev[$i]}{EV_MQTT_BASE},$ev[$i]),"availability");
      MQTT_Retain($topice,"offline");
    }
    $mqtt_online=0;
  }
  else {
    if(!$mqtt_online) {
      $mqtt_online=1;
      # First of all, delete retained value
      MQTT_Retain($topics,undef);
      MQTT_Retain($topicw,undef);
      for($i=0;$i<=$#ev;$i++) {
	$topice=MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,$MQTT_EV_BASE,Base($smart{$ev[$i]}{EV_MQTT_BASE},$ev[$i]),"availability");
	MQTT_Retain($topice,undef);
      }
    }
    MQTT_Retain($topics,"online");
    MQTT_Retain($topicw,"online");
    for($i=0;$i<=$#ev;$i++) {
      $topice=MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,$MQTT_EV_BASE,Base($smart{$ev[$i]}{EV_MQTT_BASE},$ev[$i]),"availability");
      MQTT_Retain($topice,($ev_online[$i]?"online":"offline"));
    }
  }
}

sub MQTT_PublishHeartbeat {
  my ($wallbox,$payload)=@_;
  if($wallbox eq "") {
    # Server heartbeat
    my $topich=MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,"heartbeat");
    my (%pay,$now);
    $now=time();
    if($mqtt_online) { 
      $pay{status}="online";
    }
    else {
      $pay{status}="offline";
    }
    $pay{timestamp}=Zulu($now);
    $pay{timestamp_unix}=$now;
    $pay{version}=$VERSION;
    if($uptime==0) { $uptime=$now; }
    $pay{uptime}=int($now-$uptime);
    $pay{clients}=$connected;
    $pay{charging}=$MQTT_CHARGING;
    MQTT_PublishValues($MQTT_TOPIC_PREFIX,"heartbeat",\%pay);
  }
  else {
    $payload->{version}=$VERSION;
    $payload->{status}=$STATUS;
    $payload->{substatus}=$SUBSTATUS;
    $payload->{connected}=$CONNSTATUS;
    $payload->{charging}=$MQTT_CHARGING;
    $wallbox{$wallbox}{heartbeat}=Now($payload->{now});
    MQTT_PublishWallbox($wallbox,"heartbeat",$payload);
  }
}

sub SubscribeFile {
  my($prefix,$file)=@_;
  my ($i);
  if(!($prefix=~m/^file:/)) {
    return;
  }
  $prefix=~s/^file://;
  if(length($file)==0) {
    $file=$prefix;
  }
  else {
    $file=MQTT_ComposeTopic($prefix,$file);
  }
  ($file)=SplitTopicField($file);
  $subfile{$file}++;
  if($subfile{$file}>1) {
    return;
  }
  push(@subfile,$file);
}

sub MQTT_SectionRetainUpdate {
  my ($section,$j)=@_;
  my (%payload,$s);
  $s=$smart{$section};
  if(CheckPresence($s,@grid_params)) {
    %payload=ComposeSection($j+1,$s,@grid_params,@time_params);
    MQTT_RetainDifferent(MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,MQTT_ConfigGridBase(),$section),encode_json(\%payload));
  }
  if(CheckPresence($s,@profile_params)) {
    %payload=ComposeSection($j+1,$s,@profile_params,@time_params);
    MQTT_RetainDifferent(MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,MQTT_ConfigProfileBase(),$section),encode_json(\%payload));
  }
  if(CheckPresence($s,@baseload_params)) {
    %payload=ComposeSection($j+1,$s,@baseload_params,@time_params);
    MQTT_RetainDifferent(MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,MQTT_ConfigBaseloadBase(),$section),encode_json(\%payload));
  }
  if(CheckPresence($s,@wallbox_params)) {
    %payload=ComposeSection($j+1,$s,@wallbox_params);
    MQTT_RetainDifferent(MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,MQTT_ConfigWallboxBase(),$section),encode_json(\%payload));
  }
  if(CheckPresence($s,@ev_params)) {
    %payload=ComposeSection($j+1,$s,@ev_params);
    MQTT_RetainDifferent(MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,MQTT_ConfigEvBase(),$section),encode_json(\%payload));
  }
}

sub MQTT_ReConf {
  my($i,$j,$k,$check);
  # Configure file-based  meter
  @subfile=();
  %subfile=();
  if($METER_MQTT_PREFIX=~m/file:/) {
    for($i=0;$i<=$#METER_MAP;$i++) {
      $check=${$METER_MAP[$i]{topic}};
      if(length($check)>0) {
        SubscribeFile($METER_MQTT_PREFIX,$check);
      }
    }
  }
  if($PV_MQTT_PREFIX=~m/file:/) {
    for($i=0;$i<=$#PV_MAP;$i++) {
      $check=${$PV_MAP[$i]{topic}};
      if(length($check)>0) {
        SubscribeFile($PV_MQTT_PREFIX,$check);
      }
    }
  }
  if(EvParam("EV_MQTT_PREFIX")=~m/file:/) {
    for($i=0;$i<=$#EV_MAP;$i++) {
      $check=EvParam($EV_MAP[$i]{topic});
      if(length($check)>0) {
        SubscribeFile(EvParam("EV_MQTT_PREFIX"),$check);
      }
    }
  }
  foreach(($GRID_MQTT_IMPORT,$GRID_MQTT_EXPORT,$HOME_MQTT_ENERGY))
  {
    if(m/file:/) {
      SubscribeFile($_);
    }
  }


  if(!defined($mqtt)) { return(undef); }

  if(!$mqtt_config) { 
    $mqtt_config=2;
    %mqtt_config=();
    %mqtt_config_once=();
  }
  %mqtt_config_retain=();

  verbose(10,"Reconfiguring MQTT...\n");
  # Unsubscribe from config topics, and then resubscribe to get all retained topics:
  foreach $i (@mqtt_subscribed_config) {
    $mqtt->unsubscribe($i);
  }
  @mqtt_subscribed_config=();
  $i=0;
  $mqtt_subscribed_config[$i]=MQTT_ComposeTopic($MQTT_TOPIC_PREFIX, MQTT_ConfigGeneralBase(),"")."#";
  MQTT_Subscribe($mqtt_subscribed_config[$i],\&config_callback);$i++;
  $mqtt_subscribed_config[$i]=MQTT_ComposeTopic($MQTT_TOPIC_PREFIX, MQTT_ConfigProfileBase(),"")."#";
  MQTT_Subscribe($mqtt_subscribed_config[$i],\&config_callback);$i++;
  $mqtt_subscribed_config[$i]=MQTT_ComposeTopic($MQTT_TOPIC_PREFIX, MQTT_ConfigGridBase(),"")."#";
  MQTT_Subscribe($mqtt_subscribed_config[$i],\&config_callback);$i++;
  $mqtt_subscribed_config[$i]=MQTT_ComposeTopic($MQTT_TOPIC_PREFIX, MQTT_ConfigBaseloadBase(),"")."#";
  MQTT_Subscribe($mqtt_subscribed_config[$i],\&config_callback);$i++;
  $mqtt_subscribed_config[$i]=MQTT_ComposeTopic($MQTT_TOPIC_PREFIX, MQTT_ConfigWallboxBase(),"")."#";
  MQTT_Subscribe($mqtt_subscribed_config[$i],\&config_callback);$i++;
  $mqtt_subscribed_config[$i]=MQTT_ComposeTopic($MQTT_TOPIC_PREFIX, MQTT_ConfigEvBase(),"")."#";
  MQTT_Subscribe($mqtt_subscribed_config[$i],\&config_callback);$i++;

  # To fill mqtt_config
  MQTT_Flush(\$config_counter);

  # Set General config session
  for($i=0;$i<=$#general_params;$i++)
  {
      MQTT_RetainDifferent(MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,MQTT_ConfigGeneralBase(),$general_params[$i]),${$general_params[$i]});
  }
  # Set specific general params:
  for($i=0;$i<=$#listen_port;$i++) {
      MQTT_RetainDifferent(MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,MQTT_ConfigGeneralBase(),"LISTEN$i"),$listen_port[$i]);
  }
  MQTT_RetainDifferent(MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,MQTT_ConfigGeneralBase(),"CONFKEY"),encode_json(\@confkey));
  MQTT_RetainDifferent(MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,MQTT_ConfigGeneralBase(),"HOLIDAY"),encode_json(\@holiday));
  MQTT_RetainDifferent(MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,MQTT_ConfigGeneralBase(),"TIMESLOT"),encode_json(\@timeslot));
  MQTT_RetainDifferent(MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,MQTT_ConfigGeneralBase(),"CARD"),encode_json(\@card));

  MQTT_ActiveGrid();
  MQTT_ActiveProfile();
  MQTT_ActiveBaseload();

  $section="_default";
  %payload=ComposeSection(0,\%default,@grid_params);
  MQTT_RetainDifferent(MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,MQTT_ConfigGridBase(),$section),encode_json(\%payload));
  %payload=ComposeSection(0,\%default,@profile_params);
  MQTT_RetainDifferent(MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,MQTT_ConfigProfileBase(),$section),encode_json(\%payload));
  %payload=ComposeSection(0,\%default,@baseload_params);
  MQTT_RetainDifferent(MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,MQTT_ConfigBaseloadBase(),$section),encode_json(\%payload));
  # Set Profiles
  $i=0;
  for($j=0;$j<=$#smart;$j++)
  {
    $section=$smart[$j];
    my $s=$smart{$section};
    MQTT_SectionRetainUpdate($section,$j);
    if(CheckPresence($s,@wallbox_params)) {
      my $conn=1;
      if($s->{WALLBOX_CONNECTORS}>1) { $conn=$s->{WALLBOX_CONNECTORS}; }
      # Subscribe command and event topic
      if(length($s->{WALLBOX_MQTT_CMD_BASE})>0) {
	for($k=1;$k<=$conn;$k++) {
	  $mqtt_subscribed_config[$i]=MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,$MQTT_WALLBOX_BASE,Base($s->{WALLBOX_MQTT_BASE},$section),$s->{"WALLBOX_MQTT_CONNECTOR${k}_BASE"},$s->{WALLBOX_MQTT_CMD_BASE},"")."#";
	  MQTT_Subscribe($mqtt_subscribed_config[$i],\&wallbox_callback);$i++;

	}
      }
      # Check if defined topic to get/set wallbox data:
      if(length($s->{WALLBOX_MQTT_GET_BASE})>0) {
	for($k=1;$k<=$conn;$k++) {
	  $mqtt_subscribed_config[$i]=MQTT_ComposeTopic($s->{WALLBOX_MQTT_GET_BASE},$s->{"WALLBOX_MQTT_GET_CONNECTOR${k}_BASE"},"")."#";
	  MQTT_Subscribe($mqtt_subscribed_config[$i],\&wallbox_getset_callback);$i++;
        }
	if(length($s->{WALLBOX_MQTT_RESULT_BASE})>0) {
	  $mqtt_subscribed_config[$i]=MQTT_ComposeTopic($s->{WALLBOX_MQTT_GET_BASE},$s->{WALLBOX_MQTT_RESULT_BASE},"")."#";
	  MQTT_Subscribe($mqtt_subscribed_config[$i],\&wallbox_getset_callback);$i++;
	}
      }
    }
  }

  # Delete existing no-more-retained topics:
  foreach $i (MQTT_ConfigGeneralBase(),MQTT_ConfigGridBase(),MQTT_ConfigProfileBase(),MQTT_ConfigBaseloadBase(),MQTT_ConfigWallboxBase(),MQTT_ConfigEvBase())
  {
    MQTT_DeleteConfig(MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,$i,""));
  }
  MQTT_Flush(\$config_counter);
  if($mqtt_config==2) { $mqtt_config=0; }

  foreach $i (@mqtt_subscribed) {
    $mqtt->unsubscribe($i);
  }
  @mqtt_subscribed=();

  $i=0;
  if(length($METER_MQTT_PREFIX)>0 && !($METER_MQTT_PREFIX=~m/file:/)) {
    $mqtt_subscribed[$i]=MQTT_ComposeTopic($METER_MQTT_PREFIX,"")."#";
    MQTT_Subscribe($mqtt_subscribed[$i],\&meter_callback);$i++;
  }
  if(length($PV_MQTT_PREFIX)>0 && !($PV_MQTT_PREFIX=~m/file:/)) {
    $mqtt_subscribed[$i]=MQTT_ComposeTopic($PV_MQTT_PREFIX,"")."#";
    MQTT_Subscribe($mqtt_subscribed[$i],\&pv_callback);$i++;
  }
  if(length(EvParam("EV_MQTT_PREFIX"))>0 && !(EvParam("EV_MQTT_PREFIX")=~m/file:/)) {
    $mqtt_subscribed[$i]=MQTT_ComposeTopic(EvParam("EV_MQTT_PREFIX"),"")."#";
    MQTT_Subscribe($mqtt_subscribed[$i],\&ev_callback);$i++;
  }
  my (%sub,$check);
  foreach(($GRID_MQTT_IMPORT,$GRID_MQTT_EXPORT,$HOME_MQTT_ENERGY)) {
    if(length($_)>0 && !($_=~m/file:/)) {
      ($check)=SplitTopicField($_);
      if(!$sub{$check}) {
	$mqtt_subscribed[$i]=$check;
	MQTT_Subscribe($mqtt_subscribed[$i],\&grid_callback);$i++;
      }
      $sub{$check}++;
    }
  }
}

sub MQTT_UnsubscribeAll
{
  my (@topic);
  my ($i);
  if(defined($mqtt)) {
    @topic=(@mqtt_subscribed,@mqtt_subscribed_config);
    if($#topic>=0) {
      verbose(9,"Unsubscribing relevant topics\n");
      foreach $i (@topic) {
	$mqtt->unsubscribe($i);
      }
      @mqtt_subscribed=@mqtt_subscribed_config=();
    }
  }
}

sub MQTT_Subscribe
{
  my ($topic,$callback)=@_;
  $mqtt->subscribe($topic,$callback);
  verbose(15,"Subscribed $topic\n");
}

sub MQTT_SubscribeAll
{
  @mqtt_subscribed_config=();
  my ($i,$head,$lastsession,%payload,@ftot,$totenergy,$totpv,$tottime,$session_start,$session_end,$lasttopic,$subtopic);
  my ($value,$res);

  if(!defined($mqtt)) { return(undef); }

  # Just to be sure Unsubscribe was called ;-)
  MQTT_UnsubscribeAll();
  verbose(9,"Publishing retain[s] and subscribing relevant topics\n");

  # First of all, create the basic structure.
  MQTT_HA();
  MQTT_ChargeLog();
  MQTT_ReConf();

  $mqtt_connected=2;
}

sub MQTT_RemoveHA
{
  my($i,$k);
  if(defined($mqtt)) {
    # Unretain HA auto-discovery
    foreach $i (@mqtt_ha) {
      verbose(11,"Removing HA $i auto-discovery..\n");
      $mqtt->retain($i,undef);
    }
    @mqtt_ha=();
  }
}

sub AddInfo {
  my($d,$prop,$value)=@_;
  if(defined($value)) {
    $d->{$prop}=$value;
  }
}

sub MQTT_HA
{
  my($i,$k,$sec,$topic,%h,%d,@ent,$device_name,$device_id,$component,%mqtt_ha,@dev,$dev,$map,$base,$val,$func);
  if(!defined($mqtt)) { return(undef); }
  if($MQTT_ENABLED && $HA_DISCOVERY_ENABLED) {
    #MQTT_RemoveHA();
    # Save already defined discovery, to delete them if necessary
    foreach(@mqtt_ha) {
      $mqtt_ha{$_}=1;
    }
    @mqtt_ha=();
    foreach $sec (keys %HA_DISCOVERY) {
      @dev=("${sec}01");
      if($sec eq "wallbox") {
        @dev=@wallbox;
      }
      elsif($sec eq "ev") {
        @dev=@ev;
      }
      foreach $dev (@dev) {
        %d=();
        @ent=@{$HA_DISCOVERY{$sec}};
	if($sec eq "wallbox") {
	  $device_name=$smart{$dev}{WALLBOX_MQTT_NAME};
	  if(length($device_name)==0) { $device_name="Wallbox01"; }
	  $device_id=Base($smart{$dev}{WALLBOX_MQTT_BASE},$dev);
	  if(length($device_id)==0) { $device_id="wallbox01"; }
	  $d{availability_topic}=MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,$MQTT_WALLBOX_BASE,$device_id,"availability");
	}
	elsif($sec eq "ev") {
	  $device_name=$smart{$ev}{EV_MQTT_NAME};
	  if(length($device_name)==0) { $device_name="EV01"; }
	  $device_id=Base($smart{$dev}{EV_MQTT_BASE},$dev);
	  if(length($device_id)==0) { $device_id="ev01"; }
	  $d{availability_topic}=MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,$MQTT_EV_BASE,$device_id,"availability");
	}
	elsif($sec eq "meter") {
	  $device_name=$MQTT_METER_NAME;
	  if(length($device_name)==0) { $device_name="Power Meter"; }
	  $device_id=$MQTT_METER_BASE;
	  if(length($device_id)==0) { $device_id="meter"; }
	  $device_id="${MQTT_TOPIC_PREFIX}_$device_id";
	  $d{availability_topic}=MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,"availability");
	}
	$d{device} = {
	  identifiers => $device_id,
	  name => $device_name,
	};
	if($sec eq "wallbox") {
	  # Add info, if available
	  AddInfo($d{device},"model",$WALLBOX_MODEL);
	  AddInfo($d{device},"manufacturer",$WALLBOX_VENDOR);
	  AddInfo($d{device},"sw_version",$WALLBOX_FIRMWARE);
	  AddInfo($d{device},"sn",(defined($WALLBOX_SERIAL)?$WALLBOX_SERIAL:$WALLBOX_SN));
	}
	$d{origin} = {
	  name => "OCPP/MQTT Perl Server",
	  sw => $VERSION,
	  url => "https://bonissi.it/ocpp/",
	};
	for($i=0;$i<=$#ent;$i++) {
	  %h=%{$ent[$i]};
	  $map=$h{map};
	  delete($h{map});
	  foreach $k (keys %h) {
	    if(ref($h{$k}) eq "") { # Only scalar
	      $h{$k}=~s/\{device_name\}/$device_name/g;
	      $h{$k}=~s/\{device_id\}/$device_id/g;
	      $h{$k}=~s/\{topic_prefix\}/$MQTT_TOPIC_PREFIX/g;
	      $h{$k}=~s/\{wallbox_base\}/$MQTT_WALLBOX_BASE/g;
	      $h{$k}=~s/\{meter_base\}/$MQTT_METER_BASE/g;
	      $h{$k}=~s/\{ev_base\}/$MQTT_EV_BASE/g;
	      foreach $base (qw(General Profile Grid Baseload Wallbox Ev))
	      {
	        $func="MQTT_Config${base}Base";
		eval { $val=&$func(); };
		$func=lc($base);
	        $h{$k}=~s/\{config_$func\}/$val/g;
	      }
	    }
	  }
	  # Change power/energy unit
	  if(defined($h{unit_of_measurement})) {
	    if($h{unit_of_measurement}=~m/Wh/) {
	      $h{unit_of_measurement}=$MQTT_ENERGY_UNIT;
	      if($MQTT_ENERGY_UNIT eq "kWh") {
		#$h{suggested_display_precision}=3;
	      }
	    }
	    elsif($h{unit_of_measurement}=~m/W/) {
	      $h{unit_of_measurement}=$MQTT_POWER_UNIT;
	      if($MQTT_ENERGY_UNIT eq "kW") {
		#$h{suggested_display_precision}=2;
	      }
	    }
	  }
	  my $addent=1;
	  if($sec eq "ev" && length($map)>0) {
	    # Check if the entity is defined
	    my ($e);
	    for($e=0;$e<=$#EV_MAP;$e++) {
	      if($map eq $EV_MAP[$e]{meas}) {
	        if(length(EvParam($EV_MAP[$e]{topic}))==0) {
		  $addent=0;
		}
	        last;
	      }
	    }
	  }
	  if($addent) {
	    %{$d{components}{$h{unique_id}}}=%h;
	  }
	}
	$topic=MQTT_ComposeTopic($HA_DISCOVERY_PREFIX,"device",$device_id,"config");
	$k=encode_json(\%d);
	MQTT_Retain($topic,$k);
	verbose(17,"HA TOPIC $topic => $k\n");
	push(@mqtt_ha,$topic);
	delete($mqtt_ha{$topic});
      }
    }
    foreach(keys %mqtt_ha) {
      if($mqtt_ha{$_}) {
        $mqtt->retain($_,undef);
      }
    }
  }
  else {
    MQTT_RemoveHA();
  }
}


sub MQTT_CheckConn
{
  if($MQTT_ENABLED) {
    if(defined($mqtt)) {
      if($mqtt_connected==1) {
        # Just Connected, re-subscribe
	MQTT_SubscribeAll();
      }
    }
    else {
      # To be connected
      $mqtt = Net::MQTT::Simple->new($MQTT_BROKER);
      if(defined($mqtt)) {
	if(length($MQTT_USERNAME)>0) {
	  if(length($MQTT_PASSWORD)>0) {
	    $ENV{MQTT_SIMPLE_ALLOW_INSECURE_LOGIN}=1;
	    $mqtt->login($MQTT_USERNAME,$MQTT_PASSWORD);
	  }
	  else {
	    $mqtt->login($MQTT_USERNAME);
	  }
	}
      }
      MQTT_SubscribeAll();
    }
  }
  else {
    if(defined($mqtt)) {
      # Unsubscribe and disconnect
      MQTT_UnsubscribeAll();
      MQTT_PublishAvailability(0);
      MQTT_RemoveHA();
      $mqtt->disconnect();
      undef($mqtt);
    }
  }
}

sub FILE_HandleTopic
{
  my($i,@s,$file,$message);
  for($i=0;$i<=$#subfile;$i++) {
    @s=stat($subfile[$i]);
    if($#s>0) {
      # OK, file found
      if($s[9]!=$substat[$i]) {
        # File updated, get content
	if(open(SF,$subfile[$i])) {
	  while(<SF>) {
	    $message.=$_;
	  }
	  close(SF);
	  if(length($message)>0) {
	    $substat[$i]=$s[9];
	    verbose(15,"File $subfile[$i] updated, calling callback\n");
	    if(substr("file:$subfile[$i]",0,length($METER_MQTT_PREFIX)) eq $METER_MQTT_PREFIX) {
	      meter_callback("file:$subfile[$i]",$message);
	    }
	    elsif(substr("file:$subfile[$i]",0,length($PV_MQTT_PREFIX)) eq $PV_MQTT_PREFIX) {
	      pv_callback("file:$subfile[$i]",$message);
	    }
	    elsif(substr("file:$subfile[$i]",0,length(EvParam("EV_MQTT_PREFIX"))) eq EvParam("EV_MQTT_PREFIX")) {
	      ev_callback("file:$subfile[$i]",$message);
	    }
	  }
	}
      }
    }
  }
}

sub MQTT_HandleTopic
{
  my($res,$now,$json);
  my($i,%payload,$pay,$e,$val,$param);
  $meter_counter=0;
  $pv_counter=0;
  $ev_counter=0;
  @ev_counter=();
  $grid_counter=0;
  if($MQTT_ENABLED && defined($mqtt)) {
    $res=$mqtt->tick($MAX_OCPP_MQTT_WAIT);
    $now=time();
    if(!defined($res)) {
      if($mqtt_connected>0) {
        verbose(4,"MQTT $MQTT_BROKER disconnected\n");
      }
      $mqtt_connected=0;
    }
    else {
      if($mqtt_connected<=0) {
        verbose(4,"Reconnection to $MQTT_BROKER\n");
        $mqtt_connected=1;
	MQTT_CheckConn();
      }

      if($meter_counter>0) {
        # Sleep a bit and get (possibly) remaining data
        MQTT_Flush(\$meter_counter);
	$meter_counter++;
      }

      if($pv_counter>0) {
        # Sleep a bit and get (possibly) remaining data
        MQTT_Flush(\$pv_counter);
	$pv_counter++;
      }

      if($ev_counter>0) {
        # Sleep a bit and get (possibly) remaining data
        MQTT_Flush(\$ev_counter);
	$ev_counter++;
      }

      if($grid_counter>0) {
        # Sleep a bit and get (possibly) remaining data
        MQTT_Flush(\$grid_counter);
	$grid_counter++;
      }

      if($MQTT_HEARTBEAT_INTERVAL==0) { $MQTT_HEARTBEAT_INTERVAL=30; }
      if(($now-$mqtt_last_heartbeat)>=$MQTT_HEARTBEAT_INTERVAL) {
        MQTT_PublishHeartbeat("");
	$mqtt_last_heartbeat=$now;
      }
      if($MQTT_STATUS_INTERVAL==0) { $MQTT_STATUS_INTERVAL=30; }
      if(($now-$mqtt_last_status)>=$MQTT_STATUS_INTERVAL) {
        MQTT_PublishAvailability(1);
	$mqtt_last_status=$now;
      }
    }
  }
  FILE_HandleTopic();
  if($meter_counter>0) {
    # Compose JSON message:
    $payload{type}="MeterTransfer";
    $payload{timestamp}=Zulu($now);
    $i=0;
    foreach (keys %meter) {
      my $unit="W";
      if(m/Voltage/) { $unit="V"; }
      elsif(m/Current/) { $unit="A"; }
      $payload{sampledValue}[$i]{measurand}=$_;
      $payload{sampledValue}[$i]{unit}=$unit;
      $payload{sampledValue}[$i]{value}=$meter{$_};
      $i++;
    }
    $json=encode_json(\%payload);
    verbose(15,"Calling DataTransfer '$json'\n");
    DataTransfer({"now"=>$now,"vendorId"=>"MQTT/FILE","messageId"=>"MQTTmeter","data"=>$json});
  }
  if($pv_counter>0) {
    # Compose JSON message:
    %payload=%pv;
    $payload{type}="PVTransfer";
    $payload{timestamp}=Zulu($now);
    $payload{timestamp_unix}=$now;
    # Keep the last value, if not defined in this round:
    foreach $i (keys %lastpv) {
      if(!defined($pv{$i})) {
        $payload{$i}=$lastpv{$i};
      }
    }
    $pay=encode_json(\%payload);
    verbose(15,"Calling PVDataTransfer '$pay'\n");
    PVDataTransfer(\%payload);
    %lastpv=%pv;
    %pv=();
  }
  if($ev_counter>0) {
    if($#ev==0) {
      # Only 1 EV, set as active
      $ev=$ev[0];
    }
  }
  for($e=0;$e<=$#ev;$e++) {
    if($ev_counter[$e]>0) {
      # Compose JSON message:
      %payload=%{$evmeas[$e]};
      $payload{type}="EVTransfer";
      $payload{timestamp}=Zulu($now);
      $payload{timestamp_unix}=$now;
      # Keep the last value, if not defined in this round:
      foreach $i (keys %{$lastev[$e]}) {
	if(!defined($evmeas[$e]{$i})) {
	  $payload{$i}=$lastev[$e]{$i};
	}
      }
      if(length($val=GetEvMeas("EV_MQTT_CHARGING",$ev[$e]))>0) {
	if($val!=0 || $val=~m/on|true/i) {
	  $val=1;
	}
      }
      elsif(length($val=GetEvMeas("EV_MQTT_AC_CURRENT",$ev[$e]))>0) {
        if($val>1) { $val=1; }
	else { $val=0; }
      }
      elsif(length($val=GetEvMeas("EV_MQTT_AC_POWER",$ev[$e]))>0) {
        if($val>300) { $val=1; }
	else { $val=0; }
      }
      elsif(length($val=GetEvMeas("EV_MQTT_CURRENT",$ev[$e]))>0) {
        if($val<-1 || $val>3) { $val=1; }
	else { $val=0; }
      }
      elsif(length($val=GetEvMeas("EV_MQTT_POWER",$ev[$e]))>0) {
        if(abs($val)>500) { $val=1; }
	else { $val=0; }
      }
      if($val) {
        # OK, EV is charging, set it as active
	$ev=$ev[$e];
      }
      $payload{charging}=$val;
      $pay=encode_json(\%payload);
      if(!$ev_online[$e]) {
	MQTT_Retain(MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,$MQTT_EV_BASE,Base($smart{$ev[$e]}{EV_MQTT_BASE},$ev[$e]),"availability"),"online");
      }
      $ev_online[$e]=$now;
      verbose(15,"Calling EVDataTransfer '$pay'\n");
      EVDataTransfer(\%payload,$ev[$e]);
      $pay=encode_json(\%payload);
      MQTT_Retain(MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,$MQTT_EV_BASE,Base($smart{$ev[$e]}{EV_MQTT_BASE},$ev[$e]),"status"),$pay);
      %{$lastev[$e]}=%{$ev[$e]};
      %{$ev[$e]}=();
    }
    elsif($ev_online[$e] && $CONNSTATUS==0 && ($now-$ev_online[$e])>EvParam("EV_MQTT_TIMEOUT",$ev[$e])) {
      MQTT_Retain(MQTT_ComposeTopic($MQTT_TOPIC_PREFIX,$MQTT_EV_BASE,Base($smart{$ev[$e]}{EV_MQTT_BASE},$ev[$e]),"availability"),"offline");
      EVDataTransfer({},$ev[$e]);
      %{$lastev[$e]}=();
      $ev_online[$e]=0
    }
  }
}

sub MQTT_Shutdown {
  $MQTT_ENABLED=0;
  MQTT_CheckConn();
}

# Reset EV_MAP cache on library change:
%EV_MAP=();

1;
