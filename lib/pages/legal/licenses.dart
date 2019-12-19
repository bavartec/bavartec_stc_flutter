import 'package:bavartec_stc/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyLicensesPage extends StatefulWidget {
  MyLicensesPage({Key key}) : super(key: key);

  @override
  _MyLicensesPageState createState() => _MyLicensesPageState();
}

class _MyLicensesPageState extends MyState<MyLicensesPage> {
  List<List<String>> licenses = [];

  void _onLoad() async {
    final String indexFile = await rootBundle.loadString("assets/licenses/index");
    final List<String> keys = indexFile.trimRight().split("\n");

    final List<List<String>> licenses = new List();

    for (final String key in keys) {
      final String license = await rootBundle.loadString("assets/licenses/$key");
      licenses.add([key, license]);
    }

    setState(() {
      this.licenses = licenses;
    });
  }

  @override
  void initState() {
    super.initState();
    _onLoad();
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: licenses.map((final List<String> license) {
        return ExpansionTile(
          title: Text(license[0]),
          children: <Widget>[
            Text(license[1]),
          ],
        );
      }).toList(),
    );
  }
}
