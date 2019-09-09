import 'package:bavartec_stc/api.dart';
import 'package:bavartec_stc/common.dart';
import 'package:bavartec_stc/components/control/bigslider.dart';
import 'package:bavartec_stc/components/control/weekslider.dart';
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
    final double value = prefs.getDouble("/control/value");
    final List<String> weekly = prefs.getStringList("/control/weekly");

    setState(() {
      currentValue = value ?? currentValue;
      newValue = value ?? newValue;
      this.weekly = weekly == null ? this.weekly : parseWeekly(weekly);
    });
  }

  void _onSave() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("/control/value", newValue);
    await prefs.setStringList("/control/weekly", printWeekly(weekly));

    setState(() {
      currentValue = newValue;
    });

    await indicateSuccess(Api.control(
      enabled: true,
      controlValue: newValue,
      weekly: printWeekly(weekly),
    ));
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
                  indicate(null);
                  setState(() {
                    newValue = value;
                  });
                },
              ),
            ),
            OutlineButton(
              borderSide: const BorderSide(),
              onPressed: _onSave,
              child: const Text("Save"),
            ),
            const SizedBox(height: 30.0),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600.0),
              child: WeekSlider(
                times: weekly,
                onChanged: (times) {
                  indicate(null);
                  setState(() {
                    weekly = times;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
