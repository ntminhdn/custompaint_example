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
    canvas.drawCircle(centerPoint, radius, whitePaint); // vẽ nền
    canvas.drawCircle(centerPoint, radius, blackPaint); // vẽ viền
    canvas.drawPoints(PointMode.points, [centerPoint], redPaint); // vẽ điểm chính giữa

    canvas.save(); // save trạng thái canvas hiện tại vào stack
    canvas.translate(centerPoint.dx, centerPoint.dy); // dịch chuyển gốc toạ độ (0,0) đến vị trí chính giữa
    
    // vẽ 12 mốc giờ. Mốc 3,6,9,12 sẽ vẽ Text, các mốc còn lại vẽ Line
    for (var i = 0; i < 12; i++) {
      canvas.save(); // save trạng thái canvas hiện tại vào stack, tức là trạng thái sau khi tịnh tiến

      if (i == 0) {
        // dịch chuyển gốc toạ độ lên phía trên, đến vị trí cách top 10 pixel
        canvas.translate(0, -(radius - clockPadding));
        canvas.drawText(text: '12', textStyle: textStyle, x: 0, y: 0, alignment: TextAlignment.topCenter);
      } else if (i == 3) {
        // dịch chuyển gốc toạ độ sang bên phải, đến vị trí cách mép phải 10 pixel
        canvas.translate(radius - clockPadding, 0);
        canvas.drawText(text: '3', textStyle: textStyle, x: 0, y: 0, alignment: TextAlignment.centerRight);
      } else if (i == 6) {
        // dịch chuyển gốc toạ độ xuống phía dưới, đến vị trí cách bottom 10 pixel
        canvas.translate(0, radius - clockPadding);
        canvas.drawText(text: '6', textStyle: textStyle, x: 0, y: 0, alignment: TextAlignment.bottomCenter);
      } else if (i == 9) {
        // dịch chuyển gốc toạ độ sang bên trái, đến vị trí cách mép trái 10 pixel
        canvas.translate(-(radius - clockPadding), 0);
        canvas.drawText(text: '9', textStyle: textStyle, x: 0, y: 0, alignment: TextAlignment.centerLeft);
      } else {
        // khi i bằng 1 -> xoay 30 độ theo chiều kim đồng hồ
        // khi i bằng 2 -> xoay 60 độ theo chiều kim đồng hồ
        // khi i bằng 4 -> xoay 120 độ theo chiều kim đồng hồ
        // ...
        // khi i bằng 11 -> xoay 330 độ theo chiều kim đồng hồ
        canvas.rotate((360 * i / 12).toRadian());
        canvas.drawLine(Offset(0, -(radius - clockPadding)),
            Offset(0, -(radius - clockPadding - lineLong)), blackPaint);
      }

      // pop trạng thái stack hiện tại, tức là sau khi đã rotate hoặc translate (đối với i = 0,3,6,9)
      // để về lại trạng thái cũ, tức là trạng thái trước khi rotate hoặc translate (đối với i = 0,3,6,9)
      // Sở dĩ phải làm như vậy là vì khi i = 1, ta đã xoay canvas đi 30 độ rồi,
      // hoặc ta đã translate gốc toạ độ đi chỗ khác rồi (khi i = 0,3,6,9), nó ko còn ở chính giữa màn hình nữa
      // nên nếu khi i = 2, ta tiếp tục xoay 60 độ nữa thì thành ra ta xoay 90 độ so với ban đầu -> BUG.
      canvas.restore();
    }

    // pop trạng thái sau khi canvas translate về trước khi translate luôn
    // sau khi pop thì gốc toạ độ bây giờ trở về vị trí left-top màn hình, ko còn ở chính giữa màn hình nữa
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
