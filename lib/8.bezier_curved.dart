import 'package:custompaint_example/utils.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('14. Bezier curve'),
        ),
        backgroundColor: Colors.black,
        body: const Center(
          child: Bezier(),
        ),
      ),
    ),
  );
}

class Bezier extends StatelessWidget {
  const Bezier({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: MyCustomPainter(),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final whitePaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  @override
  void paint(Canvas canvas, Size size) {
    const imageWidth = 456.0;
    const imageHeight = 752.0;
    final widgetWidth = size.width;
    final widgetHeight = size.height;

    // from mobilefish
    const leftTemp0 = Offset(124, 44);
    const leftTemp50 = Offset(119, 354);
    const leftTemp70 = Offset(166, 473);
    const leftTemp100 = Offset(124, 686);
    final leftTempControlPoints =
        getControlPointsOfCubic(0.5, leftTemp50, 0.7, leftTemp70, leftTemp0, leftTemp100);

    final leftP0 = interpolate(leftTemp0, widgetWidth, widgetHeight, imageWidth, imageHeight);
    final leftP1 =
        interpolate(leftTempControlPoints[0], widgetWidth, widgetHeight, imageWidth, imageHeight);
    final leftP2 =
        interpolate(leftTempControlPoints[1], widgetWidth, widgetHeight, imageWidth, imageHeight);
    final leftP3 = interpolate(leftTemp100, widgetWidth, widgetHeight, imageWidth, imageHeight);

    final leftPath = Path()
      ..moveTo(leftP0.dx, leftP0.dy)
      ..cubicTo(leftP1.dx, leftP1.dy, leftP2.dx, leftP2.dy, leftP3.dx, leftP3.dy);

    const shiftVector = Offset(180, 0);
    final rightPath = leftPath.shift(shiftVector);

    const centerTemp0 = leftTemp70;
    // from mobilefish
    const centerTemp50 = Offset(256, 526);
    final centerTemp100 = leftTemp70 + shiftVector;
    final centerTempControlPoint =
        getControlPointOfQuadratic(0.5, centerTemp50, centerTemp0, centerTemp100);

    final centerP0 = interpolate(centerTemp0, widgetWidth, widgetHeight, imageWidth, imageHeight);
    final centerP1 =
        interpolate(centerTempControlPoint, widgetWidth, widgetHeight, imageWidth, imageHeight);
    final centerP2 = centerP0 + shiftVector;
    final centerPath = Path()
      ..moveTo(centerP0.dx, centerP0.dy)
      ..quadraticBezierTo(centerP1.dx, centerP1.dy, centerP2.dx, centerP2.dy)
      ..close();

    canvas.drawPath(leftPath, whitePaint);
    canvas.drawPath(rightPath, whitePaint);
    canvas.drawPath(centerPath, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
