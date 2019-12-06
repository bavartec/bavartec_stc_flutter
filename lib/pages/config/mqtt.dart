import 'package:bavartec_stc/api.dart';
import 'package:bavartec_stc/common.dart';
import 'package:bavartec_stc/components/linktext.dart';
import 'package:bavartec_stc/main.dart';
import 'package:bavartec_stc/mqtt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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
  MQTT config;
  bool showPass = false;

  void _onLoad() async {
    final MQTT config = await MQTT.load() ?? MQTT();

    setState(() {
      provider = [null, MQTT.SERVER].contains(config.server);
      this.config = config;

      serverController.value = new TextEditingValue(text: config.server);
      portController.value = new TextEditingValue(text: config.port?.toString() ?? '');
      userController.value = new TextEditingValue(text: config.user);
      passController.value = new TextEditingValue(text: config.pass);
    });
  }

  void _onSubmit() async {
    indicateNull();

    if (provider) {
      config.server = MQTT.SERVER;
      config.port = MQTT.PORT;
    }

    final String validation = config.validate(locale());

    if (validation != null) {
      toast(validation);
      return;
    }

    if (provider) {
      indicate(Light.yellow);

      final String registration = await config.register();
      toast(locale().apiRegister[registration]);

      if (registration != 'success') {
        indicate(Light.red);
        return;
      }
    }

    final bool success = await indicateSuccess(Api.configMQTT(config));

    if (!success) {
      toast(locale().configMQTTFail);
      return;
    }

    await MQTT.save(config);

    toast(locale().configMQTTOk);
    await MyAppState.saveDebugQuery();
  }

  void _onReset() async {
    if (provider && await MyApp.confirm(context, locale().configMQTT_GDPR_Cancel)) {
      indicate(Light.yellow);

      final String unregistration = await config.unregister();
      toast(locale().apiUnregister[unregistration]);

      if (unregistration != 'success') {
        indicate(Light.red);
        return;
      }
    }

    MQTT.save(null);

    final bool success = await indicateSuccess(Api.configMQTT(null));

    if (!success) {
      toast(locale().configMQTTFail);
      return;
    }

    toast(locale().configMQTTOk);

    setState(() {
      serverController.text = '';
      portController.text = '';
      userController.text = '';
      passController.text = '';
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          locale().provider,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        dropdownMap<bool>(
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
        Visibility(
          visible: !provider,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 15.0),
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
                          config.server = server;
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
                          config.port = int.tryParse(port);
                        });
                      },
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15.0),
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
                    config.user = user;
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
                    config.pass = password;
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
        Visibility(
          visible: provider,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 15.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: LinkText(
                  builder: (context, recognizer) {
                    return Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: locale().configMQTT_GDPR_Submit[0],
                          ),
                          TextSpan(
                            text: locale().configMQTT_GDPR_Submit[1],
                            style: TextStyle(color: Colors.blue),
                            recognizer: recognizer,
                          ),
                          TextSpan(
                            text: locale().configMQTT_GDPR_Submit[2],
                          ),
                        ],
                      ),
                    );
                  },
                  onTap: () {
                    launch('https://www.bavartec.de/privacy/');
                  },
                ),
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
        Visibility(
          visible: provider,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 15.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(locale().configMQTT_GDPR_Reset),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15.0),
        OutlineButton(
          borderSide: const BorderSide(),
          onPressed: _onReset,
          child: Text(locale().reset),
        ),
      ],
    );
  }
}
