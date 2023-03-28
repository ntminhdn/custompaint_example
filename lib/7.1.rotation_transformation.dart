import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('2. Flag of Japan'),
        ),
        backgroundColor: Colors.black,
        body: const Center(
          child: JapanFlag(),
        ),
      ),
    ),
  );
}

class JapanFlag extends StatefulWidget {
  const JapanFlag({
    Key? key,
  }) : super(key: key);

  @override
  State<JapanFlag> createState() => _JapanFlagState();
}

class _JapanFlagState extends State<JapanFlag> {
  bool _isOldFlag = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(300, 200),
          painter: MyCustomPainter(isOldFlag: _isOldFlag),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isOldFlag = true;
                  });
                },
                child: const Text('before 1999')),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isOldFlag = false;
                  });
                },
                child: const Text('after 1999')),
          ],
        ),
      ],
    );
  }
}

class MyCustomPainter extends CustomPainter {
  MyCustomPainter({required this.isOldFlag})
      : circlePaint = Paint()
    ..color = isOldFlag ? const Color(0xFFB0313F) : const Color(0xFFBC002D);

  final bool isOldFlag;
  final Paint circlePaint;
  final bgPaint = Paint()..color = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    // trước khi transform cần save trạng thái hiện tại của canvas
    canvas.save();

    // thử đổi thành pi/3 (60 độ) và xem kết quả
    canvas.rotate(pi/2);
    final width = size.width;
    final height = size.height;
    final radius = (height * 3 / 5) / 2;
    final centerPoint = Offset(width / 2, height / 2);

    canvas.drawRect(Rect.fromLTRB(0, 0, width, height), bgPaint);

    // thử vẽ hình chữ nhật trước rồi xoay rồi xem kết quả
    // canvas.rotate(pi/2);
    canvas.drawCircle(centerPoint, radius, circlePaint);

    // khôi phục lại trạng thái trước khi rotate canvas
    canvas.restore();

    // vẽ thử lại lá cờ sau khi restore canvas
    canvas.drawRect(Rect.fromLTRB(0, 0, width, height), bgPaint);
    canvas.drawCircle(centerPoint, radius, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
