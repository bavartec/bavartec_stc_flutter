import 'dart:ui';

import 'package:bavartec_stc/components/indicator.dart';
import 'package:flutter/material.dart';

const double KELVIN = 273.15;

typedef Mapping<K, V> = V Function(K key);

String formatQueryString(final String raw) {
  return Uri.splitQueryString(raw).entries.map((entry) {
    return entry.key + ': ' + entry.value;
  }).join('\n');
}

abstract class MyState<T extends StatefulWidget> extends State<T> {
  BuildContext innerContext;
  Color indicator;

  MyState findRoot() {
    MyState state = this;

    while (state.innerContext == null) {
      state = context.ancestorStateOfType(const TypeMatcher<MyState>()) as MyState;
    }

    return state;
  }

  void indicate(final Color color) async {
    setState(() {
      indicator = color;
    });
  }

  Future<T> indicateResult<T>(final Future<T> call) async {
    final MyState root = findRoot();
    root.indicate(const Color(0xffffff00));
    final T result = await call;
    final bool success = result != null;
    root.indicate(success ? const Color(0xff00ff00) : const Color(0xffff0000));
    return result;
  }

  Future<bool> indicateSuccess(final Future<bool> call) async {
    final MyState root = findRoot();
    root.indicate(const Color(0xffffff00));
    final bool success = await call;
    root.indicate(success ? const Color(0xff00ff00) : const Color(0xffff0000));
    return success;
  }

  void navigate(final String route) {
    Navigator.of(context).pushNamed(route);
  }

  void consumePointer() {
    Scrollable.of(context).position.hold(null);
  }

  DropdownButton<String> dropdown(final String value, final List<String> items,
      {final ValueChanged<String> onChanged}) {
    return dropdownMap(value, items, onChanged: onChanged, mapping: (value) => value);
  }

  DropdownButton<T> dropdownMap<T>(final T value, final List<T> items,
      {final ValueChanged<T> onChanged, final Mapping<T, String> mapping}) {
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

  Scaffold scaffold(final String title, final Widget child) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(title),
            Container(
              width: 20,
              height: 20,
              child: indicator == null ? null : Indicator(color: indicator),
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Builder(
              builder: (context) {
                this.innerContext = context;
                return child;
              },
            ),
          ),
        ),
      ),
      drawer: SafeArea(
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: const <String>["Config", "Control", "Debug"]
                .map((label) => ListTile(
                      title: Text(label),
                      onTap: () {
                        Navigator.of(context).pop();
                        navigate('/' + label.toLowerCase());
                      },
                    ))
                .toList(growable: false),
          ),
        ),
      ),
    );
  }

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

  void toast(final String text) {
    final ScaffoldState scaffold = Scaffold.of(innerContext ?? context);
    scaffold.showSnackBar(SnackBar(
      content: Text(text),
      action: SnackBarAction(
        label: "OK",
        onPressed: scaffold.hideCurrentSnackBar,
      ),
    ));
  }

  Offset toLocal(final Offset global, final bool normal, final bool center) {
    final RenderBox box = context.findRenderObject();
    final Offset local = box.globalToLocal(global);

    double dx = local.dx;
    double dy = local.dy;

    if (normal) {
      dx /= box.size.width;
      dy /= box.size.height;
    }

    if (center) {
      dx = 2 * dx - 1;
      dy = 2 * dy - 1;
    }

    return Offset(dx, dy);
  }
}
