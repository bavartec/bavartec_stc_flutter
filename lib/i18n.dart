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

  dynamic _get() {
    return _localizedValues[locale.languageCode];
  }

  String get aboutContent => _get()['about']['content'] as String;

  String get advanced => _get()['advanced'] as String;

  String get again => _get()['again'] as String;

  Map<String, String> get apiRegister => _get()['api']['register'] as Map<String, String>;

  Map<String, String> get apiUnregister => _get()['api']['unregister'] as Map<String, String>;

  String get back => _get()['back'] as String;

  String get cancel => _get()['cancel'] as String;

  String get configMQTTFail => _get()['config']['mqtt']['fail'] as String;

  String get configMQTT_GDPR_Cancel => _get()['config']['mqtt']['gdpr']['cancel'] as String;

  String get configMQTT_GDPR_Reset => _get()['config']['mqtt']['gdpr']['reset'] as String;

  List<String> get configMQTT_GDPR_Submit => _get()['config']['mqtt']['gdpr']['submit'] as List<String>;

  String get configMQTTOk => _get()['config']['mqtt']['ok'] as String;

  String get configSensorChoose => _get()['config']['sensor']['choose'] as String;

  String get configSensorDIP => _get()['config']['sensor']['dip'] as String;

  List<String> get configSensorRecognized => _get()['config']['sensor']['recognized'] as List<String>;

  String get configSensorStart => _get()['config']['sensor']['start'] as String;

  String get configSensorWait => _get()['config']['sensor']['wait'] as String;

  String get configWifiConnect => _get()['config']['wifi']['connect'] as String;

  String get configWifiFail => _get()['config']['wifi']['fail'] as String;

  String get configWifiOk => _get()['config']['wifi']['ok'] as String;

  String get configWifiSmartconfig => _get()['config']['wifi']['smartconfig'] as String;

  String get confirmationRequired => _get()['confirmation']['required'] as String;

  String get confirmationRestart => _get()['confirmation']['restart'] as String;

  String get confirmationUpdate => _get()['confirmation']['update'] as String;

  String get doContinue => _get()['continue'] as String;

  String get controlNoLocal => _get()['control']['no-local'] as String;

  String get controlNoRemote => _get()['control']['no-remote'] as String;

  String get custom => _get()['custom'] as String;

  String get done => _get()['done'] as String;

  String get errorConnectionFailed => _get()['error']['connection-failed'] as String;

  String get errorMQTTConnectionFailed => _get()['error']['mqtt-connection-failed'] as String;

  String get errorMQTTNotSeeded => _get()['error']['mqtt-not-seeded'] as String;

  String get errorNoResponse => _get()['error']['no-response'] as String;

  String get errorPermissionRequired => _get()['error']['permission-required'] as String;

  List<String> get feedbackGDPR => _get()['feedback']['gdpr'] as List<String>;

  String get finish => _get()['finish'] as String;

  String get ok => _get()['ok'] as String;

  String get password => _get()['password'] as String;

  String get port => _get()['port'] as String;

  String get provider => _get()['provider'] as String;

  String get refresh => _get()['refresh'] as String;

  String get reset => _get()['reset'] as String;

  Map<String, String> get routes => _get()['routes'] as Map<String, String>;

  String get save => _get()['save'] as String;

  String get seeded => _get()['seeded'] as String;

  String get sensor => _get()['sensor'] as String;

  String get server => _get()['server'] as String;

  String get showPassword => _get()['show-password'] as String;

  String get ssid => _get()['ssid'] as String;

  String get start => _get()['start'] as String;

  String get stop => _get()['stop'] as String;

  String get submit => _get()['submit'][''] as String;

  String get submitFail => _get()['submit']['fail'] as String;

  String get submitOk => _get()['submit']['ok'][''] as String;

  String get submitOkLocal => _get()['submit']['ok']['local'] as String;

  String get submitOkRemote => _get()['submit']['ok']['remote'] as String;

  String get unknown => _get()['unknown'] as String;

  String get username => _get()['username'] as String;

  String get validatePass => _get()['validate']['pass'] as String;

  String get validatePort => _get()['validate']['port'] as String;

  String get validateServer => _get()['validate']['server'] as String;

  String get validateUser => _get()['validate']['user'] as String;

  List<String> get weekdays => _get()['weekdays'] as List<String>;
}

