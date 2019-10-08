import 'dart:math';

import 'package:bavartec_stc/common.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

const week = <String>["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"];

const List<String> weeklyDefault = [
  "000000111000000001111100",
  "000000111000000001111100",
  "000000111000000001111100",
  "000000111000000001111100",
  "000000111000000001111100",
  "000000001111111111111100",
  "000000001111111111111100",
];

List<List<bool>> parseWeekly(final List<String> text) {
  return text.map((line) => line.split("").map((c) => c == '1').toList(growable: false)).toList(growable: false);
}

List<String> printWeekly(final List<List<bool>> times) {
  return times.map((day) => day.map((v) => v ? '1' : '0').join()).toList(growable: false);
}

class WeekSlider extends StatefulWidget {
  WeekSlider({
    @required this.times,
    @required this.onChanged,
  });

  final List<List<bool>> times;

  final ValueChanged<List<List<bool>>> onChanged;

  @override
  _WeekSliderState createState() => _WeekSliderState();
}

class _WeekSliderState extends MyState<WeekSlider> {
  List<List<bool>> times;

  bool valid;
  int pointerH;
  int pointerY;

  void _pointer(final PointerEvent event) {
    final Offset pointer = toLocal(event.position, true, false);

    pointerH = (pointer.dx * 24).round();
    pointerY = (pointer.dy * 14).round();
  }

  void _pointerDown(final PointerDownEvent event) {
    _pointer(event);

    final int h = pointerH;
    final int y = pointerY;

    valid = h >= 0 && h <= 24 && y >= 1 && y <= 14;

    if (valid) {
      _pointerUpdate(event);
    }
  }

  void _pointerMove(final PointerMoveEvent event) {
    if (valid) {
      final int lastD = ((pointerY - 1) / 2).floor();
      _pointer(event);

      pointerH = max(pointerH, 0);
      pointerH = min(pointerH, 24);
      pointerY = max(pointerY, lastD * 2 + 1);
      pointerY = min(pointerY, lastD * 2 + 2);

      _pointerUpdate(event);
    }
  }

  void _pointerUpdate(final PointerEvent event) {
    consumePointer();

    final int h = pointerH;
    final int y = pointerY;

    final int d = ((y - 1) / 2).floor();
    final bool v = y % 2 == 1;

    setState(() {
      final List<List<bool>> times2 = List.from(times);
      times2[d] = List.from(times2[d]);
      times2[d][h % 24] = v;
      times = times2;
    });
  }

  @override
  void initState() {
    super.initState();
    times = widget.times;
  }

  @override
  void didUpdateWidget(final WeekSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    times = widget.times;
  }

  @override
  Widget build(final BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _pointerDown,
      onPointerMove: _pointerMove,
      onPointerUp: (event) {
        widget.onChanged(times);
      },
      child: CustomPaint(
        size: Size(double.infinity, 350.0),
        painter: WeekSliderPainter(
          times: times,
        ),
      ),
    );
  }
}

class WeekSliderPainter extends CustomPainter {
  WeekSliderPainter({
    @required this.times,
  });

  final List<List<bool>> times;

  @override
  void paint(final Canvas canvas, final Size size) {
    final Paint raster = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Paint rasterT = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.65
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Paint stroke = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int v = 1; v <= 14; v++) {
      final double x1 = size.width * 0 / 24;
      final double x2 = size.width * 24 / 24;
      final double y = size.height / 14 * v;

      canvas.drawLine(Offset(x1, y), Offset(x2, y), raster);
    }

    for (int d = 0; d < 7; d++) {
      for (int h = 0; h <= 24; h++) {
        final double x = size.width * h / 24;
        final double y1 = size.height / 14 * (d * 2 + 1);
        final double y2 = size.height / 14 * (d * 2 + 2);

        canvas.drawLine(Offset(x, y1), Offset(x, y2), h % 6 == 0 ? rasterT : raster);
      }
    }

    for (int d = 0; d < 7; d++) {
      final TextStyle textStyle = TextStyle(color: Colors.black, fontSize: 0.05 * size.height);

      for (int i = 0; i < (d == 0 ? 5 : 1); i++) {
        final TextSpan span = TextSpan(style: textStyle, text: [week[d], "06:00", "12:00", "18:00", "24:00"][i]);
        final TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
        tp.layout();

        final double px = size.width * i / 4 - (i == 0 ? 0 : tp.size.width / 2);
        final double py = size.height * (d * 2 + 0.5) / 14 - tp.size.height / 2;
        tp.paint(canvas, Offset(px, py));
      }

      for (int h = 0; h <= 24; h++) {
        final double x1 = size.width * h / 24;
        final double y1 = size.height / 14 * (d * 2 + (times[d][h % 24] ? 1 : 2));

        if (h < 24) {
          final double x2 = size.width * (h + 1) / 24;
          final double y2 = size.height / 14 * (d * 2 + (times[d][(h + 1) % 24] ? 1 : 2));
          canvas.drawLine(Offset(x1, y1), Offset(x2, y2), stroke);
        }
      }
    }
  }

  @override
  bool shouldRepaint(final WeekSliderPainter other) {
    return !ListEquality().equals(times, other.times);
  }
}
