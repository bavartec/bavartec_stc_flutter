import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyLocalizationsDelegate extends LocalizationsDelegate<MyLocalizations> {
  const MyLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => _localizedValues.containsKey(locale.languageCode);

  @override
  Future<MyLocalizations> load(final Locale locale) {
    return SynchronousFuture<MyLocalizations>(MyLocalizations(locale));
  }

  @override
  bool shouldReload(MyLocalizationsDelegate old) => false;
}

class MyLocalizations {
  MyLocalizations(this.locale);

  final Locale locale;

  static MyLocalizations of(final BuildContext context) {
    return Localizations.of<MyLocalizations>(context, MyLocalizations);
  }

  Map<String, dynamic> _get() {
    return _localizedValues[locale.languageCode];
  }

  String get aboutContent => _get()['about']['content'];

  String get advanced => _get()['advanced'];

  String get again => _get()['again'];

  Map<String, String> get apiRegister => _get()['api']['register'];

  String get back => _get()['back'];

  String get cancel => _get()['cancel'];

  String get configSensorChoose => _get()['config']['sensor']['choose'];

  String get configSensorDIP => _get()['config']['sensor']['dip'];

  List<String> get configSensorRecognized => _get()['config']['sensor']['recognized'];

  String get configSensorStart => _get()['config']['sensor']['start'];

  String get configSensorWait => _get()['config']['sensor']['wait'];

  String get configWifiConnect => _get()['config']['wifi']['connect'];

  String get configWifiSmartconfig => _get()['config']['wifi']['smartconfig'];

  String get confirmationRequired => _get()['confirmation']['required'];

  String get confirmationRestart => _get()['confirmation']['restart'];

  String get confirmationUpdate => _get()['confirmation']['update'];

  String get doContinue => _get()['continue'];

  String get custom => _get()['custom'];

  String get done => _get()['done'];

  String get errorConnectionFailed => _get()['error']['connection-failed'];

  String get errorMQTTConnectionFailed => _get()['error']['mqtt-connection-failed'];

  String get errorNoResponse => _get()['error']['no-response'];

  String get errorPermissionRequired => _get()['error']['permission-required'];

  String get finish => _get()['finish'];

  String get ok => _get()['ok'];

  String get password => _get()['password'];

  String get port => _get()['port'];

  String get provider => _get()['provider'];

  String get refresh => _get()['refresh'];

  String get reset => _get()['reset'];

  Map<String, String> get routes => _get()['routes'];

  String get save => _get()['save'];

  String get sensor => _get()['sensor'];

  String get server => _get()['server'];

  String get showPassword => _get()['show-password'];

  String get ssid => _get()['ssid'];

  String get start => _get()['start'];

  String get stop => _get()['stop'];

  String get submit => _get()['submit'];

  String get submitOk => _get()['submit-ok'];

  String get submitFail => _get()['submit-fail'];

  String get unknown => _get()['unknown'];

  String get username => _get()['username'];

  String get validatePass => _get()['validate']['pass'];

  String get validatePort => _get()['validate']['port'];

  String get validateServer => _get()['validate']['server'];

  String get validateUser => _get()['validate']['user'];

  List<String> get weekdays => _get()['weekdays'];
}

