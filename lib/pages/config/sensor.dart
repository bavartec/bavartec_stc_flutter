import 'package:bavartec_stc/api.dart';
import 'package:bavartec_stc/common.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<String> sensors = <String>[
  'UNKNOWN',
  'NTC1K',
  'NTC2K',
  'NTC5K',
  'NTC10K',
  'NTC20K',
  'PT100',
  'PT500',
  'PT1000',
  'NI100',
  'NI500',
  'NI1000',
  'NI1000TK5000',
  'KTY1K',
  'KTY2K',
];

typedef StateCallback = void Function(Widget stateChild);

class MyConfigSensorPage extends StatefulWidget {
  MyConfigSensorPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyConfigSensorPageState createState() => _MyConfigSensorPageState();
}

class _MyConfigSensorPageState extends MyState<MyConfigSensorPage> {
  String sensor;
  Widget stateChild;

  void _onLoad() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String sensor = prefs.getString("/config/sensor/sensor");

    if (sensor == null) {
      setState(() {
        stateChild = _MyConfigSensorPageStart(
          onStateChanged: _onStateChanged,
        );
      });
      return;
    }

    setState(() {
      this.sensor = sensor;
      stateChild = _MyConfigSensorPageEnd(
        sensor: sensor,
        onStateChanged: _onStateChanged,
      );
    });
  }

  void _onStateChanged(final Widget stateChild) {
    setState(() {
      this.stateChild = stateChild;
    });
  }

  @override
  void initState() {
    super.initState();
    _onLoad();
  }

  @override
  Widget build(final BuildContext context) {
    return scaffold(
      widget.title,
      Padding(
        padding: const EdgeInsets.all(40.0),
        child: this.stateChild,
      ),
    );
  }
}

class _MyConfigSensorPageStart extends StatefulWidget {
  _MyConfigSensorPageStart({
    @required this.onStateChanged,
  });

  final StateCallback onStateChanged;

  @override
  _MyConfigSensorPageStartState createState() => _MyConfigSensorPageStartState();
}

class _MyConfigSensorPageStartState extends MyState<_MyConfigSensorPageStart> {
  @override
  Widget build(final BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text("""
Smart Thermo Control ist kompatibel mit einer großen Vielzahl an Außenfühlern.
Damit das Gerät richtig arbeiten kann, muss zunächst der genaue Typ ermittelt werden.
Im folgenden werden Sie aufgefordert, die untenstehenden Schalter wie jeweils gezeigt einzustellen."""),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300.0),
            child: Image.asset(
              "assets/manual/dip/zero.png",
              alignment: Alignment.center,
              repeat: ImageRepeat.noRepeat,
              matchTextDirection: false,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: OutlineButton(
            borderSide: const BorderSide(),
            onPressed: () {
              Api.control(enabled: false);
              widget.onStateChanged(
                _MyConfigSensorPageLoop(
                  onStateChanged: widget.onStateChanged,
                ),
              );
            },
            child: const Text("Weiter"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: OutlineButton(
            borderSide: const BorderSide(),
            onPressed: () {
              widget.onStateChanged(
                _MyConfigSensorPageX(
                  onStateChanged: widget.onStateChanged,
                ),
              );
            },
            child: const Text("Erweitert"),
          ),
        ),
      ],
    );
  }
}

class _MyConfigSensorPageLoop extends StatefulWidget {
  _MyConfigSensorPageLoop({
    @required this.onStateChanged,
  });

  final StateCallback onStateChanged;

  @override
  _MyConfigSensorPageLoopState createState() => _MyConfigSensorPageLoopState();
}

class _MyConfigSensorPageLoopState extends MyState<_MyConfigSensorPageLoop> {
  Future<String> future;
  String dip;
  String selection;

  _onLoad() async {
    future = indicateResult(Api.configInput(dip));
  }

  @override
  void initState() {
    super.initState();
    _onLoad();
  }

