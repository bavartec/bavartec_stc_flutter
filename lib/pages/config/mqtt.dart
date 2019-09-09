import 'package:bavartec_stc/api.dart';
import 'package:bavartec_stc/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String SERVER = "mqtt.bavartec.de";
const int PORT = 8883;

class MyConfigMQTTPage extends StatefulWidget {
  MyConfigMQTTPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyConfigMQTTPageState createState() => _MyConfigMQTTPageState();
}

class _MyConfigMQTTPageState extends MyState<MyConfigMQTTPage> {
  TextEditingController serverController = TextEditingController(text: SERVER);
  TextEditingController portController = TextEditingController(text: PORT.toString());
  String server = SERVER;
  int port = PORT;
  String user = '';
  String password = '';
  bool showPassword = false;

  void _onSubmit() async {
    if (user.length == 0 || password.length == 0) {
      indicate(null);
      toast("please enter username and password");
      return;
    }

    await indicateSuccess(Api.configMQTT(server, port, user, password));
  }

  @override
  Widget build(final BuildContext context) {
    return scaffold(
      widget.title,
      Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Server",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 300.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    autocorrect: false,
                    controller: serverController,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(255),
                    ],
                    onChanged: (server) {
                      indicate(null);
                      setState(() {
                        this.server = server;
                      });
                    },
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15.0),
            const Text(
              "Port",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 300.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    autocorrect: false,
                    controller: portController,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(5),
                    ],
                    keyboardType: TextInputType.numberWithOptions(),
                    onChanged: (port) {
                      indicate(null);
                      setState(() {
                        this.port = int.parse(port);
                      });
                    },
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15.0),
            const Text(
              "User",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 300.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    autocorrect: false,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(31),
                    ],
                    onChanged: (user) {
                      indicate(null);
                      setState(() {
                        this.user = user;
                      });
                    },
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15.0),
            const Text(
              "Password",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 300.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    autocorrect: false,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(63),
                    ],
                    obscureText: !showPassword,
                    onChanged: (password) {
                      indicate(null);
                      setState(() {
                        this.password = password;
                      });
                    },
                    textAlign: TextAlign.center,
                  ),
                  CheckboxListTile(
                    value: showPassword,
                    onChanged: (value) {
                      indicate(null);
                      setState(() {
                        this.showPassword = value;
                      });
                    },
                    title: const Text("Show Password"),
                    controlAffinity: ListTileControlAffinity.platform,
                  ),
                ],
              ),
            ),
            OutlineButton(
              borderSide: const BorderSide(),
              onPressed: _onSubmit,
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
