import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomPaint(
            painter: CubicBezierPainter(), size: Size.infinite,), // size full màn hình
        ),
      ),
    );
  }
}


class CubicBezierPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const startPoint = Offset(30, 180);
    const endPoint = Offset(200, 450);
    const controlPoint = Offset(120, 160);
    const controlPoint2 = Offset(80, 430);

    final path = Path()
      ..moveTo(startPoint.dx, startPoint.dy)
      ..cubicTo(
          controlPoint.dx, controlPoint.dy, controlPoint2.dx, controlPoint2.dy ,endPoint.dx, endPoint.dy);

    // tạo paint vẽ đường cong
    final paintCurve = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round // bo tròn điểm đầu và cuối của đường cong
      ..strokeWidth = 3;

    canvas.drawPath(path, paintCurve);

    // tạo paint vẽ điểm
    final paintPoint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;

    // cách vẽ tập hợp một list điểm trong Flutter
    canvas.drawPoints(PointMode.points, [startPoint, endPoint, controlPoint, controlPoint2], paintPoint);

    // tạo paint vẽ line
    final paintLine = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;

    // cách vẽ line trong Flutter
    canvas.drawLine(startPoint, controlPoint, paintLine);
    canvas.drawLine(endPoint, controlPoint2, paintLine);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
