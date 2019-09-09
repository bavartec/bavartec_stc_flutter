import 'package:bavartec_stc/common.dart';
import 'package:flutter/material.dart';

typedef Future<bool> Action();

class MyIndexPage extends StatefulWidget {
  MyIndexPage({
    Key key,
    this.title,
    @required this.prefix,
    @required this.labels,
    this.actions = const {},
  }) : super(key: key);

  final String title;
  final String prefix;
  final List<String> labels;
  final Map<String, Action> actions;

  @override
  _MyIndexPageState createState() => _MyIndexPageState();
}

class _MyIndexPageState extends MyState<MyIndexPage> {
  @override
  Widget build(final BuildContext context) {
    return scaffold(
      widget.title,
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.labels
            .map((label) => Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: OutlineButton(
                    borderSide: const BorderSide(),
                    onPressed: () {
                      if (widget.actions.containsKey(label.toLowerCase())) {
                        indicateSuccess(widget.actions[label.toLowerCase()]());
                      } else {
                        navigate(widget.prefix + label.toLowerCase());
                      }
                    },
                    child: Text(label),
                  ),
                ))
            .toList(growable: false),
      ),
    );
  }
}
