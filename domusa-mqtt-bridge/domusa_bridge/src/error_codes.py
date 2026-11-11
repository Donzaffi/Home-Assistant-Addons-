
import re

ERROR_CODES = {
    "e01": "Außentemperaturfühler defekt",
    "e02": "Temperaturfühler äußerer Wärmetauscher defekt",
    "e03": "Ansaugtemperaturfühler defekt",
    "e04": "Wärmepumpenkonfiguration fehlerhaft",
    "e05": "Wärmepumpenkonfiguration fehlerhaft",
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
    "e23": "Frostschutz Warmwasserbetrieb",
    "e24": "Frostschutz Heiz-/Kühlbetrieb",
    "e26": "Wärmepumpeneinstellung fehlerhaft",
    "e27": "Raumtemperatur überschreitet Grenzwert",
    "e28": "Rücklauftemperatur im Kühlbetrieb zu hoch",
    "e29": "Raumtemperaturfühler defekt",
    "e32": "Vorlauftemperatur zu hoch",
    "e36": "Lüfter-Kommunikationsfehler",
    "e40": "Rücklauftemperatur im Kühlbetrieb zu niedrig",
    "e44": "Lüftermotorfehler",
    "e50": "Temperatur äußerer Wärmetauscher zu hoch",
    "e56": "Überstromschutz",
    "e58": "Außentemperatur unterhalb des Grenzwerts",
    "e59": "Vorlauf/Rücklauf vertauscht oder Vierwegeventil defekt",
    "e99": "Kommunikationsfehler IPM-Modul",

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
    active = []

    for key, value in data.items():
        if not key.startswith("err_"):
            continue

        if value not in (True, 1):
            continue

        match = re.search(
            r"_(e\d+(?:_\d+)?)$",
            key.lower()
        )

        if not match:
            continue

        # API: e20_320 -> Dokumentationsformat: e20-320
        code = match.group(1).replace("_", "-")
        description = ERROR_CODES.get(
            code,
            "Unbekannter Fehlercode – Dokumentation fehlt"
        )

        active.append({
            "code": code.upper(),
            "description": description,
            "source_key": key,
        })

    # E44 kann über mehrere API-Flags kommen.
    # Gleiche Fehlercodes nur einmal ausgeben.
    unique = {}
    for error in active:
        unique[error["code"]] = error

    return sorted(
        unique.values(),
        key=lambda error: error["code"]
    )


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