const Map<String, Map<String, dynamic>> _localizedValues = {
  'en': {
    'about': {
      'content': """
Developed and imported by
BavarTec UG (haftungsbeschränkt),
Kapellenweg 10 D, 94575 Windorf, Germany
E-Mail: bavartec@gmail.com
Web: https://www.bavartec.de""",
    },
    'advanced': "Advanced",
    'again': "Again",
    'api': {
      'register': {
        'no-response': "no response",
        'password-invalid': "password invalid",
        'success': "registration completed",
        'username-conflict': "username already taken",
        'username-invalid': "username invalid",
      },
    },
    'back': "Back",
    'cancel': "Cancel",
    'config': {
      'sensor': {
        'choose': """
What is the outside temperature?
Hint: Read the outside sensor temperature off your heater.""",
        'dip': "Set the switches as shown:",
        'recognized': ["Your temperature sensor was recognized as ", ""],
        'start': """
Smart Thermo Control is compatible with a great variety of temperature sensors.
For the device to work properly, the exact type must first be determined.
In what follows, you will be asked to set the switches below as shown in each case.""",
        'wait': "Please wait a moment ...",
      },
      'wifi': {
        'connect': "please connect to Wifi",
        'smartconfig': """
Please press the button "T1" on the device. When the LED "LED1" is flashing, tap "Submit".""",
      },
    },
    'confirmation': {
      'required': "Confirmation required",
      'restart': "Confirm to restart device firmware?",
      'update': "Confirm to update device firmware?",
    },
    'continue': "Continue",
    'custom': "Custom",
    'done': "Done",
    'error': {
      'connection-failed': "connection failed",
      'mqtt-connection-failed': "connection to MQTT server failed",
      'no-response': "no response",
      'permission-required': "permission required",
    },
    'finish': "Finish",
    'ok': "OK",
    'password': "Password",
    'provider': "Provider",
    'port': "Port",
    'refresh': "Refresh",
    'reset': "Reset",
    'routes': {
      '/': "BavarTec STC",
      '/about': "About Us",
      '/config': "Config",
      '/config/mqtt': "Config MQTT",
      '/config/sensor': "Config Sensor",
      '/config/wifi': "Config WiFi",
      '/control': "Control",
      '/debug': "Debug",
      '/debug/listen': "Listen",
      '/debug/query': "Query",
      '/feedback': "Feedback",
      '/restart': "Restart",
      '/update': "Update",
    },
    'save': "Save",
    'sensor': "Sensor",
    'server': "Server",
    'show-password': "Show password",
    'ssid': "SSID",
    'start': "Start",
    'stop': "Stop",
    'submit': "Submit",
    'submit-ok': "submit successful",
    'submit-fail': "submit failed, please retry",
    'unknown': "Unknown",
    'username': "Username",
    'validate': {
      'pass': "password must not be empty",
      'port': "port must be a positive integer",
      'server': "server must be a domain or IP address",
      'user': "username must not be empty",
    },
    'weekdays': ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
  },
  'de': {
    'about': {
      'content': """
Entwickelt und importiert durch
BavarTec UG (haftungsbeschränkt),
Kapellenweg 10 D, 94575 Windorf, Deutschland
E-Mail: bavartec@gmail.com
Web: https://www.bavartec.de""",
    },
    'advanced': "Erweitert",
    'again': "Nochmal",
    'api': {
      'register': {
        'no-response': "Keine Antwort",
        'password-invalid': "Passwort ungültig",
        'success': "Registrierung abgeschlossen",
        'username-conflict': "Nutzername bereits vergeben",
        'username-invalid': "Nutzername ungültig",
      },
    },
    'back': "Zurück",
    'cancel': "Abbrechen",
    'config': {
      'sensor': {
        'choose': """
Welche Temperatur hat es gerade draußen?
Hinweis: Lesen Sie die Außenfühlertemperatur an Ihrer Heizung ab.""",
        'dip': "Stellen Sie die Schalter wie dargestellt ein:",
        'recognized': ["Ihr Außenfühler wurde als ", " erkannt."],
        'start': """
Smart Thermo Control ist kompatibel mit einer großen Vielzahl an Außenfühlern.
Damit das Gerät richtig arbeiten kann, muss zunächst der genaue Typ ermittelt werden.
Im folgenden werden Sie aufgefordert, die untenstehenden Schalter wie jeweils gezeigt einzustellen.""",
        'wait': "Bitte einen kurzen Moment Geduld ...",
      },
      'wifi': {
        'connect': "Bitte mit WLAN verbinden",
        'smartconfig': """
Bitte betätigen Sie den Knopf "T1" auf dem Gerät. Wenn die LED "LED1" leuchtet, tippen sie auf "Senden".""",
      },
    },
    'confirmation': {
      'required': "Bestätigung erforderlich",
      'restart': "Bestätigen, die Geräte-Firmware neuzustarten?",
      'update': "Bestätigen, die Geräte-Firmware zu aktualisieren?",
    },
    'continue': "Weiter",
    'custom': "Benutzerdefiniert",
    'done': "Erledigt",
    'error': {
      'connection-failed': "Verbindung fehlgeschlagen",
      'mqtt-connection-failed': "Verbindung zum MQTT-Server fehlgeschlagen",
      'no-response': "Keine Antwort",
      'permission-required': "Berechtigung erforderlich",
    },
    'finish': "Fertig",
    'ok': "OK",
    'password': "Passwort",
    'provider': "Anbieter",
    'port': "Port",
    'refresh': "Aktualisieren",
    'reset': "Zurücksetzen",
    'routes': {
      '/': "BavarTec STC",
      '/about': "Über Uns",
      '/config': "Konfiguration",
      '/config/mqtt': "Konfiguration MQTT",
      '/config/sensor': "Konfiguration Sensor",
      '/config/wifi': "Konfiguration WLAN",
      '/control': "Steuerung",
      '/debug': "Debug",
      '/debug/listen': "Listen",
      '/debug/query': "Query",
      '/feedback': "Feedback",
      '/restart': "Neustart",
      '/update': "Update",
    },
    'save': "Speichern",
    'sensor': "Sensor",
    'server': "Server",
    'show-password': "Passwort anzeigen",
    'ssid': "SSID",
    'start': "Start",
    'stop': "Stop",
    'submit': "Senden",
    'submit-ok': "Senden erfolgreich",
    'submit-fail': "Senden fehlgeschlagen, bitte erneut versuchen",
    'unknown': "Unbekannt",
    'username': "Nutzername",
    'validate': {
      'pass': "Passwort darf nicht leer sein",
      'port': "Port muss eine positive Ganzzahl sein",
      'server': "Server muss eine Domain oder IP-Adresse sein",
      'user': "Nutzername darf nicht leer sein",
    },
    'weekdays': ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"],
  },
};
List<Locale> supportedLocales = _localizedValues.keys.map((langCode) => Locale(langCode)).toList();
