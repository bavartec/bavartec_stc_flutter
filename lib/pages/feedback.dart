import 'package:bavartec_stc/api.dart';
import 'package:bavartec_stc/common.dart';
import 'package:bavartec_stc/components/linktext.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MyFeedbackPage extends StatefulWidget {
  MyFeedbackPage({Key key}) : super(key: key);

  @override
  _MyFeedbackPageState createState() => _MyFeedbackPageState();
}

class _MyFeedbackPageState extends MyState<MyFeedbackPage> {
  TextEditingController messageController = TextEditingController();
  TextEditingController contactMethodController = TextEditingController();

  String message = '';
  String contactMethod = '';

  void _onSubmit() async {
    if (message.isEmpty) {
      return;
    }

    final bool success = await indicateSuccess(Api.submitFeedback(message, contactMethod));

    if (!success) {
      toast(locale().submitFail);
      return;
    }

    toast(locale().submitOk);
    _onReset();
  }

  void _onReset() {
    setState(() {
      messageController.text = '';
      contactMethodController.text = '';
    });
  }

  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 10.0),
          const Text(
            "Contact Us",
            style: TextStyle(
              height: 0,
              fontSize: 23,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 30.0),
          TextField(
            //设置为多行文本框：
            minLines: 4,
            maxLines: 10,
            controller: messageController,
            decoration: InputDecoration(
              hintText: "Please input the content",
              border: OutlineInputBorder(),
              fillColor: Colors.white,
              filled: true,
            ),
            onChanged: (final String value) {
              setState(() {
                message = value;
              });
            },
          ),
          const SizedBox(height: 10.0),
          TextField(
            controller: contactMethodController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
              prefixIcon: Icon(Icons.mail),
              border: OutlineInputBorder(),
              hintText: "(optional) Your contact method",
              fillColor: Colors.white,
              filled: true,
            ),
            onChanged: (final String value) {
              setState(() {
                contactMethod = value;
              });
            },
          ),
          const SizedBox(height: 30.0),
          LinkText(
            builder: (final BuildContext context, final TapGestureRecognizer recognizer) {
              return Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: locale().feedbackGDPR[0],
                    ),
                    TextSpan(
                      text: locale().feedbackGDPR[1],
                      style: TextStyle(color: Colors.blue),
                      recognizer: recognizer,
                    ),
                    TextSpan(
                      text: locale().feedbackGDPR[2],
                    ),
                  ],
                ),
              );
            },
            onTap: () {
              launch('https://www.bavartec.de/privacy/');
            },
          ),
          const SizedBox(height: 30.0),
          Container(
            margin: const EdgeInsets.only(top: 15.0),
            height: 50.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                OutlineButton(
                  onPressed: _onSubmit,
                  child: Text(locale().submit),
                  color: Colors.white,
                ),
                Padding(padding: const EdgeInsets.all(10.0)),
                OutlineButton(
                  onPressed: _onReset,
                  child: Text(locale().reset),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
