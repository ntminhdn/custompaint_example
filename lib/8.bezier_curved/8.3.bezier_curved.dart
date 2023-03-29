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
      size: const Size(300, 300),
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

    final scaleRatio = getScaleRatio(
      canvasWidth: widgetWidth,
      canvasHeight: widgetHeight,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
    canvas.scale(scaleRatio);

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

    // vẽ xong leftPath
    final leftPath = Path()
      ..moveTo(leftMobileFishStart.dx, leftMobileFishStart.dy)
      ..cubicTo(
          leftMobileFishControlPoints[0].dx,
          leftMobileFishControlPoints[0].dy,
          leftMobileFishControlPoints[1].dx,
          leftMobileFishControlPoints[1].dy,
          leftMobileFishEnd.dx,
          leftMobileFishEnd.dy);

    // dùng phép tịnh tiến để vẽ nhanh rightPath từ leftPath
    const shiftVector = Offset(180, 0);
    final rightPath = leftPath.shift(shiftVector);

    // vẽ cái túi thần kỳ ở giữa dòng sông
    // điểm đầu và điểm cuối trùng với 2 nhánh dòng sông rồi nên khỏi cần lấy toạ độ từ mobifish nữa
    const pocketMobileFishStart = leftMobileFish70;
    final pocketMobileFishEnd = leftMobileFish70 + shiftVector;

    // Để vẽ Quadratic curve, ta cần lấy thêm điểm chính giữa túi từ mobilefish
    final pocketMobileFish50 =
        Offset((pocketMobileFishStart.dx + pocketMobileFishEnd.dx) / 2, 526);

    // Nhờ 3 điểm trên mà ta tìm được toạ độ điểm control nhờ hàm này
    // Chú ý đây chỉ là điểm control point tương ứng với mobilefish, chưa phải tương ứng với size của widget
    final pocketMobileFishControlPoint = getControlPointOfQuadratic(
      t: 0.5,
      pointAtT: pocketMobileFish50,
      startPoint: pocketMobileFishStart,
      endPoint: pocketMobileFishEnd,
    );

    // vẽ cái túi thần kỳ
    final centerPath = Path()
      ..moveTo(pocketMobileFishStart.dx, pocketMobileFishStart.dy)
      ..quadraticBezierTo(
          pocketMobileFishControlPoint.dx,
          pocketMobileFishControlPoint.dy,
          pocketMobileFishEnd.dx,
          pocketMobileFishEnd.dy)
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
