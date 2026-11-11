
import re


# Bedeutungen aus dem DOMUSA DUAL CLIMA HT Service Manual,
# Kapitel 11 "Error Management Procedure".
# Nicht im Handbuch beschriebene API-Codes bleiben unbekannt.

ERROR_CODES = {
    "e01": "Außentemperaturfühler defekt",
    "e02": "Temperaturfühler äußerer Wärmetauscher defekt",
    "e03": "Ansaugtemperaturfühler defekt",
    "e04": "Wärmepumpeneinstellung fehlerhaft",
    "e05": "Wärmepumpeneinstellung fehlerhaft",
    "e06": "Verdichter-Austrittstemperaturfühler defekt",
    "e07": "Warmwasser-Temperaturfühler defekt",
    "e08": "Vorlauftemperaturfühler defekt",
    "e09": "Rücklauftemperaturfühler defekt",
    "e10": "Temperaturfühler innerer Wärmetauscher defekt",

    "e11": "Hochdrucksensor defekt",
    "e12": "Niederdrucksensor defekt",
    "e13": "Hochdruckschutz",
    "e14": "Niederdruckschutz",
    "e15": "Wasserdurchfluss zu gering",
    "e16": "Kommunikationsfehler",
    "e17": "Verdichter-Gasaustrittstemperatur zu hoch",
    "e18": "Wärmepumpenkonfiguration fehlerhaft",
    "e20": "IPM- oder Verdichterfehler",
    "e21": "Spannungsfehler",
    "e22": "Temperaturdifferenz Vorlauf/Rücklauf zu groß",
    "e23": "Frostschutzfunktion Warmwasserbetrieb",
    "e24": "Frostschutzfunktion Heiz-/Kühlbetrieb",
    "e26": "Wärmepumpeneinstellung fehlerhaft",
    "e27": "Raumtemperatur überschreitet Grenzwert",
    "e28": "Rücklauftemperatur im Kühlbetrieb zu hoch",
    "e29": "Raumtemperaturfühler defekt",
    "e32": "Vorlauftemperatur zu hoch",
    "e36": "Lüfter-Kommunikationsfehler (Drehstrom)",
    "e40": "Rücklauftemperatur im Kühlbetrieb zu niedrig",
    "e44": "Lüftermotorfehler",
    "e50": "Temperatur äußerer Wärmetauscher zu hoch",
    "e56": "Überstromschutz",
    "e58": "Außentemperatur unterhalb des Grenzwerts",
    "e59": "Vorlauf-/Rücklauffühler vertauscht oder Vierwegeventil defekt",
    "e99": "Kommunikationsfehler mit dem IPM-Modul",

    "e20-1": "Überstrom im IPM",
    "e20-5": "Verdichterfehler",
    "e20-320": "Überstromschutz des Verdichters",
    "e20-288": "IPM-Temperatur zu hoch",
    "e20-384": "PFC-Modulfehler im IPM",
    "e20-32": "IPM-Spannung zu hoch",
    "e20-16": "IPM-Spannung zu niedrig",
    "e20-264": "AC-Spannungsschutz",
    "e20-260": "AC-Stromschutz des IPM",
    "e20-257": "Kommunikationsfehler des IPM",
}


def extract_active_errors(data):
    """
    Sucht aktive err_* Flags im DOMUSA-API-Payload.
    Beispiel:
      err_4_2_e20_320 -> E20-320
    """

    active = {}

    for key, value in data.items():
        if not key.startswith("err_"):
            continue

        # Die API liefert boolesche Werte.
        if value is not True and value != 1:
            continue

        match = re.search(r"_(e\d+(?:_\d+)?)$", key.lower())

        if not match:
            continue

        # API-Unterstrich in E20-Untercodes in Bindestrich umwandeln.
        code = match.group(1).replace("_", "-")
        description = ERROR_CODES.get(
            code,
            "Bedeutung in den vorliegenden Dokumenten nicht zugeordnet"
        )

        # Doppelte Codes, z. B. E44, nur einmal anzeigen.
        active[code.upper()] = description

    def sort_key(item):
        code = item[0].lower()
        numbers = re.findall(r"\d+", code)
        return tuple(int(number) for number in numbers)

    return [
        {
            "code": code,
            "description": description,
        }
        for code, description in sorted(
            active.items(),
            key=sort_key
        )
    ]


def get_error_summary(data):
    errors = extract_active_errors(data)

    if not errors:
        return {
            "error_active": False,
            "error_codes": "Kein aktiver Fehler",
            "error_description": "Kein aktiver Fehler",
        }

    return {
        "error_active": True,
        "error_codes": ", ".join(
            error["code"] for error in errors
        ),
        "error_description": "; ".join(
            f'{error["code"]}: {error["description"]}'
            for error in errors
        ),
    }
