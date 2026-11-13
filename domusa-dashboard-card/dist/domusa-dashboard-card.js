/*
 * DOMUSA Dashboard Card
 * Reads existing DOMUSA Bridge entities from Home Assistant.
 * No sensors, services, or backend polling are created by this card.
 */

const CARD_VERSION = "0.1.0";
const CARD_TYPE = "domusa-dashboard";
const UNIQUE_ID_PREFIX = "domusa_";

const SENSOR_DEFINITIONS = [
  { uid: "estado_func_c52", label: "Operating mode", group: "System", kind: "mode" },
  { uid: "demanda_hp", label: "Heat pump demand", group: "System", kind: "boolean" },
  { uid: "demanda_zona1", label: "Heating zone demand", group: "System", kind: "boolean" },
  { uid: "m_estadoacs", label: "DHW active", group: "System", kind: "boolean" },
  { uid: "heating_circuit_pump", label: "Heating circuit pump", group: "System", kind: "boolean" },

  { uid: "s_ext_c02", label: "Outdoor temperature", group: "Temperatures", unit: "°C" },
  { uid: "s_ida_hp_c08", label: "Heat pump flow", group: "Temperatures", unit: "°C" },
  { uid: "s_ret_hp_c07", label: "Heat pump return", group: "Temperatures", unit: "°C" },
  { uid: "s_buffer_c57", label: "Buffer temperature", group: "Temperatures", unit: "°C" },
  { uid: "s_acs_c09", label: "DHW temperature", group: "Temperatures", unit: "°C" },

  { uid: "st_buffer_c_p123", label: "Buffer target", group: "Setpoints", unit: "°C" },
  { uid: "st_c_p02", label: "Heating target", group: "Setpoints", unit: "°C" },
  { uid: "st_f_p03", label: "Cooling target", group: "Setpoints", unit: "°C" },
  { uid: "st_acs_p04", label: "DHW target", group: "Setpoints", unit: "°C" },

  { uid: "freq_c15", label: "Compressor frequency", group: "Refrigerant circuit", unit: "Hz" },
  { uid: "st_freq_c20", label: "Compressor frequency target", group: "Refrigerant circuit", unit: "Hz" },
  { uid: "curr_comp_c21", label: "Compressor current", group: "Refrigerant circuit", unit: "A" },
  { uid: "s_evap_c00", label: "Evaporator temperature", group: "Refrigerant circuit", unit: "°C" },
  { uid: "s_discharge_c01", label: "Discharge temperature", group: "Refrigerant circuit", unit: "°C" },
  { uid: "s_suction_c03", label: "Suction temperature", group: "Refrigerant circuit", unit: "°C" },
  { uid: "s_condens_c06", label: "Condenser temperature", group: "Refrigerant circuit", unit: "°C" },
  { uid: "s_pralta_c13", label: "High-side pressure", group: "Refrigerant circuit", unit: "bar", scale: 0.1 },
  { uid: "s_prbaja_c14", label: "Low-side pressure", group: "Refrigerant circuit", unit: "bar", scale: 0.1 },

  { uid: "s_q_c10", label: "Water flow", group: "Hydraulics", unit: "L/min" },
  { uid: "pwm_c1_c51", label: "Pump C1 speed", group: "Hydraulics", unit: "%" },
  { uid: "rpm_vent1_c16", label: "Fan 1 speed", group: "Hydraulics", unit: "rpm" },
  { uid: "rpm_vent2_c17", label: "Fan 2 speed", group: "Hydraulics", unit: "rpm" },
];

const MODE_LABELS = {
  "0": "Standby",
  "1": "Domestic hot water",
  "2": "Heating",
  "3": "Cooling",
};

const GROUP_ORDER = [
  "System",
  "Temperatures",
  "Setpoints",
  "Refrigerant circuit",
  "Hydraulics",
];

