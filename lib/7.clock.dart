import 'dart:math';
import 'dart:ui';

import 'package:custompaint_example/utils.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('8. Vẽ đồng hồ'),
        ),
        backgroundColor: Colors.grey,
        body: const Center(
          child: Clock(),
        ),
      ),
    ),
  );
}

class Clock extends StatelessWidget {
  const Clock({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(300, 300),
      painter: MyCustomPainter(),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final whitePaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  final blackPaint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  final redPaint = Paint()
    ..color = Colors.red
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 10;

  static const clockPadding = 10.0;
  static const lineLong = 16.0;

  static const textStyle = TextStyle(color: Colors.black, fontSize: 22);

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final radius = min(width, height) / 2;
    final centerPoint = Offset(width / 2, height / 2);
    canvas.drawCircle(centerPoint, radius, whitePaint);
    canvas.drawCircle(centerPoint, radius, blackPaint);
    canvas.drawPoints(PointMode.points, [centerPoint], redPaint);

    canvas.save();
    canvas.translate(centerPoint.dx, centerPoint.dy);
    for (var i = 0; i < 12; i++) {
      canvas.save();
      if (i == 0) {
        canvas.translate(0, -(radius - clockPadding));
        canvas.drawText('12', textStyle, 0, 0, TextAlignment.topCenter);
      } else if (i == 3) {
        canvas.translate(radius - clockPadding, 0);
        canvas.drawText('3', textStyle, 0, 0, TextAlignment.centerRight);
      } else if (i == 6) {
        canvas.translate(0, radius - clockPadding);
        canvas.drawText('6', textStyle, 0, 0, TextAlignment.bottomCenter);
      } else if (i == 9) {
        canvas.translate(-(radius - clockPadding), 0);
        canvas.drawText('9', textStyle, 0, 0, TextAlignment.centerLeft);
      } else {
        canvas.rotate((360 * i / 12).toRadian());
        canvas.drawLine(Offset(0, -(radius - clockPadding)),
            Offset(0, -(radius - clockPadding - lineLong)), blackPaint);
      }
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