  @override
  Widget build(final BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text("Einen kurzen Moment Geduld ..."),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: CircularProgressIndicator(),
              ),
            ],
          );
        }

        if (snap.hasData) {
          final String data = snap.data;
          final Map<String, String> dataMap = Uri.splitQueryString(data);

          if (dataMap["type"] != dip) {
            dip = dataMap["type"];
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Stellen Sie die Schalter wie dargestellt ein:"),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300.0),
                    child: Image.asset(
                      "assets/manual/dip/${dip}X.png",
                      alignment: Alignment.center,
                      repeat: ImageRepeat.noRepeat,
                      matchTextDirection: false,
                    ),
                  ),
                ),
                OutlineButton(
                  borderSide: const BorderSide(),
                  onPressed: () {
                    setState(() {
                      future = indicateResult(Api.configInput(dip));
                      selection = null;
                    });
                  },
                  child: const Text("Erledigt"),
                ),
              ],
            );
          } else {
            print(dataMap.remove("value"));
            print(dataMap.remove("type"));
            return _buildChoose(dataMap.map((key, value) {
              final int temp = (double.parse(value) - KELVIN).round();
              return MapEntry(key, "$temp°C");
            }));
          }
        }

        return const Text("Verbindung fehlgeschlagem");
      },
    );
  }

  Widget _buildChoose(final Map<String, String> options) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text("""Welche Temperatur hat es gerade draußen?
Hinweis: Lesen Sie die Außenfühlertemperatur an Ihrer Heizung ab."""),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: dropdown(selection, (selection) {
            setState(() {
              this.selection = selection;
            });
          }, options.values.toList(growable: false)),
        ),
        OutlineButton(
          borderSide: const BorderSide(),
          onPressed: () async {
            if (selection == null) {
              toast("please select temperature");
              return;
            }

            final String sensor = options.entries.singleWhere((entry) => entry.value == selection).key;
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("/config/sensor/sensor", sensor);
            widget.onStateChanged(
              _MyConfigSensorPageEnd(
                sensor: sensor,
                onStateChanged: widget.onStateChanged,
              ),
            );
          },
          child: const Text("Weiter"),
        ),
      ],
    );
  }
}

class _MyConfigSensorPageEnd extends StatefulWidget {
  _MyConfigSensorPageEnd({
    @required this.sensor,
    @required this.onStateChanged,
  });

  final String sensor;
  final StateCallback onStateChanged;

  @override
  _MyConfigSensorPageEndState createState() => _MyConfigSensorPageEndState();
}

class _MyConfigSensorPageEndState extends MyState<_MyConfigSensorPageEnd> {
  Future<String> future;

  _onLoad() async {
    future = indicateResult(Api.configSensor(widget.sensor));
  }

  @override
  void initState() {
    super.initState();
    _onLoad();
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text.rich(
          TextSpan(
            children: <TextSpan>[
              TextSpan(text: "Ihr Außenfühler wurde als "),
              TextSpan(text: widget.sensor, style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: " erkannt."),
            ],
          ),
        ),
        const Text("Stellen Sie die Schalter wie dargestellt ein:"),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: FutureBuilder(
            future: future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              if (snap.hasData) {
                final String dip = snap.data;
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300.0),
                  child: Image.asset(
                    "assets/manual/dip/$dip.png",
                    alignment: Alignment.center,
                    repeat: ImageRepeat.noRepeat,
                    matchTextDirection: false,
                  ),
                );
              }

              return const Text("Verbindung fehlgeschlagem");
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: OutlineButton(
                borderSide: const BorderSide(),
                onPressed: () {
                  widget.onStateChanged(
                    _MyConfigSensorPageStart(
                      onStateChanged: widget.onStateChanged,
                    ),
                  );
                },
                child: const Text("Nochmal"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: OutlineButton(
                borderSide: const BorderSide(),
                onPressed: () {
                  Api.control(enabled: true);
                  navigate("/");
                },
                child: const Text("Fertig"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MyConfigSensorPageX extends StatefulWidget {
  _MyConfigSensorPageX({
    @required this.onStateChanged,
  });

  final StateCallback onStateChanged;

  @override
  _MyConfigSensorPageXState createState() => _MyConfigSensorPageXState();
}

class _MyConfigSensorPageXState extends MyState<_MyConfigSensorPageX> {
  String sensor = 'UNKNOWN';

  void _onSubmit() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("/config/sensor/sensor", sensor);
    widget.onStateChanged(
      _MyConfigSensorPageEnd(
        sensor: sensor,
        onStateChanged: widget.onStateChanged,
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          "Sensor",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: dropdown(
            sensor,
            (String sensor) {
              indicate(null);
              setState(() {
                this.sensor = sensor;
              });
            },
            sensors,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: OutlineButton(
            borderSide: const BorderSide(),
            onPressed: _onSubmit,
            child: const Text("Submit"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: OutlineButton(
            borderSide: const BorderSide(),
            onPressed: () {
              widget.onStateChanged(
                _MyConfigSensorPageStart(
                  onStateChanged: widget.onStateChanged,
                ),
              );
            },
            child: const Text("Zurück"),
          ),
        ),
      ],
    );
  }
}
