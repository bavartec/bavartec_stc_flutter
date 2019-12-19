import 'package:bavartec_stc/common.dart';
import 'package:flutter/material.dart';

typedef Action(BuildContext context);

class MyIndex {
  MyIndex({
    @required this.route,
    this.action,
  });

  final String route;
  final Action action;
}

class MyIndexPage extends StatefulWidget {
  MyIndexPage(
    this.indexes, {
    Key key,
  }) : super(key: key);

  final List<MyIndex> indexes;

  @override
  _MyIndexPageState createState() => _MyIndexPageState();
}

class _MyIndexPageState extends MyState<MyIndexPage> {
  @override
  Widget build(final BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.indexes.map((final MyIndex index) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: OutlineButton(
              borderSide: const BorderSide(),
              onPressed: () {
                if (index.action != null) {
                  index.action(context);
                  return;
                }

                navigate(index.route);
              },
              child: Text(locale().routes[index.route]),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}
