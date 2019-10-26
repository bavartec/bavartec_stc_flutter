import 'package:bavartec_stc/common.dart';
import 'package:flutter/material.dart';

typedef Future<bool> Action();

class MyIndex {
  MyIndex({
    @required this.label,
    this.action,
    this.route,
  });

  final String label;
  final Action action;
  final String route;
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.indexes
          .map((index) => Padding(
                padding: const EdgeInsets.all(15.0),
                child: OutlineButton(
                  borderSide: const BorderSide(),
                  onPressed: () {
                    if (index.action != null) {
                      indicateSuccess(index.action());
                    }

                    if (index.route != null) {
                      navigate(index.route);
                    }
                  },
                  child: Text(index.label),
                ),
              ))
          .toList(growable: false),
    );
  }
}
