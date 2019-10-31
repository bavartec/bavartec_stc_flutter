import 'package:bavartec_stc/common.dart';
import 'package:flutter/material.dart';




class MyAboutPage extends StatefulWidget {
  MyAboutPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyAboutPageState createState() => _MyAboutPageState();
}

class _MyAboutPageState extends MyState<MyAboutPage> {
  //TextEditingController passController = TextEditingController();

  String aboutContent = "Entwickelt und importiert durch\r\n"+
  "BavarTec UG (haftungsbeschränkt), Kapellenweg 10d\r\n"+
  "94575 Windorf, Deutschland\r\n"+
  "E-Mail: bavartec@gmail.com\r\n"+
  "https://www.bavartec.de";
  String softWareVer  = 'SoftWare Version: V1.0.1';
  String firmWareVer = 'FirmWare Version: V1.0.1';


  //void _onLoad() async {
    //indicate(null);
  //}


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
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(25.0),
              color: const Color(0xffffffff),
              width: 250,
              height: 280,
              child:Image.asset(
                    'assets/logo.png',
                    width: 200,
                    height: 120,
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                  ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(""),
            ),
            Container(
              padding: const EdgeInsets.all(5.0),
              //color: const Color(0xffffffff),
              width: 550,
              height: 130,
              decoration: BoxDecoration(
                color: const Color(0xffffffff),
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
                //设置四周边框
                border: new Border.all(width: 1, color: Colors.grey),
              ),
              child: Text(
                  aboutContent,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    backgroundColor: const Color(0xffffffff),
                    fontWeight: FontWeight.normal,

                  ),
                ),
            ),

            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Text(" "),
            ),
            Container(
                width: 550,
              padding: const EdgeInsets.all(2.0),
              child: Text(
                softWareVer,
                textAlign: TextAlign.left,
                style: TextStyle(
                fontWeight: FontWeight.normal,
                ),
              )
            ),
            Container(
              width: 550,
              padding: const EdgeInsets.all(2.0),
              child: Text(
                firmWareVer,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
