import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LinkText extends StatefulWidget {
  LinkText({
    Key key,
    @required this.builder,
    @required this.onTap,
  }) : super(key: key);

  final Widget Function(BuildContext, TapGestureRecognizer) builder;

  final void Function() onTap;

  @override
  LinkTextState createState() => LinkTextState();
}

class LinkTextState extends State<LinkText> {
  TapGestureRecognizer recognizer;

  @override
  void initState() {
    super.initState();
    recognizer = TapGestureRecognizer()..onTap = widget.onTap;
  }

  @override
  void dispose() {
    recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return widget.builder(context, recognizer);
  }
}
