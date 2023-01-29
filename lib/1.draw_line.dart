import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('1. Vẽ đường thẳng'),
        ),
        backgroundColor: Colors.black,
        body: const Center(
          child: MyLine(),
        ),
      ),
    ),
  );
}

class MyLine extends StatefulWidget {
  const MyLine({
    Key? key,
  }) : super(key: key);

  @override
  State<MyLine> createState() => _MyLineState();
}

class _MyLineState extends State<MyLine> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() {}),
      child: CustomPaint(
        size: const Size(300, 300),
        painter: MyCustomPainter(),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final whitePaint = Paint()
    ..color = Colors.white
    ..strokeWidth = 10;

  final redPaint = Paint()
    ..color = Colors.red
    ..strokeWidth = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    canvas.drawLine(Offset.zero, Offset(width, height), whitePaint);
    // Không nên tái sử dụng object Paint như vậy. Nên tạo 2 object Paint khác nhau cho 2 line có 2 màu khác nhau
    whitePaint.color = Colors.red;
    canvas.drawLine(Offset(width, 0), Offset(0, height), whitePaint); // đổi thành redPaint sẽ fix được bug
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