class DomusaDashboardCard extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: "open" });
    this._hass = undefined;
    this._config = {};
    this._registryConnection = undefined;
    this._registryPromise = undefined;
    this._entitiesByDevice = {};
    this._loading = false;
    this._error = "";
  }

  static getStubConfig() {
    return {};
  }

  setConfig(config) {
    if (!config || typeof config !== "object") {
      throw new Error("Invalid DOMUSA Dashboard configuration.");
    }
    this._config = config;
    this._render();
  }

  set hass(hass) {
    this._hass = hass;

    if (hass && hass.connection && hass.connection !== this._registryConnection) {
      this._registryConnection = hass.connection;
      this._registryPromise = undefined;
      this._entitiesByDevice = {};
      this._error = "";
      this._loadEntityRegistry();
    } else {
      this._render();
    }
  }

  getCardSize() {
    return 6;
  }

  async _loadEntityRegistry() {
    if (!this._hass || !this._hass.callWS || this._loading) return;

    this._loading = true;
    this._error = "";
    this._render();

    try {
      this._registryPromise = this._hass.callWS({
        type: "config/entity_registry/list",
      });

      const entries = await this._registryPromise;
      this._entitiesByDevice = this._mapBridgeEntities(entries);
      this._error = "";
    } catch (error) {
      this._error = error && error.message
        ? error.message
        : "The Home Assistant entity registry could not be read.";
      this._entitiesByDevice = {};
    } finally {
      this._loading = false;
      this._render();
    }
  }

  _mapBridgeEntities(entries) {
    const mapped = {};
    if (!Array.isArray(entries)) return mapped;

    for (const entry of entries) {
      if (!entry || !entry.unique_id || !entry.entity_id || entry.disabled_by) {
        continue;
      }

      const uniqueId = String(entry.unique_id);

      if (!uniqueId.startsWith(UNIQUE_ID_PREFIX)) {
        continue;
      }

      const definition = SENSOR_DEFINITIONS.find((item) =>
        uniqueId === item.uid || uniqueId.endsWith(`_${item.uid}`)
      );

      if (!definition) continue;

      let deviceId = "default";

      if (uniqueId !== definition.uid) {
        const suffix = `_${definition.uid}`;

        const withoutSuffix = uniqueId.endsWith(suffix)
          ? uniqueId.slice(0, -suffix.length)
          : uniqueId;

        deviceId = withoutSuffix.startsWith(UNIQUE_ID_PREFIX)
          ? withoutSuffix.slice(UNIQUE_ID_PREFIX.length) || "default"
          : withoutSuffix || "default";
      }

      if (!mapped[deviceId]) {
        mapped[deviceId] = {};
      }

      mapped[deviceId][definition.uid] = entry.entity_id;
    }

    return mapped;
  }

  _getState(deviceId, definition) {
    const entityId = this._entitiesByDevice[deviceId]?.[definition.uid];

    if (!entityId || !this._hass?.states) {
      return undefined;
    }

    return this._hass.states[entityId];
  }

  _formatValue(stateObj, definition) {
    if (!stateObj) return "Not found";

    const raw = stateObj.state;

    if (
      raw === "unknown" ||
      raw === "unavailable" ||
      raw === null ||
      raw === undefined
    ) {
      return raw === "unavailable" ? "Unavailable" : "Unknown";
    }

    if (definition.kind === "mode") {
      return MODE_LABELS[String(raw)] || `Code ${raw}`;
    }

    if (definition.kind === "boolean") {
      if (raw === "on" || raw === "true" || raw === "1") return "On";
      if (raw === "off" || raw === "false" || raw === "0") return "Off";
      return String(raw);
    }

    const numeric = Number(raw);

    if (!Number.isFinite(numeric)) {
      return String(raw);
    }

    const scaled = numeric * (definition.scale ?? 1);

    const value = new Intl.NumberFormat(undefined, {
      maximumFractionDigits: 1,
    }).format(scaled);

    const unit =
      definition.unit ||
      stateObj.attributes?.unit_of_measurement ||
      "";

    return unit ? `${value} ${unit}` : value;
  }

  _statusClass(stateObj, definition) {
    if (
      !stateObj ||
      stateObj.state === "unknown" ||
      stateObj.state === "unavailable"
    ) {
      return "muted";
    }

    if (definition.kind === "boolean") {
      return ["on", "true", "1"].includes(String(stateObj.state))
        ? "active"
        : "";
    }

    if (definition.kind === "mode") {
      return String(stateObj.state) === "0" ? "muted" : "active";
    }

    return "";
  }

  _render() {
    if (!this.shadowRoot) return;

    const devices = Object.keys(this._entitiesByDevice);

    const styles = `
      :host {
        display: block;
        color: var(--primary-text-color);
      }

      ha-card {
        overflow: hidden;
        border-radius: var(--ha-card-border-radius, 18px);
        background: var(--ha-card-background, var(--card-background-color));
      }

      .header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
        padding: 20px 20px 14px;
      }

      .heading {
        min-width: 0;
      }

      .title {
        font-size: 1.15rem;
        font-weight: 650;
        letter-spacing: .01em;
      }

      .subtitle {
        margin-top: 4px;
        color: var(--secondary-text-color);
        font-size: .82rem;
      }

      .version {
        color: var(--secondary-text-color);
        font-size: .68rem;
        white-space: nowrap;
      }

      .content {
        padding: 0 20px 20px;
      }

      .device + .device {
        margin-top: 22px;
        padding-top: 18px;
        border-top: 1px solid var(--divider-color);
      }

      .device-title {
        margin: 0 0 12px;
        color: var(--secondary-text-color);
        font-size: .78rem;
        font-weight: 650;
        letter-spacing: .09em;
        text-transform: uppercase;
      }

      .group + .group {
        margin-top: 18px;
      }

      .group-title {
        margin: 0 0 9px;
        font-size: .88rem;
        font-weight: 600;
      }

      .grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(min(100%, 145px), 1fr));
        gap: 9px;
      }

      .metric {
        min-width: 0;
        padding: 12px 13px;
        border: 1px solid var(--divider-color);
        border-radius: 13px;
        background: var(--secondary-background-color, rgba(127,127,127,.06));
      }

      .label {
        color: var(--secondary-text-color);
        font-size: .75rem;
        line-height: 1.35;
      }

      .value {
        margin-top: 7px;
        font-size: 1.12rem;
        font-weight: 650;
        line-height: 1.25;
        overflow-wrap: anywhere;
      }

      .value.active {
        color: var(--success-color, var(--primary-color));
      }

      .value.muted {
        color: var(--secondary-text-color);
        font-size: .96rem;
        font-weight: 550;
      }

      .message {
        padding: 18px 20px 20px;
        color: var(--secondary-text-color);
        font-size: .9rem;
        line-height: 1.5;
      }

      .error {
        color: var(--error-color);
      }

      .retry {
        margin-top: 12px;
        padding: 7px 12px;
        border: 1px solid var(--divider-color);
        border-radius: 9px;
        background: transparent;
        color: var(--primary-text-color);
        font: inherit;
        cursor: pointer;
      }

      @media (max-width: 420px) {
        .header {
          padding: 16px 16px 12px;
        }

        .content {
          padding: 0 16px 16px;
        }

        .grid {
          grid-template-columns: repeat(2, minmax(0, 1fr));
        }
      }
    `;

    let body = "";

    if (this._loading) {
      body = `
        <div class="message">
          Discovering DOMUSA Bridge entities…
        </div>
      `;
    } else if (this._error) {
      body = `
        <div class="message">
          <div class="error">Could not discover DOMUSA entities.</div>
          <div>${this._escapeHtml(this._error)}</div>
          <button class="retry" type="button">Retry discovery</button>
        </div>
      `;
    } else if (devices.length === 0) {
      body = `
        <div class="message">
          No DOMUSA Bridge entities were found in the Home Assistant
          entity registry. Check that the Bridge sensors are enabled
          and that their unique IDs use the <code>domusa_</code> prefix.
        </div>
      `;
    } else {
      body = `
        <div class="content">
          ${devices.map((deviceId) => this._renderDevice(deviceId)).join("")}
        </div>
      `;
    }

    this.shadowRoot.innerHTML = `
      <style>${styles}</style>

      <ha-card>
        <div class="header">
          <div class="heading">
            <div class="title">DOMUSA Dashboard</div>
            <div class="subtitle">Heat pump overview</div>
          </div>

          <div class="version">v${CARD_VERSION}</div>
        </div>

        ${body}
      </ha-card>
    `;

    const retry = this.shadowRoot.querySelector(".retry");

    if (retry) {
      retry.addEventListener("click", () => this._loadEntityRegistry());
    }
  }

  _renderDevice(deviceId) {
    const groups = GROUP_ORDER.map((groupName) => {
      const definitions = SENSOR_DEFINITIONS.filter(
        (item) => item.group === groupName
      );

      const availableDefinitions = definitions.filter(
        (item) => this._entitiesByDevice[deviceId]?.[item.uid]
      );

      if (!availableDefinitions.length) return "";

      const metrics = availableDefinitions.map((definition) => {
        const stateObj = this._getState(deviceId, definition);
        const value = this._formatValue(stateObj, definition);
        const statusClass = this._statusClass(stateObj, definition);

        return `
          <div class="metric">
            <div class="label">
              ${this._escapeHtml(definition.label)}
            </div>

            <div class="value ${statusClass}">
              ${this._escapeHtml(value)}
            </div>
          </div>
        `;
      }).join("");

      return `
        <section class="group">
          <h3 class="group-title">${this._escapeHtml(groupName)}</h3>
          <div class="grid">${metrics}</div>
        </section>
      `;
    }).join("");

    const deviceTitle = deviceId === "default"
      ? "DOMUSA heat pump"
      : `DOMUSA · ${deviceId}`;

    return `
      <section class="device">
        <h2 class="device-title">
          ${this._escapeHtml(deviceTitle)}
        </h2>

        ${groups}
      </section>
    `;
  }

  _escapeHtml(value) {
    return String(value).replace(/[&<>"']/g, (character) => ({
      "&": "&amp;",
      "<": "&lt;",
      ">": "&gt;",
      '"': "&quot;",
      "'": "&#39;",
    })[character]);
  }
}

if (!customElements.get(CARD_TYPE)) {
  customElements.define(CARD_TYPE, DomusaDashboardCard);
}

window.customCards = window.customCards || [];

if (!window.customCards.some((card) => card.type === CARD_TYPE)) {
  window.customCards.push({
    type: CARD_TYPE,
    name: "DOMUSA Dashboard",
    description: "Live overview for DOMUSA heat pumps using existing Bridge entities.",
    preview: false,
  });
}

console.info(
  `%c DOMUSA Dashboard %c ${CARD_VERSION} `,
  "color: white; background: #176b87; font-weight: bold;",
  "color: #176b87; background: transparent; font-weight: bold;"
);
