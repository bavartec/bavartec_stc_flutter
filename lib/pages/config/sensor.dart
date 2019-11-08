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
    final String sensor = prefs.getString('/config/sensor/sensor');

    if (sensor == null || sensor == 'UNKNOWN') {
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
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: this.stateChild,
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
        Text(locale().configSensorStart),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300.0),
            child: Image.asset(
              'assets/manual/dip/zero.png',
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
            onPressed: () async {
              bool rt = await Api.control(enabled: false);
              print("current widget:"+widget.toString());
              widget.onStateChanged(
                _MyConfigSensorPageLoop(
                  onStateChanged: widget.onStateChanged,
                ),
              );
            },
            child: Text(locale().doContinue),
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
            child: Text(locale().advanced),
          ),
        ),
      ],
    );
  }
}

class _MyConfigSensorPageLoop extends StatefulWidget {
  _MyConfigSensorPageLoop({
    @required this.onStateChanged,
    this.dip,
  });

  final StateCallback onStateChanged;
  final String dip;

  @override
  _MyConfigSensorPageLoopState createState() => _MyConfigSensorPageLoopState();
}

class _MyConfigSensorPageLoopState extends MyState<_MyConfigSensorPageLoop> {
  Future<String> future;
  String dip;
  String selection;

  @override
  void initState() {
    super.initState();
    dip = widget.dip;
    future = indicateResult(Api.configInput(dip));
    print("initState");
    print(dip);
    print(future.hashCode);
  }

  @override
  void didUpdateWidget(final _MyConfigSensorPageLoop oldWidget){
    super.didUpdateWidget(oldWidget);
    dip = widget.dip;
    future = indicateResult(Api.configInput(dip));
  }

  @override
  Widget build(final BuildContext context) {
    print("build");
    print(dip);
    print(future.hashCode);
    return FutureBuilder(
      key: ValueKey(future.hashCode),
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(locale().configSensorWait),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: CircularProgressIndicator(),
              ),
            ],
          );
        }

        if (snap.hasData && snap.data != null) {
          print("builder");
          print(dip);
          print(future.hashCode);

          final String data = snap.data;
          final Map<String, String> dataMap = Uri.splitQueryString(data);
          print("data="+data);
          print("dip="+(dip??"null"));
          if(dataMap == null){
            print("dataMap=null");
          }else {
            print("dataMap=" + dataMap.toString());
          }

          if (dataMap['type'] != dip) {
            final String dip2 = dataMap['type'];
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(locale().configSensorDIP),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300.0),
                    child: Image.asset(
                      'assets/manual/dip/${dip2}X.png',
                      alignment: Alignment.center,
                      repeat: ImageRepeat.noRepeat,
                      matchTextDirection: false,
                    ),
                  ),
                ),
                OutlineButton(
                  borderSide: const BorderSide(),
                  onPressed: () {
                    /*setState(() {
                      dip = dip2;//dataMap['type'];
                      print("outlineButton dip="+dip);
                      future = indicateResult(Api.configInput(dip));
                      print("OutlineButton setState");
                      print(dip);
                      print(future.hashCode);
                      selection = null;
                    });*/
                    widget.onStateChanged(
                      _MyConfigSensorPageLoop(
                        dip:dip2,
                        onStateChanged: widget.onStateChanged,
                      )
                    );
                  },
                  child: Text(locale().done),
                ),
              ],
            );
          } else {
            //print("value="+(dataMap==null?"null":dataMap.remove('value')));
            //print("type="+dataMap.remove('type'));
            //print("mike dataMap:"+dataMap.toString());
            //print("mike data:"+(data??"null"));

            //print("dataMap remove value="+(dataMap==null?'null':dataMap.remove('value')));
            //print("dataMap remove type="+(dataMap==null?'null':dataMap.remove('type')));
            dataMap.remove('value');
            dataMap.remove('type');
            return _buildChoose(dataMap.map((key, value) {
              print("key,value="+(key??'null')+","+(value??'null'));
              final int temp = (double.parse(value) - KELVIN).round();
              return MapEntry(key, "$temp°C");
            }));
          }
        }

        return Text(locale().errorConnectionFailed);
      },
    );
  }

  Widget _buildChoose(final Map<String, String> options) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(locale().configSensorChoose),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: dropdownMap(
            selection,
            options.keys.toList(growable: false),
            onChanged: (selection) {
              setState(() {
                this.selection = selection;
              });
            },
            mapping: (key) {
              return options[key];
            },
          ),
        ),
        OutlineButton(
          borderSide: const BorderSide(),
          onPressed: () async {
            if (selection == null) {
              return;
            }

            final String sensor = selection;
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('/config/sensor/sensor', sensor);
            widget.onStateChanged(
              _MyConfigSensorPageEnd(
                sensor: sensor,
                onStateChanged: widget.onStateChanged,
              ),
            );
          },
          child: Text(locale().doContinue),
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

  @override
  void initState() {
    super.initState();
    future = indicateResult(Api.configSensor(widget.sensor));
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text.rich(
          TextSpan(
            children: <TextSpan>[
              TextSpan(text: locale().configSensorRecognized[0]),
              TextSpan(text: widget.sensor, style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: locale().configSensorRecognized[1]),
            ],
          ),
        ),
        Text(locale().configSensorDIP),
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
                    'assets/manual/dip/$dip.png',
                    alignment: Alignment.center,
                    repeat: ImageRepeat.noRepeat,
                    matchTextDirection: false,
                  ),
                );
              }

              return Text(locale().errorConnectionFailed);
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
                child: Text(locale().again),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: OutlineButton(
                borderSide: const BorderSide(),
                onPressed: () {
                  Api.control(enabled: true);
                  navigate('/');
                },
                child: Text(locale().finish),
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
    prefs.setString('/config/sensor/sensor', sensor);
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
        Text(
          locale().sensor,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: dropdown(
            sensor,
            sensors,
            onChanged: (String sensor) {
              indicateNull();
              setState(() {
                this.sensor = sensor;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: OutlineButton(
            borderSide: const BorderSide(),
            onPressed: _onSubmit,
            child: Text(locale().submit),
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
            child: Text(locale().back),
          ),
        ),
      ],
    );
  }
}
