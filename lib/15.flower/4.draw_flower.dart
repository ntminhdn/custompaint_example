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

    final scaleRatio = getScaleRatio(
      canvasWidth: widgetWidth,
      canvasHeight: widgetHeight,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );

    canvas.scale(scaleRatio);

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

    // paint để vẽ hoa lớn
    final hoaPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFfcc2ae);

    // paint để vẽ hoa nhỏ
    final hoaNhoPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFf9ad93);

    // paint để vẽ nhuỵ hoa
    final nhuyHoaPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFee946f);

    // vẽ thân
    void drawBody() {
      // offset lấy từ mobilefish và sử dụng hàm nội suy để suy ra offset tương ứng với widget
      // sở dĩ mình ko cần sử dụng hàm getControlPointsOfCubic vì khi mình vẽ cái này, mình ko cần phải quá chính xác
      // nên mình dựa vào giác quan thứ 6 để dự đoán chính xác các điểm control mà ko cần dùng hàm để suy ra
      // nếu ae thích chính xác thì cứ dùng hàm getControlPointsOfCubic giống ví dụ về con sông và túi thần kỳ nhá
      const start = Offset(165, 419);
      const control1 = Offset(57, 297);
      const control2 = Offset(159, 219);
      const end = Offset(128, 120);

      canvas.drawPath(
          Path()
            ..moveTo(start.dx, start.dy)
            ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy),
          nhanhPaint);
    }

    // vẽ nhánh 1
    void drawNhanh1() {
      // offset lấy từ mobilefish và sử dụng hàm nội suy để suy ra offset tương ứng với widget
      const start = Offset(117, 326);
      const control1 = Offset(135, 291);
      const control2 = Offset(158, 273);
      const end = Offset(189, 262);

      canvas.drawPath(
          Path()
            ..moveTo(start.dx, start.dy)
            ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy),
          nhanhPaint);
    }

    // vẽ nhánh 2
    void drawNhanh2() {
      // offset lấy từ mobilefish và sử dụng hàm nội suy để suy ra offset tương ứng với widget
      const start = Offset(115, 285);
      const control1 = Offset(105, 253);
      const control2 = Offset(81, 230);
      const end = Offset(46, 218);

      canvas.drawPath(
          Path()
            ..moveTo(start.dx, start.dy)
            ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy),
          nhanhPaint);
    }

    // vẽ nhánh 3
    void drawNhanh3() {
      // offset lấy từ mobilefish và sử dụng hàm nội suy để suy ra offset tương ứng với widget
      const start = Offset(121, 246);
      const control1 = Offset(119, 209);
      const control2 = Offset(102, 175);
      const end = Offset(71, 140);

      canvas.drawPath(
          Path()
            ..moveTo(start.dx, start.dy)
            ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy),
          nhanhPaint);
    }

    // vẽ nhánh 4
    void drawNhanh4() {
      // offset lấy từ mobilefish và sử dụng hàm nội suy để suy ra offset tương ứng với widget
      const start = Offset(121, 246);
      const control1 = Offset(127, 204);
      const control2 = Offset(146, 170);
      const end = Offset(182, 145);

      canvas.drawPath(
          Path()
            ..moveTo(start.dx, start.dy)
            ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy),
          nhanhPaint);
    }

    // vẽ lá 1
    void drawLa1() {
      // offset lấy từ mobilefish và sử dụng hàm nội suy để suy ra offset tương ứng với widget
      const start = Offset(139, 294);
      const control1 = Offset(168, 305);
      const control2 = Offset(190, 286);
      const end = Offset(207, 246);
      const control3 = Offset(160, 245);
      const control4 = Offset(135, 260);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy)
        ..cubicTo(control3.dx, control3.dy, control4.dx, control4.dy, start.dx, start.dy);
      canvas.drawPath(path, getLaPaint(path));
    }

    // vẽ lá 2
    void drawLa2() {
      // offset lấy từ mobilefish và sử dụng hàm nội suy để suy ra offset tương ứng với widget
      const start = Offset(100, 256);
      const control1 = Offset(64, 267);
      const control2 = Offset(54, 259);
      const end = Offset(30, 209);
      const control3 = Offset(100, 214);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy)
        ..quadraticBezierTo(control3.dx, control3.dy, start.dx, start.dy);
      canvas.drawPath(path, getLaPaint(path));
    }

    // vẽ lá 3
    void drawLa3() {
      // offset lấy từ mobilefish và sử dụng hàm nội suy để suy ra offset tương ứng với widget
      const start = Offset(98, 176);
      const control1 = Offset(62, 173);
      const end = Offset(59, 122);
      const control2 = Offset(104, 142);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control1.dx, control1.dy, end.dx, end.dy)
        ..quadraticBezierTo(control2.dx, control2.dy, start.dx, start.dy);
      canvas.drawPath(path, getLaPaint(path));
    }

    // vẽ lá 4
    void drawLa4() {
      // offset lấy từ mobilefish và sử dụng hàm nội suy để suy ra offset tương ứng với widget
      const start = Offset(141, 187);
      const control1 = Offset(140, 140);
      const end = Offset(200, 126);
      const control2 = Offset(188, 188);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control1.dx, control1.dy, end.dx, end.dy)
        ..quadraticBezierTo(control2.dx, control2.dy, start.dx, start.dy);
      canvas.drawPath(path, getLaPaint(path));
    }

    void drawFlower() {
      canvas.save();

      // tịnh tiến gốc toạ độ đến tâm của nhuỵ hoa
      const newOrigin = Offset(124, 99);
      canvas.translate(newOrigin.dx, newOrigin.dy);

      // offset lấy từ mobilefish và sử dụng hàm nội suy để suy ra offset tương ứng với widget
      // 1 cánh hoa sẽ có 4 đường cong
      // đường cong 1
      const c1 = Offset(7, -45);
      const c2 = Offset(38, -40);
      const b = Offset(36, -28);

      // đường cong 2
      const c3 = Offset(44, -28);
      const c = Offset(43, -21);

      // đường cong 3
      const c4 = Offset(53, -19);
      const d = Offset(47, -9);

      // đường cong 4
      const c5 = Offset(56, -1);
      const c6 = Offset(42, 10);

      final path = Path()
        ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, b.dx, b.dy)
        ..quadraticBezierTo(c3.dx, c3.dy, c.dx, c.dy)
        ..quadraticBezierTo(c4.dx, c4.dy, d.dx, d.dy)
        ..cubicTo(c5.dx, c5.dy, c6.dx, c6.dy, 0, 0);

      // vẽ 1 cánh hoa lớn
      canvas.drawPath(path, hoaPaint);

      // scale nhỏ lại 0.5 để vẽ cánh hoa bên trong
      canvas.save();
      canvas.scale(0.5);

      // vẽ 1 cánh hoa nhỏ.
      // Ta vẫn truyền cái path cánh hoa ở trên vào
      // vì ta sử dụng phép vị tự để scale nhỏ cánh hoa lớn thành cánh hoa nhỏ chứ kiểu dáng vẫn y như cánh hoa lớn
      // nên ko cần phải tạo ra Path khác
      canvas.drawPath(path, hoaNhoPaint);

      // pop canvas về trạng thái trước khi scale để chuẩn bị rotate canvas
      canvas.restore();

      // Muốn vẽ 5 cánh hoa thì lấy 360 độ / 5 tức 2 pi / 5
      const double rotateAngle = pi * 2 / 5;

      // loop 4 lần để vẽ 4 cánh hoa còn lại
      for (int i = 0; i < 4; i++) {
        // xoay canvas
        canvas.rotate(rotateAngle);

        // vẽ cánh hoa lớn
        canvas.drawPath(path, hoaPaint);

        // scale nhỏ lại
        canvas.save();
        canvas.scale(0.5);

        // vẽ cánh hoa nhỏ
        canvas.drawPath(path, hoaNhoPaint);

        // pop canvas về trạng thái trước khi scale để tiếp tục rotate canvas
        canvas.restore();
      }

      // vẽ nhuỵ hoa
      canvas.drawCircle(Offset.zero, 6, nhuyHoaPaint);

      // pop canvas về trạng thái trước khi translate và rotate, tức là trạng thái default ban đầu
      // ae nhớ là save() bao nhiêu lần thì phải restore() bấy nhiêu lần
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
