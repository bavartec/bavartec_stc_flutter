import 'package:bavartec_stc/common.dart';
import 'package:flutter/material.dart';
import 'package:bavartec_stc/api.dart';




class MyFeedbackPage extends StatefulWidget {
  MyFeedbackPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyFeedbackPageState createState() => _MyFeedbackPageState();
}

class _MyFeedbackPageState extends MyState<MyFeedbackPage> {
  //TextEditingController passController = TextEditingController();
  TextEditingController _msg = TextEditingController(text: 'Please input the content');
  TextEditingController _contact = TextEditingController(text: '(optional)Your contact method');

  void _onLoad() async {
    indicate(null);
  }

  @override
  void initState() {
    super.initState();
    //_onLoad();
  }

  @override
  Widget build(final BuildContext context) {
    return scaffoldEx(
      widget.title,
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(""),
            ),
            const Text(
              "Contact Us",
              style: TextStyle(
                height: 0,
                fontSize: 23,
                fontWeight: FontWeight.normal,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Text(""),
            ),
            TextField(  //设置为多行文本框：
              minLines: 8,
              maxLines: 8,
              controller: _msg,
              decoration: InputDecoration(
                hintText: "Please input the content",
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Text(""),
            ),
            TextField(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                prefixIcon: Icon(Icons.mail),
                border: OutlineInputBorder(),
                hintText: "(optional) Your contact method",
                fillColor: Colors.white,
                filled: true,
              ),
              controller: _contact,
              onChanged: (value){
                setState(() {
                  _contact.text=value;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(""),
            ),
            new Container(
                margin: const EdgeInsets.only(top: 15.0),
                height: 50.0,
                child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      OutlineButton(
                        //borderSide: const BorderSide(),
                        onPressed: (){
                          Api.submitFeedback('http://localhost:8080/feedback', '['+_contact.toString()+'] '+_msg.toString());
                        },
                        child: const Text("Submit"),
                        color: Colors.white,
                      ),
                      Padding(padding: const EdgeInsets.all(10.0)),
                      OutlineButton(
                        //borderSide: const BorderSide(),
                        onPressed: (){},
                        child: const Text("Reset"),
                        color: Colors.white,
                      )
                      ])),
           // ),
          //],
        ]),
      ),
    );
  }
}
