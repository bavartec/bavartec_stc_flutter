import 'dart:async';

import 'package:bavartec_stc/api.dart';
import 'package:bavartec_stc/common.dart';
import 'package:flutter/material.dart';

class MyListenPage extends StatefulWidget {
  MyListenPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyListenPageState createState() => _MyListenPageState();
}

class _MyListenPageState extends MyState<MyListenPage> {
  String text;

  Timer timer;

  void listenStart() async {
    if (timer != null) {
      return;
    }

    print("listenStart");
    setState(() {
      text = "getting service...";
    });
    indicate(Light.yellow);

    timer = periodic(Duration(milliseconds: 500), () async {
      listening(await Api.debugListen());
    });
  }

  void listening(final Map<String, String> data) {
    indicate(data == null ? Light.red : Light.green);
    setState(() {
      if (data == null) {
        text = locale().errorNoResponse;
      } else {
        text = formatQueryString(data);
      }
    });

    if (data == null) {
      listenStop();
    }
  }

  void listenStop() async {
    if (timer == null) {
      return;
    }

    print("listenStop");
    timer.cancel();
    timer = null;
    indicateNull();
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(text ?? "</>"),
        const SizedBox(height: 30.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: OutlineButton(
                borderSide: const BorderSide(),
                onPressed: listenStart,
                child: Text(locale().start),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: OutlineButton(
                borderSide: const BorderSide(),
                onPressed: listenStop,
                child: Text(locale().stop),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
