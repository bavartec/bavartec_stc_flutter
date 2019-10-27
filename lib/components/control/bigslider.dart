import 'dart:math';

import 'package:bavartec_stc/common.dart';
import 'package:flutter/material.dart';

typedef ValueChangedEx<T> = void Function(T value, int isH);

class BigSlider extends StatefulWidget {
  BigSlider({
    @required this.min,
    @required this.max,
    //H
    @required this.oldValueH,
    @required this.newValueH,
    //L
    @required this.oldValueL,
    @required this.newValueL,

    @required this.onChanged,
  });

  //绘图区域
  //final Rect drawRect;


  final double min;
  final double max;

  //High T
  final double oldValueH;
  final double newValueH;

  //Low T
  final double oldValueL;
  final double newValueL;

  final ValueChangedEx<double> onChanged;


  @override
  _BigSliderState createState() => _BigSliderState();
}

const START_ANGLE = -0.75 * pi;
const END_ANGLE = 0.75 * pi;

class _BigSliderState extends MyState<BigSlider> {
  double valueH;
  double valueL;

//  Point ptHandleH;
//  Point ptHandleL;

  Rect rectHandleH;
  Rect rectHandleL;

  bool valid;
  int isH = -1;

  Offset pointer;


  //从温度值计算出当前的角度弧度
  double _calculateAngleFromValue(double val){
//    print("pointer update:"+pointer.dx.toString()+ " "+ pointer.dy.toString());
    final double start = -0.75 * pi;
    final double end = 0.75 * pi;
   // final double angle = atan2(pointer.dx, -pointer.dy);
//
//    print("angle:"+(angle*180.0/pi).toString());
    final double min = widget.min;
    final double max = widget.max;

    double tVal = val;
    if(val < min){
      tVal = min;
    }else if(val > max){
      tVal = max;
    }

    double angleV = start + (end-start) * (tVal-min)/(max-min);

    double angleX = angleV * 180.0 / pi;
    print("calc angleV:"+ angleX.toString());
    return angleV;
  }

  //从角度计算手柄点的位置
  Offset _calHandlePosByAngleH(double angle) {
    double radius = 1.0;

    double dx = radius * sin(angle);
    double dy = -radius * cos(angle);

    print("handle1 pos:" + dx.toString() + " " + dy.toString());
    double r = 50;
    rectHandleH = Rect.fromPoints(Offset(dx - r / 190.0, dy - r / 190.0),
        Offset(dx + r / 190.0, dy + r / 190.0));
    return Offset(dx, dy);
  }

  //从角度计算手柄点的位置
  Offset _calHandlePosByAngleL(double angle) {
    double radius = 0.55;
    double r = 50;

    double dx1 = radius * sin(angle);
    double dy1 = -radius * cos(angle);

    print("handle2 pos:" + dx1.toString() + " " + dy1.toString());
    rectHandleL = Rect.fromPoints(Offset(dx1 - r / 190.0, dy1 - r / 190.0),
        Offset(dx1 + r / 190.0, dy1 + r / 190.0));
    return Offset(dx1, dy1);
  }


//  Offset _handlePos(final Size size, final double angle) {
//    return size.center(Offset.zero).translate(cos(angle) * size.width / 2, sin(angle) * size.width / 2);
//  }

  void _pointer(final PointerEvent event) {
    //print("event.position:"+event.position.dx.toString()+" "+event.position.dy.toString());
    pointer = toLocal(event.position, true, true);
  }

  void _pointerDown(final PointerDownEvent event) {
    _pointer(event);

    valid = pointer.dx * pointer.dx + pointer.dy * pointer.dy <= 1.0;

    if(valid) {
      //consumePointer();
      Scrollable.of(context).position.hold(null);
    }
    print("Rect H:"+rectHandleH.center.dx.toString()+" "+rectHandleL.center.dy.toString());
    print("Rect L:"+rectHandleL.center.dx.toString()+" "+rectHandleL.center.dy.toString());
    print("pointer:"+pointer.dx.toString()+ " "+ pointer.dy.toString());
    if(rectHandleH.contains(pointer)){
      print("mike:yes in high");
      valid = true;
      isH = 1;
    }else if(rectHandleL.contains(pointer)){
      print("mike:yes in low");
      valid = true;
      isH = 0;
    }else{
      print("mike:not in any");
      isH = -1;
      valid = false;
    }


    //print(pointer.dx.toString()+" "+pointer.dy.toString());

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
    //print("pointer update:"+pointer.dx.toString()+ " "+ pointer.dy.toString());
    final double start = -0.75 * pi;
    final double end = 0.75 * pi;
    final double angle = atan2(pointer.dx, -pointer.dy);

    //print("angle:"+(angle*180.0/pi).toString());
    final double min = widget.min;
    final double max = widget.max;

    double newValue = min + (max - min) * (angle - start) / (end - start);

    if (newValue < min) {
      newValue = min;
    } else if (newValue > max) {
      newValue = max;
    }

    newValue = (newValue / 0.5).round() * 0.5;

    //计算Handle Rect
    double v = _calculateAngleFromValue(newValue);

    if(isH == 1) {
      print("mike:cal H");
      _calHandlePosByAngleH(v);
    }else if (isH == 0){
      print("mike:cal L");
      _calHandlePosByAngleL(v);
    }

    setState(() {
      if(isH == 1) {
        print("mike:setState H");
        this.valueH = newValue;
      }else if(isH == 0){
        print("mike:setState L");
        this.valueL = newValue;
      }else{

      }

    });
  }

