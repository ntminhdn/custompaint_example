import 'package:flutter/material.dart';
import 'dart:math';

import 'utils.dart';

void main() {
  runApp(const MaterialApp(
    home: SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Flower(),
        ),
      ),
    ),
  ));
}

class Flower extends StatelessWidget {
  const Flower({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: FlowerPainter(),
      size: const Size(250, 375),
    );
  }
}

class FlowerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final nhanhPaint = Paint()
      ..color = const Color(0xFFaeab5e)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    Paint getLaPaint(Path path) {
      return Paint()
        ..shader = const LinearGradient(colors: [Color(0xFFb9bfb3), Color(0xFFc5dec8)])
            .createShader(path.getBounds())
        ..style = PaintingStyle.fill;
    }

    final hoaPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFfcc2ae);

    final nhuyHoaPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFf9ad93);

    // vẽ thân
    void drawBody() {
      final Offset start = interpolate(const Offset(165, 419), width, height, 240, 480);
      final Offset control1 = interpolate(const Offset(57, 297), width, height, 240, 480);
      final Offset control2 = interpolate(const Offset(159, 219), width, height, 240, 480);
      final Offset end = interpolate(const Offset(128, 120), width, height, 240, 480);

      canvas.drawPath(
          Path()
            ..moveTo(start.dx, start.dy)
            ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy),
          nhanhPaint);
    }

    // vẽ nhánh 1
    void drawNhanh1() {
      final Offset start = interpolate(const Offset(117, 326), width, height, 240, 480);
      final Offset control1 = interpolate(const Offset(135, 291), width, height, 240, 480);
      final Offset control2 = interpolate(const Offset(158, 273), width, height, 240, 480);
      final Offset end = interpolate(const Offset(189, 262), width, height, 240, 480);

      canvas.drawPath(
          Path()
            ..moveTo(start.dx, start.dy)
            ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy),
          nhanhPaint);
    }

    // vẽ nhánh 2
    void drawNhanh2() {
      final Offset start = interpolate(const Offset(115, 285), width, height, 240, 480);
      final Offset control1 = interpolate(const Offset(105, 253), width, height, 240, 480);
      final Offset control2 = interpolate(const Offset(81, 230), width, height, 240, 480);
      final Offset end = interpolate(const Offset(46, 218), width, height, 240, 480);

      canvas.drawPath(
          Path()
            ..moveTo(start.dx, start.dy)
            ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy),
          nhanhPaint);
    }

    // vẽ nhánh 3
    void drawNhanh3() {
      final Offset start = interpolate(const Offset(121, 246), width, height, 240, 480);
      final Offset control1 = interpolate(const Offset(119, 209), width, height, 240, 480);
      final Offset control2 = interpolate(const Offset(102, 175), width, height, 240, 480);
      final Offset end = interpolate(const Offset(71, 140), width, height, 240, 480);

      canvas.drawPath(
          Path()
            ..moveTo(start.dx, start.dy)
            ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy),
          nhanhPaint);
    }

    // vẽ nhánh 4
    void drawNhanh4() {
      final Offset start = interpolate(const Offset(121, 246), width, height, 240, 480);
      final Offset control1 = interpolate(const Offset(127, 204), width, height, 240, 480);
      final Offset control2 = interpolate(const Offset(146, 170), width, height, 240, 480);
      final Offset end = interpolate(const Offset(182, 145), width, height, 240, 480);

      canvas.drawPath(
          Path()
            ..moveTo(start.dx, start.dy)
            ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy),
          nhanhPaint);
    }

    // vẽ lá 1
    void drawLa1() {
      final Offset start = interpolate(const Offset(139, 294), width, height, 240, 480);
      final Offset control1 = interpolate(const Offset(168, 305), width, height, 240, 480);
      final Offset control2 = interpolate(const Offset(190, 286), width, height, 240, 480);
      final Offset end = interpolate(const Offset(207, 246), width, height, 240, 480);
      final Offset control3 = interpolate(const Offset(160, 245), width, height, 240, 480);
      final Offset control4 = interpolate(const Offset(135, 260), width, height, 240, 480);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy)
        ..cubicTo(control3.dx, control3.dy, control4.dx, control4.dy, start.dx, start.dy);
      canvas.drawPath(path, getLaPaint(path));
    }

    // vẽ lá 2
    void drawLa2() {
      final Offset start = interpolate(const Offset(100, 256), width, height, 240, 480);
      final Offset control1 = interpolate(const Offset(64, 267), width, height, 240, 480);
      final Offset control2 = interpolate(const Offset(54, 259), width, height, 240, 480);
      final Offset end = interpolate(const Offset(30, 209), width, height, 240, 480);
      final Offset control3 = interpolate(const Offset(100, 214), width, height, 240, 480);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy)
        ..quadraticBezierTo(control3.dx, control3.dy, start.dx, start.dy);
      canvas.drawPath(path, getLaPaint(path));
    }

    // vẽ lá 3
    void drawLa3() {
      final Offset start = interpolate(const Offset(98, 176), width, height, 240, 480);
      final Offset control1 = interpolate(const Offset(62, 173), width, height, 240, 480);
      final Offset end = interpolate(const Offset(59, 122), width, height, 240, 480);
      final Offset control2 = interpolate(const Offset(104, 142), width, height, 240, 480);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control1.dx, control1.dy, end.dx, end.dy)
        ..quadraticBezierTo(control2.dx, control2.dy, start.dx, start.dy);
      canvas.drawPath(path, getLaPaint(path));
    }

    // vẽ lá 4
    void drawLa4() {
      final Offset start = interpolate(const Offset(141, 187), width, height, 240, 480);
      final Offset control1 = interpolate(const Offset(140, 140), width, height, 240, 480);
      final Offset end = interpolate(const Offset(200, 126), width, height, 240, 480);
      final Offset control2 = interpolate(const Offset(188, 188), width, height, 240, 480);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control1.dx, control1.dy, end.dx, end.dy)
        ..quadraticBezierTo(control2.dx, control2.dy, start.dx, start.dy);
      canvas.drawPath(path, getLaPaint(path));
    }

    void drawFlower() {
      canvas.save();

      final Offset newOrigin = interpolate(const Offset(124, 99), width, height, 240, 480);
      canvas.translate(newOrigin.dx, newOrigin.dy);

      final c1 = interpolate(const Offset(7, -45), width, height, 240, 480);
      final c2 = interpolate(const Offset(38, -40), width, height, 240, 480);
      final b = interpolate(const Offset(36, -28), width, height, 240, 480);

      final c3 = interpolate(const Offset(44, -28), width, height, 240, 480);
      final c = interpolate(const Offset(43, -21), width, height, 240, 480);

      final c4 = interpolate(const Offset(53, -19), width, height, 240, 480);
      final d = interpolate(const Offset(47, -9), width, height, 240, 480);

      final c5 = interpolate(const Offset(56, -1), width, height, 240, 480);
      final c6 = interpolate(const Offset(42, 10), width, height, 240, 480);

      final path = Path()
        ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, b.dx, b.dy)
        ..quadraticBezierTo(c3.dx, c3.dy, c.dx, c.dy)
        ..quadraticBezierTo(c4.dx, c4.dy, d.dx, d.dy)
        ..cubicTo(c5.dx, c5.dy, c6.dx, c6.dy, 0, 0);

      canvas.drawPath(path, hoaPaint);
      canvas.save();
      canvas.scale(0.5);
      canvas.drawPath(path, nhuyHoaPaint);
      canvas.restore();

      const double rotateAngle = pi / 2.5;

      for (int i = 0; i < 4; i++) {
        canvas.rotate(rotateAngle);
        canvas.drawPath(path, hoaPaint);
        canvas.save();
        canvas.scale(0.5);
        canvas.drawPath(path, nhuyHoaPaint);
        canvas.restore();
      }

      canvas.drawCircle(
          Offset.zero,
          6,
          Paint()
            ..style = PaintingStyle.fill
            ..color = const Color(0xFFee946f));

      canvas.restore();
    }

    drawBody();
    drawLa1();
    drawLa2();
    drawLa3();
    drawLa4();
    drawNhanh1();
    drawNhanh2();
    drawNhanh3();
    drawNhanh4();
    drawFlower();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
