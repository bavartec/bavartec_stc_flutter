import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {
  Indicator({
    @required this.color,
  });

  final Color color;

  @override
  Widget build(final BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: CustomPaint(
        painter: IndicatorPainter(
          color: color,
        ),
      ),
    );
  }
}

class IndicatorPainter extends CustomPainter {
  IndicatorPainter({
    @required this.color,
  });

  final Color color;

  @override
  void paint(final Canvas canvas, final Size size) {
    if (color == null) {
      return;
    }

    final Paint border = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    final Paint fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(size.center(Offset.zero), 0.6 * size.shortestSide, border);
    canvas.drawCircle(size.center(Offset.zero), 0.5 * size.shortestSide, fill);
  }

  @override
  bool shouldRepaint(final IndicatorPainter other) {
    return color != other.color;
  }
}
