import 'package:bavartec_stc/api.dart';
import 'package:bavartec_stc/common.dart';
import 'package:bavartec_stc/components/control/bigslider.dart';
import 'package:bavartec_stc/components/control/weekslider.dart';
import 'package:bavartec_stc/main.dart';
import 'package:bavartec_stc/mqtt.dart';
import 'package:bavartec_stc/wifi.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const KEY_H = '/control/valueH';
const KEY_L = '/control/valueL';
const KEY_WEEK_DATA = '/control/weekly';

const MIN_T = 12.0;
const MAX_T = 28.0;

class MyControlPage extends StatefulWidget {
  MyControlPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyControlPageState createState() => _MyControlPageState();
}

class _MyControlPageState extends MyState<MyControlPage> {
  double currentValueH = 22.0;
  double currentValueL = 18.0;
  double newValueH = 22.0;
  double newValueL = 18.0;

  List<List<bool>> weekly = parseWeekly(weeklyDefault);

  void _onLoad() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final double valueH = prefs.getDouble(KEY_H);
    final double valueL = prefs.getDouble(KEY_L);
    final List<String> weekly = prefs.getStringList(KEY_WEEK_DATA);

    setState(() {
      currentValueH = valueH ?? currentValueH;
      newValueH = valueH ?? newValueH;
      currentValueL = valueL ?? currentValueL;
      newValueL = valueL ?? newValueL;
      this.weekly = weekly == null ? this.weekly : parseWeekly(weekly);
    });
  }

  Future<void> _save() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(KEY_H, newValueH);
    await prefs.setDouble(KEY_L, newValueL);
    await prefs.setStringList(KEY_WEEK_DATA, printWeekly(weekly));

    setState(() {
      currentValueH = newValueH;
      currentValueL = newValueL;
    });
  }

  void _onSync() async {
    await _save();
    await indicateSuccess(_sync());
  }

  Future<bool> _sync() async {
    final Future<bool> localFuture = _syncLocal();
    final Future<bool> remoteFuture = _syncRemote();

    final bool local = await localFuture.then((success) {
      if (success) {
        toast(locale().submitOkLocal);
      }

      return success;
    });
    final bool remote = await remoteFuture.then((success) {
      if (success) {
        toast(locale().submitOkRemote);
      }

      return success;
    });

    if (!local && !remote) {
      toast(locale().submitFail);
    }

    return local || remote;
  }

  Future<bool> _syncLocal() async {
    if (WiFi.load() == null) {
      toast(locale().controlNoLocal);
      return false;
    }

    return await Api.control(
      enabled: true,
      controlValue: newValueH,
      nightValue: newValueL,
      weekly: printWeekly(weekly),
    );
  }

  Future<bool> _syncRemote() async {
    if (MQTT.load() == null) {
      toast(locale().controlNoRemote);
      return false;
    }

    if (!await MQTT.connect()) {
      toast(locale().errorMQTTConnectionFailed);
      return false;
    }

    if ((await MQTT.seed()) == null) {
      toast(locale().errorMQTTNotSeeded);
      MyAppState.saveDebugQuery();
      return false;
    }

    MQTT.publish('enabled', 'true');
    MQTT.publish('controlValue', currentValueH.toString());
    MQTT.publish('nightValue', currentValueL.toString());
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
      padding: const EdgeInsets.fromLTRB(5.0, 15.0, 5.0, 2.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: BigSlider(
                  isHType: false,
                  min: MIN_T,
                  max: MAX_T,
                  oldValue: currentValueL,
                  newValue: newValueL,
                  onChanged: (value, done) {
                    indicate(null);
                    setState(() {
                      if (value > newValueH) {
                        newValueH = value;
                      }
                      newValueL = value;
                    });
                  },
                ),
                flex: 1,
              ),
              Expanded(
                child: BigSlider(
                  isHType: true,
                  min: MIN_T,
                  max: MAX_T,
                  oldValue: currentValueH,
                  newValue: newValueH,
                  onChanged: (value, done) {
                    indicate(null);
                    setState(() {
                      if (value < newValueL) {
                        newValueL = value;
                      }
                      newValueH = value;
                    });
                  },
                ),
                flex: 1,
              ),
            ],
          ),
          OutlineButton(
            borderSide: const BorderSide(),
            onPressed: _onSync,
            child: Text(locale().save),
          ),
          const SizedBox(height: 10.0),
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
