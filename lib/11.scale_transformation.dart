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
    final width = size.width;
    final height = size.height;
    final radius = (height * 3 / 5) / 2;
    final centerPoint = Offset(width / 2, height / 2);

    // vẽ lá cờ trc khi scale
    canvas.drawRect(Rect.fromLTRB(0, 0, width, height), bgPaint);
    canvas.drawCircle(centerPoint, radius, circlePaint);

    // scale
    canvas.scale(0.5);

    // vẽ thử lại lá cờ sau khi scale canvas
    canvas.drawRect(Rect.fromLTRB(0, 0, width, height), bgPaint);
    canvas.drawCircle(centerPoint, radius, circlePaint);

    // sau khi scale 0.5, nếu ta muốn vẽ lại lá cờ giống y kích thước ban đầu
    // thì toạ độ tâm, width, height, radius đều phải x2 như này
    // canvas.drawRect(Rect.fromLTRB(0, 0, 2 * width, 2 * height), bgPaint);
    // canvas.drawCircle(centerPoint * 2, radius * 2, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
