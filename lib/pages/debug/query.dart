import 'package:bavartec_stc/api.dart';
import 'package:bavartec_stc/common.dart';
import 'package:flutter/material.dart';

class MyQueryPage extends StatefulWidget {
  MyQueryPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyQueryPageState createState() => _MyQueryPageState();
}

class _MyQueryPageState extends MyState<MyQueryPage> {
  String text;

  void _onRefresh() async {
    final String text = await indicateResult(Api.debugQuery());

    setState(() {
      if (text == null) {
        this.text = "no response";
      } else {
        this.text = formatQueryString(text);
      }
    });
  }

  @override
  Widget build(final BuildContext context) {
    return scaffold(
      widget.title,
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 30.0),
          Text(text ?? "</>"),
          const SizedBox(height: 30.0),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: OutlineButton(
              borderSide: const BorderSide(),
              onPressed: _onRefresh,
              child: const Text("Refresh"),
            ),
          ),
        ],
      ),
    );
  }
}