  @override
  void initState() {
    super.initState();

    valueH = widget.newValueH;
    valueL = widget.newValueL;
    print("value H,L"+valueH.toString()+" "+valueL.toString());
    double v = _calculateAngleFromValue(valueH);
    _calHandlePosByAngleH(v);//update rectH

    v = _calculateAngleFromValue(valueL);
    _calHandlePosByAngleL(v);//update rectL

  }

  @override
  void didUpdateWidget(final BigSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    valueH = widget.newValueH;
    valueL = widget.newValueL;
  }

  @override
  Widget build(final BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _pointerDown,
      onPointerMove: _pointerMove,
      onPointerUp: (event) {
        double val = 0;
        if(isH == 1){
          val = valueH;
        }else if(isH == 0){
          val = valueL;
        }
        widget.onChanged(val, isH);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 30.0),
        child: AspectRatio(
          aspectRatio: 1.0,

          child: CustomPaint(
            painter: BigSliderPainter(
              context: context,
              min: widget.min,
              max: widget.max,
              oldValueH: widget.oldValueH,
              newValueH: valueH,
              oldValueL: widget.oldValueL,
              newValueL: valueL,
            ),
          ),
        ),
      ),
    );
  }
}

//==============================================================================
//  painter
//==============================================================================

class BigSliderPainter extends CustomPainter {
  BigSliderPainter({
    @required this.context,
    @required this.min,
    @required this.max,
    @required this.oldValueH,
    @required this.newValueH,
    @required this.oldValueL,
    @required this.newValueL,
  });

  final BuildContext context;
  final double min;
  final double max;
  final double oldValueH;
  final double newValueH;
  final double oldValueL;
  final double newValueL;

  //Size size;

  Offset _handlePos(final Size size, final double angle) {
    return size.center(Offset.zero).translate(cos(angle) * size.width / 2, sin(angle) * size.width / 2);
  }

  Offset _handlePosEx(final Size size, final double angle, final double rate) {
    return size.center(Offset.zero).translate(cos(angle) * size.width*rate / 2, sin(angle) * size.width*rate / 2);
  }

  @override
  void paint(final Canvas canvas, final Size size) {
    //this.size = size;

    print(size.width.toString() + " " +size.height.toString());

//    final Paint backgroundx = Paint()
//      ..color = Colors.pink
//      ..style = PaintingStyle.fill;
//
//    final RenderBox box = context.findRenderObject();
//    final Offset pt = Offset(0,0);
//    final Offset ptx = Offset(size.width,size.height);
//    Rect rt = Rect.fromPoints(pt, ptx);
//    canvas.drawRect(rt, backgroundx);

    //circle rect
    final Rect rect = Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2.0);

    final Paint coldLight = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final Paint warmLight = Paint()
      ..color = Colors.red.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final Paint lightgrey = Paint()
      ..color = Colors.grey[200]
      //..strokeWidth = 6.0
      //..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    final Paint grey = Paint()
      ..color = Colors.grey[300]
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Paint cold = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Paint warm = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Paint handleH = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    final Paint handleL = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    final Paint handleFill = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.fill;

    final Paint background = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final double start = -1.25 * pi;
    final double end = 0.25 * pi;

    final double oldProgressH = (oldValueH - min) / (max - min);
    final double newProgressH = (newValueH - min) / (max - min);
    final double oldAngleH = start + 1.5 * pi * oldProgressH;
    final double newAngleH = start + 1.5 * pi * newProgressH;

    final double oldProgressL = (oldValueL - min) / (max - min);
    final double newProgressL = (newValueL - min) / (max - min);
    final double oldAngleL = start + 1.5 * pi * oldProgressL;
    final double newAngleL = start + 1.5 * pi * newProgressL;

