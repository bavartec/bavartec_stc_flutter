import 'package:bavartec_stc/api.dart';
import 'package:bavartec_stc/common.dart';
import 'package:bavartec_stc/components/control/bigslider.dart';
import 'package:bavartec_stc/components/control/weekslider.dart';
import 'package:bavartec_stc/mqtt.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyControlPage extends StatefulWidget {
  MyControlPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyControlPageState createState() => _MyControlPageState();
}

class _MyControlPageState extends MyState<MyControlPage> {
  double currentValue = 20.0;
  double newValue = 20.0;

  List<List<bool>> weekly = parseWeekly(weeklyDefault);

  void _onLoad() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final double value = prefs.getDouble('/control/value');
    final List<String> weekly = prefs.getStringList('/control/weekly');

    setState(() {
      currentValue = value ?? currentValue;
      newValue = value ?? newValue;
      this.weekly = weekly == null ? this.weekly : parseWeekly(weekly);
    });
  }

  void _onSave() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('/control/value', newValue);
    await prefs.setStringList('/control/weekly', printWeekly(weekly));

    setState(() {
      currentValue = newValue;
    });
  }

  void _onSync() async {
    await indicateSuccess(() async {
      return (await _syncLocal()) || (await _syncRemote());
    }());
  }

  Future<bool> _syncLocal() {
    return Api.control(
      enabled: true,
      controlValue: newValue,
      weekly: printWeekly(weekly),
    );
  }

  Future<bool> _syncRemote() async {
    if (MQTT.valid()) {
      return false;
    }

    if (!await MQTT.connect()) {
      toast(locale().errorMQTTConnectionFailed);
      return false;
    }

    MQTT.publish('controlValue', currentValue.toString());
    MQTT.publish('weekly', printWeekly(weekly).join());
    return true;
  }

  @override
  void initState() {
    super.initState();
    _onLoad();
  }

  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 250.0),
            child: BigSlider(
              min: 12.0,
              max: 28.0,
              oldValue: currentValue,
              newValue: newValue,
              onChanged: (value) {
                indicateNull();
                setState(() {
                  newValue = value;
                });
              },
            ),
          ),
          OutlineButton(
            borderSide: const BorderSide(),
            onPressed: () {
              _onSave();
              _onSync();
            },
            child: Text(locale().save),
          ),
          const SizedBox(height: 30.0),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600.0),
            child: WeekSlider(
              times: weekly,
              onChanged: (times) {
                indicateNull();
                setState(() {
                  weekly = times;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
