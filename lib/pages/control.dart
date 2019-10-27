import 'package:bavartec_stc/api.dart';
import 'package:bavartec_stc/common.dart';
import 'package:bavartec_stc/components/control/bigslider.dart';
import 'package:bavartec_stc/components/control/weekslider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const KEY_H = "/control/valueH";
const KEY_L = "/control/valueL";
const KEY_WEEK_DATA = "/control/weekly";

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

  void _onSave() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(KEY_H, newValueH);
    await prefs.setDouble(KEY_L, newValueL);
    await prefs.setStringList(KEY_WEEK_DATA, printWeekly(weekly));

    setState(() {
      currentValueH = newValueH;
      currentValueL = newValueL;
    });

    await indicateSuccess(Api.control(
      enabled: true,
      controlValue: newValueH,
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
        padding: const EdgeInsets.fromLTRB(5.0, 15.0, 5.0, 2.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
//            Container(
//              margin: EdgeInsets.all(50),
//              color: Colors.orange[200],
//              child: new Transform(
//                alignment: Alignment.topLeft, //相对于坐标系原点的对齐方式
//                transform: new Matrix4.rotationZ(-0.4),// 旋转
//                child: new Container(
//                  padding: const EdgeInsets.all(8.0),
//                  color: Colors.deepOrange,
//                  child: const Text('new Matrix4.rotationZ(-0.4)'),
//                ),
//              ),
//            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250.0),
              child: BigSlider(
                min: MIN_T,
                max: MAX_T,
                oldValueH: currentValueH,
                newValueH: newValueH,
                oldValueL: currentValueL,
                newValueL: newValueL,
                onChanged: (value, isH) {
                  indicate(null);
                  setState(() {
                    if(isH == 1) {
                      newValueH = value;
                    }else if(isH == 0){
                      newValueL = value;
                    }
                  });
                },
              ),
            ),
            OutlineButton(
              borderSide: const BorderSide(),
              onPressed: _onSave,
              child: const Text("Save"),
            ),
            const SizedBox(height: 10.0),
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
