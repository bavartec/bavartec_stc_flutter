import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:bavartec_stc/i18n.dart';
import 'package:bavartec_stc/main.dart';
import 'package:flutter/material.dart';

const double KELVIN = 273.15;

typedef Mapping<K, V> = V Function(K key);

enum Light { blue, red, yellow, green }

class Lights {
  Lights({
    @required this.mdns,
    @required this.mqtt,
    @required this.sync,
  });

  Light mdns;
  Light mqtt;
  Light sync;

  Light shine() {
    if (sync != Light.blue) {
      return sync;
    }

    return best(mdns, mqtt);
  }

  static Light best(final Light a, final Light b) {
    return Light.values[max(a.index, b.index)];
  }
}

String formatQueryString(final Map<String, String> data) {
  return data.entries.map((entry) {
    return entry.key + ': ' + entry.value;
  }).join('\n');
}

Timer periodic(final Duration duration, void callback()) {
  Timer.run(callback);
  return Timer.periodic(duration, (timer) => callback());
}

void periodicSafe(final Duration duration, Future<bool> callback()) {
  Timer.run(() async {
    if (await callback()) {
      Timer(duration, () => periodicSafe(duration, callback));
    }
  });
}

class Regex {
  static const String _domainComponent = '[a-z0-9][a-z0-9_-]*[a-z0-9]';
  static const String _domain = '$_domainComponent(.$_domainComponent)+';
  static RegExp domain = RegExp('^$_domain\$');

  static const String _ipComponent = '[0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5]';
  static const String _ip = '$_ipComponent(.$_ipComponent)+';
  static RegExp ip = RegExp('^$_ip\$');

  static RegExp server = RegExp('^($_domain)|($_ip)\$');
}

abstract class MyBaseState<T extends StatefulWidget> extends State<T> {
  MyLocalizations locale() => MyLocalizations.of(context);

  @override
  void setState(fn) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        super.setState(fn);
      });
      window.scheduleFrame();
    } else {
      fn();
    }
  }
}

abstract class MyState<T extends StatefulWidget> extends MyBaseState<T> {
  MyAppState findRoot() {
    return context.ancestorStateOfType(const TypeMatcher<MyAppState>()) as MyAppState;
  }

  void indicate(final Light light) {
    findRoot().indicate(
      sync: light,
    );
  }

  void indicateNull() {
    indicate(Light.blue);
  }

  Future<T> indicateResult<T>(final Future<T> call) async {
    indicate(Light.yellow);
    final T result = await call;
    final bool success = result != null;
    indicate(success ? Light.green : Light.red);
    return result;
  }

  Future<bool> indicateSuccess(final Future<bool> call) async {
    indicate(Light.yellow);
    final bool success = await call;
    indicate(success ? Light.green : Light.red);
    return success;
  }

  void navigate(final String route) {
    indicateNull();

    if (route == null) {
      navigator().pop();
    } else {
      navigator().pushNamed(route);
    }
  }

  NavigatorState navigator() => Navigator.of(context);

  void consumePointer() {
    scrollable().position.hold(null);
  }

  ScrollableState scrollable() => Scrollable.of(context);

  DropdownButton<String> dropdown(
    final String value,
    final List<String> items, {
    @required final ValueChanged<String> onChanged,
  }) {
    return dropdownMap<String>(
      value,
      items,
      onChanged: onChanged,
      mapping: (value) => value,
    );
  }

  DropdownButton<T> dropdownMap<T>(
    final T value,
    final List<T> items, {
    @required final ValueChanged<T> onChanged,
    @required final Mapping<T, String> mapping,
  }) {
    return DropdownButton<T>(
      value: value,
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<T>>((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(mapping(value)),
        );
      }).toList(),
    );
  }

  void toast(
    final String text, {
    final Duration duration = const Duration(seconds: 4),
  }) {
    print("showing toast: $text");

    final ScaffoldState scaffold = Scaffold.of(context);
    scaffold.showSnackBar(SnackBar(
      content: Text(text),
      action: SnackBarAction(
        label: locale().ok,
        onPressed: scaffold.hideCurrentSnackBar,
      ),
      duration: duration,
    ));
  }

  Offset toLocal(final Offset global, final bool normal, final bool center) {
    final RenderBox box = context.findRenderObject();
    final Offset local = box.globalToLocal(global);

    // print("local pos: " + local.dx.toString() + " " + local.dy.toString());

    double dx = local.dx;
    double dy = local.dy;

    //归一化
    if (normal) {
      dx /= box.size.width;
      dy /= box.size.height;
    }

    //以中心为原点
    if (center) {
      dx = 2 * dx - 1;
      dy = 2 * dy - 1;
    }

    return Offset(dx, dy);
  }
}
