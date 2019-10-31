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
      this.text = "getting service...";
    });
    indicate(const Color(0xffffff00));

    listening(await Api.debugListen());
    timer = Timer.periodic(Duration(milliseconds: 500), (timer) async {
      listening(await Api.debugListen());
    });
  }

  void listening(final String text) {
    indicate(text == null ? const Color(0xffff0000) : const Color(0xff00ff00));
    setState(() {
      this.text = text == null ? "Empty response" : formatQueryString(text);
    });

    if (text == null) {
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
    indicate(null);
  }

  @override
  Widget build(final BuildContext context) {
    return scaffold(
      widget.title,
      Column(
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
                  child: const Text("Start"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: OutlineButton(
                  borderSide: const BorderSide(),
                  onPressed: listenStop,
                  child: const Text("Stop"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
