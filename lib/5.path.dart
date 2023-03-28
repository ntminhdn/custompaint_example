import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('5. Path'),
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: CustomPaint(
            size: const Size(300, 300),
            painter: MyCustomPainter(),
          ),
        ),
      ),
    ),
  );
}

class MyCustomPainter extends CustomPainter {
  final redPaint = Paint()
    ..color = Colors.red
    ..strokeWidth = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final path = Path()
      ..moveTo(width / 2, 0)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();

    canvas.drawPath(path, redPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