    canvas.drawArc(rect, start, newAngleH - start, true, lightgrey);
    canvas.drawArc(rect, newAngleH, end - newAngleH, true, lightgrey);
    //arc background
    //canvas.drawArc(rect, start, end-start, true, lightgrey);

    canvas.drawArc(rect, start, oldAngleH - start, false, warm);
    canvas.drawArc(rect, oldAngleH, end - oldAngleH, false, grey);

    //draw handleH
    final Offset oldHandlePosH = _handlePos(size, oldAngleH);
    final Offset newHandlePosH = _handlePos(size, newAngleH);
    print("newAngleH:"+newAngleH.toString());
    print("paint H:"+newHandlePosH.dx.toString()+" "+newHandlePosH.dy.toString());
    canvas.drawCircle(oldHandlePosH, 6.0, handleH);
    canvas.drawCircle(newHandlePosH, 12.0, handleH);
    canvas.drawCircle(newHandlePosH, 10.0, handleFill);


    //center white circle
    canvas.drawCircle(size.center(Offset.zero), 0.275 * size.width, background);

    //inner rect
    final Rect rectInner = Rect.fromCircle(center: size.center(Offset.zero), radius: size.width*0.55 / 2.0);

    //inner grey arc
    canvas.drawArc(rectInner, start, oldAngleL - start, false, cold);
    canvas.drawArc(rectInner, oldAngleL, end - oldAngleL, false, grey);

    //draw handleL
    final Offset oldHandlePosL = _handlePosEx(size, oldAngleL, 0.55);
    final Offset newHandlePosL = _handlePosEx(size, newAngleL, 0.55);
    print("newAngleL:"+newAngleL.toString());
    print("paint L:"+newHandlePosL.dx.toString()+" "+newHandlePosL.dy.toString());
    canvas.drawCircle(oldHandlePosL, 6.0, handleL);
    canvas.drawCircle(newHandlePosL, 12.0, handleL);
    canvas.drawCircle(newHandlePosL, 10.0, handleFill);

    // H temperature
    final Color textColorH = Color.lerp(Colors.red, Colors.red, newProgressH);
    final TextStyle textStyleH = TextStyle(color: textColorH, fontSize: 0.08 * size.width);//0.175

    final TextSpan spanH = TextSpan(style: textStyleH, text: "H $newValueH°C");
    final TextPainter tpH = TextPainter(text: spanH, textDirection: TextDirection.ltr);
    tpH.layout();

    final Offset textPosH = size.center(Offset.zero).translate(-tpH.size.width / 2, -tpH.size.height-2);
    tpH.paint(canvas, textPosH);

    //draw line
    final Paint pls = Paint()
      ..color = Colors.grey[400]
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Offset pts = size.center(Offset.zero).translate(-tpH.size.width / 2, 0);
    final Offset pte = size.center(Offset.zero).translate(tpH.size.width / 2, 0);
    canvas.drawLine(pts, pte, pls);

    //L temperature
    final Color textColorL = Color.lerp(Colors.blue, Colors.blue, newProgressL);
    final TextStyle textStyleL = TextStyle(color: textColorL, fontSize: 0.08 * size.width);//0.175

    final TextSpan spanL = TextSpan(style: textStyleL, text: "L $newValueL°C");
    final TextPainter tpL = TextPainter(text: spanL, textDirection: TextDirection.ltr);
    tpL.layout();

    final Offset textPosL = size.center(Offset.zero).translate(-tpL.size.width / 2, 2);
    tpL.paint(canvas, textPosL);

    //draw line
//    final Paint pl = Paint()
//      ..color = Colors.green
//      ..strokeWidth = 5.0
//      ..strokeCap = StrokeCap.round
//      ..style = PaintingStyle.stroke;
//
//    final Offset pt1 = Offset(0,0);
//    final Offset pt2 = Offset(size.width,0);
//    final Offset pt3 = Offset(size.width,size.height);
//    final Offset pt4 = Offset(0,size.height);
//    canvas.drawLine(pt1, pt2, pl);
//    canvas.drawLine(pt2, pt3, pl);
//    canvas.drawLine(pt3, pt4, pl);
//    canvas.drawLine(pt4, pt1, pl);


//    Offset pt1 = box.localToGlobal(pt);
//    List<Offset> points = [pt, Offset(size.width, size.height)];
//    canvas.drawPoints(prefix0.PointMode.points, points, purpleLine);
  }

  @override
  bool shouldRepaint(final BigSliderPainter other) {
    return min != other.min || max != other.max || oldValueH != other.oldValueH || newValueH != other.newValueH;
  }
}
