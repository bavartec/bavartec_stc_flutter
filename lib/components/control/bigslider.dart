import 'dart:math';

import 'package:bavartec_stc/common.dart';
import 'package:flutter/material.dart';

typedef ValueChanged<T> = void Function(T value, bool done);

class BigSlider extends StatefulWidget {
  BigSlider({
    @required this.isHType,
    @required this.min,
    @required this.max,
    @required this.oldValue,
    @required this.newValue,
    @required this.onChanged,
  });

  final bool isHType;

  final double min;
  final double max;

  final double oldValue;
  final double newValue;

  final ValueChanged<double> onChanged;

  @override
  _BigSliderState createState() => _BigSliderState();
}

class _BigSliderState extends MyState<BigSlider> {
  double value;

  bool valid;
  Offset pointer;

  void _pointer(final PointerEvent event) {
    pointer = toLocal(event.position, true, true);
  }

  void _pointerDown(final PointerDownEvent event) {
    _pointer(event);
    valid = pointer.dx * pointer.dx + pointer.dy * pointer.dy <= 1.0;

    if (valid) {
      _pointerUpdate(event);
    }
  }

  void _pointerMove(final PointerMoveEvent event) {
    if (valid) {
      _pointer(event);
      _pointerUpdate(event);
    }
  }

  void _pointerUpdate(final PointerEvent event) {
    consumePointer();

    final double start = -0.75 * pi;
    final double end = 0.75 * pi;
    final double angle = atan2(pointer.dx, -pointer.dy);

    final double min = widget.min;
    final double max = widget.max;

    double newValue = min + (max - min) * (angle - start) / (end - start);

    if (newValue < min) {
      newValue = min;
    } else if (newValue > max) {
      newValue = max;
    }

    newValue = (newValue / 0.5).round() * 0.5;

    setState(() {
      this.value = newValue;
    });

    widget.onChanged(value, false);
  }

  @override
  void initState() {
    super.initState();
    value = widget.newValue;
  }

  @override
  void didUpdateWidget(final BigSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    value = widget.newValue;
  }

  @override
  Widget build(final BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _pointerDown,
      onPointerMove: _pointerMove,
      onPointerUp: (final PointerUpEvent event) {
        widget.onChanged(value, true);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: CustomPaint(
            painter: BigSliderPainter(
              isHType: widget.isHType,
              min: widget.min,
              max: widget.max,
              oldValue: widget.oldValue,
              newValue: value,
            ),
          ),
        ),
      ),
    );
  }
}

class BigSliderPainter extends CustomPainter {
  BigSliderPainter({
    @required this.isHType,
    @required this.min,
    @required this.max,
    @required this.oldValue,
    @required this.newValue,
  });

  final bool isHType;

  final double min;
  final double max;
  final double oldValue;
  final double newValue;

  Size size;

  Offset _handlePos(final Size size, final double angle) {
    return size.center(Offset.zero).translate(cos(angle) * size.width / 2, sin(angle) * size.width / 2);
  }

  @override
  void paint(final Canvas canvas, final Size size) {
    this.size = size;

    final Rect rect = Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2.0);

    final Paint coldLight = Paint()
      ..color = Colors.blue.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    final Paint warmLight = Paint()
      ..color = Colors.red.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    if (isHType) {
      warmLight.color = Colors.red.withOpacity(0.25);
      coldLight.color = Colors.grey[200];
    } else {
      warmLight.color = Colors.blue.withOpacity(0.25);
      coldLight.color = Colors.grey[200];
    }

    final Paint cold = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Paint warm = Paint()
      ..color = Colors.red
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (isHType) {
      warm.color = Colors.red;//grey[300];
      cold.color = Colors.red;
    } else {
      warm.color = Colors.blue;//grey[200];
      cold.color = Colors.blue;
    }

    final Paint handle = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    if (isHType) {
      handle.color = Colors.red;
    } else {
      handle.color = Colors.blue;
    }

    final Paint background = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final double start = -1.25 * pi;
    final double end = 0.25 * pi;
    final double oldProgress = (oldValue - min) / (max - min);
    final double newProgress = (newValue - min) / (max - min);
    final double oldAngle = start + 1.5 * pi * oldProgress;
    final double newAngle = start + 1.5 * pi * newProgress;

    canvas.drawArc(rect, start, newAngle - start, true, warmLight);
    canvas.drawArc(rect, newAngle, end - newAngle, true, coldLight);
    canvas.drawArc(rect, start, oldAngle - start, false, cold);
    canvas.drawArc(rect, oldAngle, end - oldAngle, false, warm);

    final Offset oldHandlePos = _handlePos(size, oldAngle);
    final Offset newHandlePos = _handlePos(size, newAngle);
    canvas.drawCircle(oldHandlePos, 6.0, handle);
    canvas.drawCircle(newHandlePos, 12.0, handle);
    canvas.drawCircle(newHandlePos, 10.0, background);

    canvas.drawCircle(size.center(Offset.zero), 0.275 * size.width, background);

    final Color textColor = Color.lerp(Colors.blue, Colors.red, newProgress);
    final TextStyle textStyle = TextStyle(color: textColor, fontSize: 0.125 * size.width);

    final TextSpan span = TextSpan(style: textStyle, text: "$newValue°C");
    final TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();

    final Offset textPos = size.center(Offset.zero).translate(-tp.size.width / 2, -tp.size.height / 2);
    tp.paint(canvas, textPos);

    if (isHType) {
      final Color textColor = Colors.red;
      final TextStyle textStyle = TextStyle(color: textColor, fontSize: 0.080 * size.width);

      final TextSpan span = TextSpan(style: textStyle, text: "H");
      final TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();

      //final Offset textPos = size.center(Offset.zero).translate(-tp.size.width / 2, -tp.size.height * 3 / 2);
      final Offset textPos = Offset(newHandlePos.dx - tp.size.width / 2, newHandlePos.dy - tp.size.height / 2);
      tp.paint(canvas, textPos);
    } else {
      final Color textColor = Colors.blue;
      final TextStyle textStyle = TextStyle(color: textColor, fontSize: 0.080 * size.width);

      final TextSpan span = TextSpan(style: textStyle, text: "L");
      final TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();

      final Offset textPos = Offset(newHandlePos.dx - tp.size.width / 2 + 1, newHandlePos.dy - tp.size.height / 2);
      tp.paint(canvas, textPos);
    }
  }

  @override
  bool shouldRepaint(final BigSliderPainter other) {
    return min != other.min || max != other.max || oldValue != other.oldValue || newValue != other.newValue;
  }
}
