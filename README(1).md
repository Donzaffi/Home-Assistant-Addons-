<!--
SPDX-FileCopyrightText: 2023-2024 Luca Bonissi <wallbox@bonissi.it>

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# OCPP-MQTT Perl Server

This is a simple OCPP/MQTT server for EVSE Chargers, written in Perl.

It also handle dynamic load management, allowing to change the maximum power
fetched from grid based on hour/day.

## Italian ARERA sperimentation ready

This server is ready for Italian ARERA sperimentation, where the available power 
of your grid connection could be freely increased to 6.05 kW in F3 (Monday-Saturday 23-7, Sunday and Holidays all the day).


## Handling of Italian Open Meter 2.0 +33% "bonus"

Italian Open Meter 2.0 allows to use 33% more of contractual power for 3 consecutive hours.
To "reset" the bonus, you have to pause at least 10% of the time you use more than available power.

This server automatically handles the bonus and reduces the charging power for the time needed.

## Integration with Home Assistant by MQTT

This server allow to easily integrate with Home Assistant and/or with devices (meters, wallboxes, etc.) compatibile with MQTT protocol.

The command are sub-topic of ocpp/wallbox/wallbox01/cmd/
The value must be JSON with the field "command" coerent with the sub-topic.
The result of the command will be published in ocpp/wallbox/wallbox01/cmd/result

List of commands:
- start: { "command": "start", "idTag": "RFIDTAG", "force": 1}

  "idTag" is optional, useful to select a profile. If "idTag" not specified or empty, it will be used the power limit set by "set_limit" parameter.
  The command will be rejected if a session was already started and it was not started by MQTT/HA. This restriction could be override by "force" parameter.
- stop: { "command": "stop", "force": 1}
  
  The command will be rejected if the active was not started by MQTT/HA. This restriction could be override by "force" parameter.
- reset: { "command": "reset", "type": "Hard/Soft", "force": 1}

  "force" is optional and used to force reset even if charging is in progress.
- unlock: { "command": "unlock", "force": 1}

  "force" is optional and used to force connector unlock even if charging is in progress.
- set_limit: { "command": "set_limit", "limit": 10}

  To set maximum charging current/power. If the value is not empty and not negative, and the session was started by "start" MQTT command without idTag, charging profiles will be disabled
  and this values is used as "FIXED" value.
  If "StopTransaction" message will be received, this limit will not be more valid unless the next session will be started by "start" MQTT command without idTag.
- max_energy: { "command": "max_energy", "energy": 40000, "reset_after_stop": 1}

  Set maximum energy charged for each session (including sub-sessions). 
  Energy could be specified in Wh (no suffix required if value >=1000) or in kWh (no suffix required if value <1000)
  
- trigger: { "command": "trigger", "message": "BootNotification|StatusNotification|MeterValues"}

  Trigger an OCPP message.
- reconf: { "command": "reconf" }

  Reload configuration and rebuild MQTT tree.
  

## License

This code is [REUSE compliant](https://reuse.software), so all
copyright and licensing information is stored within the files
themselves, or can be extracted with the REUSE helper tool.
