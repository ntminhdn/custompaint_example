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

    // Để vẽ cubic curve, ta cần toạ độ điểm đầu, điểm cuối và 2 toạ độ bất kỳ từ mobilefish
    const leftMobileFishStart = Offset(124, 44);
    const leftMobileFish50 = Offset(119, 354);
    const leftMobileFish70 = Offset(166, 473);
    const leftMobileFishEnd = Offset(124, 686);

    // Nhờ 4 điểm trên mà ta tìm được toạ độ 2 điểm control nhờ hàm này
    // Chú ý đây chỉ là 2 điểm control point tương ứng với mobilefish, chưa phải tương ứng với size của widget
    final leftMobileFishControlPoints = getControlPointsOfCubic(
      t1: 0.5,
      pointAtT1: leftMobileFish50,
      t2: 0.7,
      pointAtT2: leftMobileFish70,
      startPoint: leftMobileFishStart,
      endPoint: leftMobileFishEnd,
    );

    // từ toạ độ mobilefish, ta nội suy ra toạ độ tương ứng với size của widget
    final leftStart = getWidgetOffset(imageOffset: leftMobileFishStart);
    final leftControl1 = getWidgetOffset(imageOffset: leftMobileFishControlPoints[0]);
    final leftControl2 = getWidgetOffset(imageOffset: leftMobileFishControlPoints[1]);
    final leftEnd = getWidgetOffset(imageOffset: leftMobileFishEnd);

    // vẽ xong leftPath
    final leftPath = Path()
      ..moveTo(leftStart.dx, leftStart.dy)
      ..cubicTo(leftControl1.dx, leftControl1.dy, leftControl2.dx, leftControl2.dy, leftEnd.dx, leftEnd.dy);

    // dùng phép tịnh tiến để vẽ nhanh rightPath từ leftPath
    const shiftVector = Offset(180, 0);
    final rightPath = leftPath.shift(shiftVector);

    // vẽ cái túi thần kỳ ở giữa dòng sông
    // điểm đầu và điểm cuối trùng với 2 nhánh dòng sông rồi nên khỏi cần lấy toạ độ từ mobifish nữa
    const pocketMobileFishStart = leftMobileFish70;
    final pocketMobileFishEnd = leftMobileFish70 + shiftVector;

    // Để vẽ Quadratic curve, ta cần lấy thêm điểm chính giữa túi từ mobilefish
    const pocketMobileFish50 = Offset(256, 526);

    // Nhờ 3 điểm trên mà ta tìm được toạ độ điểm control nhờ hàm này
    // Chú ý đây chỉ là điểm control point tương ứng với mobilefish, chưa phải tương ứng với size của widget
    final pocketMobileFishControlPoint = getControlPointOfQuadratic(
      t: 0.5,
      pointAtT: pocketMobileFish50,
      startPoint: pocketMobileFishStart,
      endPoint: pocketMobileFishEnd,
    );

    // từ toạ độ mobilefish, ta nội suy ra toạ độ tương ứng với size của widget
    final pocketStart = getWidgetOffset(imageOffset: pocketMobileFishStart);
    final pocketControl = getWidgetOffset(imageOffset: pocketMobileFishControlPoint);
    final pocketEnd = pocketStart + shiftVector;

    // vẽ cái túi thần kỳ
    final centerPath = Path()
      ..moveTo(pocketStart.dx, pocketStart.dy)
      ..quadraticBezierTo(pocketControl.dx, pocketControl.dy, pocketEnd.dx, pocketEnd.dy)
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
