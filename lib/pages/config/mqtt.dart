import 'package:bavartec_stc/api.dart';
import 'package:bavartec_stc/common.dart';
import 'package:bavartec_stc/mqtt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyConfigMQTTPage extends StatefulWidget {
  MyConfigMQTTPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyConfigMQTTPageState createState() => _MyConfigMQTTPageState();
}

class _MyConfigMQTTPageState extends MyState<MyConfigMQTTPage> {
  TextEditingController serverController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController userController = TextEditingController();
  TextEditingController passController = TextEditingController();

  bool provider = true;
  String server;
  int port;
  String user;
  String pass;
  bool showPass = false;

  void _onLoad() async {
    await MQTT.load();

    setState(() {
      provider = [null, MQTT.SERVER].contains(MQTT.server);
      server = MQTT.server;
      port = MQTT.port;
      user = MQTT.user;
      pass = MQTT.pass;

      serverController.value = new TextEditingValue(text: server ?? '');
      portController.value = new TextEditingValue(text: port?.toString() ?? '');
      userController.value = new TextEditingValue(text: user ?? '');
      passController.value = new TextEditingValue(text: pass ?? '');
    });
  }

  Future<bool> _save() async {
    indicateNull();

    final String server = provider ? MQTT.SERVER : this.server;
    final int port = provider ? MQTT.PORT : this.port;

    final String validation = MQTT.validate(server, port, user, pass);

    if (validation != null) {
      toast(validation);
      return false;
    }

    MQTT.set(server, port, user, pass);
    MQTT.save();
    return true;
  }

  void _onSubmit() async {
    if (!await _save()) {
      return;
    }

    if (provider) {
      indicate(Light.yellow);

      final String registration = await MQTT.register();
      toast(locale().apiRegister[registration]);

      if (registration != 'success') {
        indicate(Light.red);
        return;
      }
    }

    final bool success = await indicateSuccess(Api.configMQTT(server, port, user, pass));

    if (!success) {
      toast(locale().configWifiFail);
      return;
    }

    toast(locale().configWifiOk);
  }

  @override
  void initState() {
    super.initState();
    _onLoad();
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          locale().provider,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        dropdownMap(
          provider,
          [true, false],
          onChanged: (provider) {
            setState(() {
              this.provider = provider;
            });
          },
          mapping: (provider) {
            return provider ? "BavarTec" : locale().custom;
          },
        ),
        const SizedBox(height: 15.0),
        Visibility(
          visible: !provider,
          child: Column(
            children: <Widget>[
              Text(
                locale().server,
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
                        indicateNull();
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
              Text(
                locale().port,
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
                        indicateNull();
                        setState(() {
                          this.port = int.tryParse(port);
                        });
                      },
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15.0),
            ],
          ),
        ),
        Text(
          locale().username,
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
                controller: userController,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(31),
                ],
                onChanged: (user) {
                  indicateNull();
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
        Text(
          locale().password,
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
                controller: passController,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(63),
                ],
                obscureText: !showPass,
                onChanged: (password) {
                  indicateNull();
                  setState(() {
                    this.pass = password;
                  });
                },
                textAlign: TextAlign.center,
              ),
              CheckboxListTile(
                value: showPass,
                onChanged: (value) {
                  indicateNull();
                  setState(() {
                    this.showPass = value;
                  });
                },
                title: Text(locale().showPassword),
                controlAffinity: ListTileControlAffinity.platform,
              ),
            ],
          ),
        ),
        const SizedBox(height: 15.0),
        OutlineButton(
          borderSide: const BorderSide(),
          onPressed: _onSubmit,
          child: Text(locale().submit),
        ),
      ],
    );
  }
}
