import 'package:flutter/material.dart';
import 'dart:math';

import '../utils.dart';

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
    final widgetWidth = size.width;
    final widgetHeight = size.height;
    const imageWidth = 240.0;
    const imageHeight = 480.0;

    // local function giúp mình đỡ truyền đi truyền lại 4 biến imageWidth, imageHeight, widgetHeight, widgetWidth
    Offset getWidgetOffset({required Offset imageOffset}) {
      return interpolate(
        imageOffset: imageOffset,
        widgetWidth: widgetWidth,
        widgetHeight: widgetHeight,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      );
    }

    // paint để vẽ nhánh
    final nhanhPaint = Paint()
      ..color = const Color(0xFFaeab5e)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    // paint để vẽ lá là gradient, cần truyền path vào để gradient tô đều lên path
    Paint getLaPaint(Path path) {
      return Paint()
        ..shader = const LinearGradient(colors: [Color(0xFFb9bfb3), Color(0xFFc5dec8)])
            .createShader(path.getBounds())
        ..style = PaintingStyle.fill;
    }

    // vẽ thân
    void drawBody() {
      // offset lấy từ mobilefish và sử dụng hàm nội suy để suy ra offset tương ứng với widget
      // sở dĩ mình ko cần sử dụng hàm getControlPointsOfCubic vì khi mình vẽ cái này, mình ko cần phải quá chính xác
      // nên mình dựa vào giác quan thứ 6 để dự đoán chính xác các điểm control mà ko cần dùng hàm để suy ra
      // nếu ae thích chính xác thì cứ dùng hàm getControlPointsOfCubic giống ví dụ về con sông và túi thần kỳ nhá
      final Offset start = getWidgetOffset(imageOffset: const Offset(165, 419));
      final Offset control1 = getWidgetOffset(imageOffset: const Offset(57, 297));
      final Offset control2 = getWidgetOffset(imageOffset: const Offset(159, 219));
      final Offset end = getWidgetOffset(imageOffset: const Offset(128, 120));

      canvas.drawPath(
          Path()
            ..moveTo(start.dx, start.dy)
            ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy),
          nhanhPaint);
    }

    // vẽ nhánh 1
    void drawNhanh1() {
      // offset lấy từ mobilefish và sử dụng hàm nội suy để suy ra offset tương ứng với widget
      final Offset start = getWidgetOffset(imageOffset: const Offset(117, 326));
      final Offset control1 = getWidgetOffset(imageOffset: const Offset(135, 291));
      final Offset control2 = getWidgetOffset(imageOffset: const Offset(158, 273));
      final Offset end = getWidgetOffset(imageOffset: const Offset(189, 262));

      canvas.drawPath(
          Path()
            ..moveTo(start.dx, start.dy)
            ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy),
          nhanhPaint);
    }

    // vẽ nhánh 2
    void drawNhanh2() {
      // offset lấy từ mobilefish và sử dụng hàm nội suy để suy ra offset tương ứng với widget
      final Offset start = getWidgetOffset(imageOffset: const Offset(115, 285));
      final Offset control1 = getWidgetOffset(imageOffset: const Offset(105, 253));
      final Offset control2 = getWidgetOffset(imageOffset: const Offset(81, 230));
      final Offset end = getWidgetOffset(imageOffset: const Offset(46, 218));

      canvas.drawPath(
          Path()
            ..moveTo(start.dx, start.dy)
            ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy),
          nhanhPaint);
    }

    // vẽ nhánh 3
    void drawNhanh3() {
      // offset lấy từ mobilefish và sử dụng hàm nội suy để suy ra offset tương ứng với widget
      final Offset start = getWidgetOffset(imageOffset: const Offset(121, 246));
      final Offset control1 = getWidgetOffset(imageOffset: const Offset(119, 209));
      final Offset control2 = getWidgetOffset(imageOffset: const Offset(102, 175));
      final Offset end = getWidgetOffset(imageOffset: const Offset(71, 140));

      canvas.drawPath(
          Path()
            ..moveTo(start.dx, start.dy)
            ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy),
          nhanhPaint);
    }

    // vẽ nhánh 4
    void drawNhanh4() {
      // offset lấy từ mobilefish và sử dụng hàm nội suy để suy ra offset tương ứng với widget
      final Offset start = getWidgetOffset(imageOffset: const Offset(121, 246));
      final Offset control1 = getWidgetOffset(imageOffset: const Offset(127, 204));
      final Offset control2 = getWidgetOffset(imageOffset: const Offset(146, 170));
      final Offset end = getWidgetOffset(imageOffset: const Offset(182, 145));

      canvas.drawPath(
          Path()
            ..moveTo(start.dx, start.dy)
            ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy),
          nhanhPaint);
    }

    // vẽ lá 1
    void drawLa1() {
      // offset lấy từ mobilefish và sử dụng hàm nội suy để suy ra offset tương ứng với widget
      final Offset start = getWidgetOffset(imageOffset: const Offset(139, 294));
      final Offset control1 = getWidgetOffset(imageOffset: const Offset(168, 305));
      final Offset control2 = getWidgetOffset(imageOffset: const Offset(190, 286));
      final Offset end = getWidgetOffset(imageOffset: const Offset(207, 246));
      final Offset control3 = getWidgetOffset(imageOffset: const Offset(160, 245));
      final Offset control4 = getWidgetOffset(imageOffset: const Offset(135, 260));

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy)
        ..cubicTo(control3.dx, control3.dy, control4.dx, control4.dy, start.dx, start.dy);
      canvas.drawPath(path, getLaPaint(path));
    }

    // vẽ lá 2
    void drawLa2() {
      // offset lấy từ mobilefish và sử dụng hàm nội suy để suy ra offset tương ứng với widget
      final Offset start = getWidgetOffset(imageOffset: const Offset(100, 256));
      final Offset control1 = getWidgetOffset(imageOffset: const Offset(64, 267));
      final Offset control2 = getWidgetOffset(imageOffset: const Offset(54, 259));
      final Offset end = getWidgetOffset(imageOffset: const Offset(30, 209));
      final Offset control3 = getWidgetOffset(imageOffset: const Offset(100, 214));

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy)
        ..quadraticBezierTo(control3.dx, control3.dy, start.dx, start.dy);
      canvas.drawPath(path, getLaPaint(path));
    }

    // vẽ lá 3
    void drawLa3() {
      // offset lấy từ mobilefish và sử dụng hàm nội suy để suy ra offset tương ứng với widget
      final Offset start = getWidgetOffset(imageOffset: const Offset(98, 176));
      final Offset control1 = getWidgetOffset(imageOffset: const Offset(62, 173));
      final Offset end = getWidgetOffset(imageOffset: const Offset(59, 122));
      final Offset control2 = getWidgetOffset(imageOffset: const Offset(104, 142));

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control1.dx, control1.dy, end.dx, end.dy)
        ..quadraticBezierTo(control2.dx, control2.dy, start.dx, start.dy);
      canvas.drawPath(path, getLaPaint(path));
    }

    // vẽ lá 4
    void drawLa4() {
      // offset lấy từ mobilefish và sử dụng hàm nội suy để suy ra offset tương ứng với widget
      final Offset start = getWidgetOffset(imageOffset: const Offset(141, 187));
      final Offset control1 = getWidgetOffset(imageOffset: const Offset(140, 140));
      final Offset end = getWidgetOffset(imageOffset: const Offset(200, 126));
      final Offset control2 = getWidgetOffset(imageOffset: const Offset(188, 188));

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control1.dx, control1.dy, end.dx, end.dy)
        ..quadraticBezierTo(control2.dx, control2.dy, start.dx, start.dy);
      canvas.drawPath(path, getLaPaint(path));
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
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
