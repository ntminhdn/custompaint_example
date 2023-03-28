import 'package:custompaint_example/utils.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('16. Heart beat'),
        ),
        backgroundColor: Colors.black,
        body: const Center(
          child: HeartBeat(),
        ),
      ),
    ),
  );
}

class HeartBeat extends StatefulWidget {
  const HeartBeat({
    Key? key,
  }) : super(key: key);

  @override
  State<HeartBeat> createState() => _HeartBeatState();
}

class _HeartBeatState extends State<HeartBeat> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _heartSize;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 357,
      ),
    )..addListener(() {
        setState(() {});
      });

    _heartSize = Tween(begin: 0.0, end: 0.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    // Since a heartbeat, so repeats infinitely.
    _controller.repeat().orCancel;
  }

  @override
  void didUpdateWidget(HeartBeat oldWidget) {
    _controller.reset();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(300, 300),
      painter: MyCustomPainter(_heartSize.value),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  MyCustomPainter(this.value);

  final double value; // 0 - 0.2
  final redPaint = Paint()..color = const Color(0xFFFFCCB4);

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    // vẽ khung để dễ hình dung
    // canvas.drawRect(Rect.fromLTRB(0, 0, width, height), Paint()..color=Colors.white..style=PaintingStyle.stroke);

    // transform flip vertically
    canvas.save();
    canvas.flipVertically(size);

    // vẽ 1 nửa trái tim bên trái
    Path halfHeartPath = Path()
      ..moveTo(0.5 * width, height * (0.25 + value))
      ..cubicTo(
          0.2 * width, height * 0.1, -(0.15 + value) * width, height * 0.6, 0.5 * width, height);

    canvas.drawPath(halfHeartPath, redPaint);

    // tiếp tục transform flip horizontally
    canvas.flipHorizontally(size);

    // vẽ 1 nửa trái tim bên phải còn lại
    canvas.drawPath(halfHeartPath, redPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
