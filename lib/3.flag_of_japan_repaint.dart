import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('3. Repaint'),
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: JapanFlag(),
        ),
      ),
    ),
  );
}

class JapanFlag extends StatelessWidget {
  JapanFlag({
    Key? key,
  }) : super(key: key);

  final controller = MyPainterController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(300, 200),
          painter: MyCustomPainter(controller: controller),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () {
                  controller.changeToOldFlag();
                },
                child: const Text('before 1999')),
            ElevatedButton(
                onPressed: () {
                  controller.changeToNewFlag();
                },
                child: const Text('after 1999')),
          ],
        ),
      ],
    );
  }
}

class MyPainterController extends ChangeNotifier {
  bool isOldFlag = false;

  void changeToOldFlag() {
    isOldFlag = true;
    notifyListeners();
  }

  void changeToNewFlag() {
    isOldFlag = false;
    notifyListeners();
  }
}

class MyCustomPainter extends CustomPainter {
  MyCustomPainter({required this.controller})
      : circlePaint = Paint()
          ..color = controller.isOldFlag ? const Color(0xFFB0313F) : const Color(0xFFBC002D),
        super(repaint: controller);

  final Paint circlePaint;
  final MyPainterController controller;
  final bgPaint = Paint()..color = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    print('repaint!!!!! ${controller.isOldFlag}');
    circlePaint.color = controller.isOldFlag ? const Color(0xFFB0313F) : const Color(0xFFBC002D);
    final width = size.width;
    final height = size.height;
    final radius = (height * 3 / 5) / 2;
    final centerPoint = Offset(width / 2, height / 2);

    canvas.drawRect(Rect.fromLTRB(0, 0, width, height), bgPaint);
    canvas.drawCircle(centerPoint, radius, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
