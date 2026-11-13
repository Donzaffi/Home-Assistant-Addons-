# Domusa MQTT Bridge

[![GitHub Issues](https://img.shields.io/github/issues/Donzaffi/Home-Assistant-Addons-)](https://github.com/Donzaffi/Home-Assistant-Addons-/issues)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

The **Domusa MQTT Bridge** is a Home Assistant add-on that connects your Domusa heating system to your local MQTT broker.

It retrieves heating system data from the Domusa cloud API and publishes it via MQTT. Home Assistant can then automatically discover the available entities for monitoring, dashboards and automations.

## Features

- **Domusa Cloud API:** Retrieves operating data, configuration values, counters and energy statistics from your Domusa heating system.
- **MQTT Integration:** Publishes the retrieved data to your local MQTT broker.
- **Home Assistant MQTT Discovery:** Automatically creates the available sensors and control entities in Home Assistant.
- **Device Controls:** Supports changing selected heating system parameters through MQTT.
- **Automatic Status Updates:** Regularly retrieves and publishes updated system data.
- **Status Refresh After Commands:** Refreshes the published status after a successful parameter change.
- **Error Information:** Provides information about active Domusa system errors.
- **Multilingual Entity Names:** Choose English, German or Spanish for the Home Assistant entity names.

### Multiple Devices – Beta

Support for multiple Domusa heating systems is currently under development and available as a **beta version on a separate GitHub branch**.

This functionality is not part of the stable main branch. It is intended for testing and feedback and should be considered experimental.

Users who want to test the multi-device version must switch to the corresponding beta branch. The stable main branch remains separate.

## Requirements

- Home Assistant with add-on support
- An MQTT broker, for example the Mosquitto Broker add-on
- A Domusa heating system supported by the Domusa cloud API
- A valid Domusa cloud account
- An active internet connection

**Important:** This integration depends on the Domusa cloud service. It does not communicate with the heating system exclusively over the local network.

## Installation

1. Open **Settings → Apps** in Home Assistant.
2. Open the three-dot menu in the upper-right corner.
3. Select **Repositories**.
4. Add the following repository URL:

   `https://github.com/Donzaffi/Home-Assistant-Addons-`

5. Click **Add** and close the dialog.
6. Find **Domusa MQTT Bridge** in the add-on store.
7. Install the add-on.

The installation above refers to the stable version on the main branch.

## Configuration

After installation, open the add-on's **Configuration** tab and enter your settings.

| Option | Description | Default |
|---|---|---|
| `username` | Email address of your Domusa account | — |
| `password` | Password of your Domusa account | — |
| `mqtt_host` | Hostname of your MQTT broker | `core-mosquitto` |
| `mqtt_port` | MQTT broker port | `1883` |
| `mqtt_user` | MQTT username, if authentication is required | — |
| `mqtt_password` | MQTT password, if authentication is required | — |
| `language` | Language used for entity names: `en`, `de` or `es` | `en` |
| `poll_interval` | Interval between status updates, in seconds | `60` |

The MQTT broker must be reachable from the add-on. If your broker requires authentication, enter the corresponding MQTT username and password.

## Language Selection

The add-on supports three languages:

- `en` – English
- `de` – German
- `es` – Spanish

English is the default language and is also used as a fallback if an unsupported language is encountered.

The selected language controls the names published through Home Assistant MQTT Discovery. It applies to the entities created by this add-on.

**Note:** Changing the language does not automatically translate custom entity names that you have already assigned in Home Assistant. Depending on Home Assistant's existing MQTT Discovery entries, you may need to reload or recreate the affected entities to see the updated names.

## Home Assistant Integration

After the add-on starts successfully and connects to MQTT, it publishes its discovery information.

The discovered entities should appear under:

**Settings → Devices & Services → MQTT**

No manual sensor configuration should be necessary.

The add-on provides information from the heating system, including:

- Operating status
- Temperatures and target values
- Configuration values
- Counters
- Energy statistics
- Error information
- Supported control entities

The available information depends on the data supplied by the Domusa cloud API and the capabilities of the connected heating system.

Selected parameters can also be changed using the discovered control entities.

## MQTT Topics

The bridge uses the following device-specific MQTT topics:

| Topic | Purpose |
|---|---|
| `domusa/<device_id>/status` | Published heating system status and data |
| `domusa/<device_id>/set` | Receives commands to change supported parameters |
| `domusa/<device_id>/set/result` | Reports the result of parameter change commands |

`<device_id>` is a placeholder for the ID of the respective Domusa heating system.

### Sending Commands

To change a supported parameter, publish a JSON message to the device's `set` topic.

Example:

```json
{
  "parameter": "hyst_acs_p07",
  "value": 10
}
```

The bridge processes the command and publishes the result to the corresponding `set/result` topic.

Only supported parameters and valid values are accepted.

## Troubleshooting

If no entities appear in Home Assistant, check the following:

1. Make sure the Domusa account credentials are correct.
2. Check that the MQTT broker is running.
3. Verify the MQTT host and authentication settings.
4. Check the add-on logs for connection or API errors.
5. Make sure the MQTT integration is configured in Home Assistant.

If the connection to the Domusa cloud API fails, check your internet connection and Domusa account access.

## Support and Issues

If you encounter a problem or want to report a bug, please open an issue on GitHub:

[Domusa MQTT Bridge – GitHub Issues](https://github.com/Donzaffi/Home-Assistant-Addons-/issues)

When reporting an issue, include relevant add-on logs and a description of the problem. Remove passwords, access tokens and personal device identifiers before sharing logs.

## Disclaimer

This project is an independent community integration and is not officially affiliated with or supported by Domusa.

Use the controls carefully. Changing heating system parameters may affect the operation of your heating installation.

## License

This project is licensed under the MIT License.