const Map<String, dynamic> _localizedValues = <String, dynamic>{
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
        'password-invalid': "password invalid; must be 8-32 ASCII characters (letters, digits, special symbols)",
        'success': "registration completed",
        'username-conflict': "username already taken or password wrong",
        'username-invalid': "username invalid; must be 8-32 letters and/or digits",
      },
      'unregister': {
        'no-response': "no response",
        'success': "registration canceled",
        'unknown-username': "username not registered",
        'wrong-password': "wrong password",
      },
    },
    'back': "Back",
    'cancel': "Cancel",
    'config': {
      'mqtt': {
        'fail': "MQTT config failed, please try again",
        'gdpr': {
          'cancel': """
Do you wish to withdraw your consent and cancel your MQTT registration?
Due to caching, our server might still accept your credentials for some time.""",
          'reset': """
When resetting this form, you can withdraw your consent to the processing of your data,
in the context of the usage of our MQTT server, if such was previously given.""",
          'submit': [
            """
By submitting this form, you're giving your consent to the processing of your data,
in the context of the usage of our MQTT server, on the basis of Art. 6 para. 1 lit. a GDPR.
Please refer to our """,
            "privacy policy",
            " for more information on how we process data.",
          ],
        },
        'ok': "MQTT config successful",
      },
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
        'fail': "Wifi config failed, please try again",
        'ok': "Wifi config successful",
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
    'control': {
      'no-local': "Wifi not configured",
      'no-remote': "MQTT not configured",
    },
    'custom': "Custom",
    'done': "Done",
    'error': {
      'connection-failed': "connection failed",
      'mqtt-connection-failed': "connection to MQTT server failed",
      'mqtt-not-seeded': "MQTT did not synchronize the device MAC yet",
      'no-response': "no response",
      'permission-required': "permission required",
    },
    'feedback': {
      'gdpr': [
        """
By submitting this form, you're giving your consent to the processing of your data,
so that we can process your request, on the basis of Art. 6 para. 1 lit. a GDPR.
Please refer to our """,
        "privacy policy",
        " for more information on how we process data.",
      ],
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
      '/privacy': "Privacy",
      '/restart': "Restart",
      '/update': "Update",
    },
    'save': "Save",
    'seeded': "device data synced",
    'sensor': "Sensor",
    'server': "Server",
    'show-password': "Show password",
    'ssid': "SSID",
    'start': "Start",
    'stop': "Stop",
    'submit': {
      '': "Submit",
      'fail': "submit failed, please try again",
      'ok': {
        '': "submit successful",
        'local': "local submit successful",
        'remote': "MQTT submit successful",
      },
    },
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
        'password-invalid': "Passwort ungültig; muss 8-32 ASCII Zeichen sein (Buchstaben, Ziffern, Sonderzeichen)",
        'success': "Registrierung abgeschlossen",
        'username-conflict': "Nutzername bereits vergeben oder Passwort falsch",
        'username-invalid': "Nutzername ungültig; muss 8-32 Buchstaben und/oder Ziffern sein",
      },
      'unregister': {
        'no-response': "Keine Antwort",
        'success': "Registrierung aufgehoben",
        'unknown-username': "Nutzername nicht registriert",
        'wrong-password': "Falsches Passwort",
      },
    },
    'back': "Zurück",
    'cancel': "Abbrechen",
    'config': {
      'mqtt': {
        'fail': "Konfiguration MQTT fehlgeschlagen, bitte erneut versuchen",
        'gdpr': {
          'cancel': """
Wünschen Sie, ihre Einwilligung zu widerrufen und ihre MQTT-Registrierung aufzuheben?
Aufgrund von Caching akzeptiert unser Server möglicherweise noch für eine Weile ihre Zugangsdaten.""",
          'reset': """
Beim Zurücksetzen dieses Formulars können Sie ihre Einwilligung zur Verarbeitung ihrer Daten widerrufen,
im Rahmen der Nutzung unseres MQTT-Servers, falls eine solche zuvor abgegeben wurde.""",
          'submit': [
            """
Durch das Absenden dieses Formulars geben Sie ihre Einwilligung zur Verarbeitung ihrer Daten ab,
im Rahmen der Nutzung unseres MQTT-Servers, auf der Grundlage von Art. 6 Abs. 1 lit. 1 DSGVO.
Bitte entnehmen sie unserer """,
            "Datenschutzerklärung",
            " weitere Informationen dazu, wie wir Daten verarbeiten.",
          ],
        },
        'ok': "Konfiguration MQTT erfolgreich",
      },
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
        'fail': "Konfiguration Wifi fehlgeschlagen, bitte erneut versuchen",
        'ok': "Konfiguration Wifi erfolgreich",
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
    'control': {
      'no-local': "WLAN nicht eingerichtet",
      'no-remote': "MQTT nicht eingerichtet",
    },
    'custom': "Benutzerdefiniert",
    'done': "Erledigt",
    'error': {
      'connection-failed': "Verbindung fehlgeschlagen",
      'mqtt-connection-failed': "Verbindung zum MQTT-Server fehlgeschlagen",
      'mqtt-not-seeded': "MQTT hat die Geräte-MAC noch nicht synchronisiert",
      'no-response': "Keine Antwort",
      'permission-required': "Berechtigung erforderlich",
    },
    'feedback': {
      'gdpr': [
        """
Durch das Absenden dieses Formulars geben Sie ihre Einwilligung zur Verarbeitung ihrer Daten,
damit wir Ihre Anfrage bearbeiten können, auf der Grundlage von Art. 6 Abs. 1 lit. 1 DSGVO.
Bitte entnehmen sie unserer """,
        "Datenschutzerklärung",
        " weitere Informationen dazu, wie wir Daten verarbeiten.",
      ],
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
      '/privacy': "Datenschutz",
      '/restart': "Neustart",
      '/update': "Update",
    },
    'save': "Speichern",
    'seeded': "Geräte-Daten synchronisiert",
    'sensor': "Sensor",
    'server': "Server",
    'show-password': "Passwort anzeigen",
    'ssid': "SSID",
    'start': "Start",
    'stop': "Stop",
    'submit': {
      '': "Senden",
      'fail': "Senden fehlgeschlagen, bitte erneut versuchen",
      'ok': {
        '': "Senden erfolgreich",
        'local': "Senden lokal erfolgreich",
        'remote': "Senden über MQTT erfolgreich",
      },
    },
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
