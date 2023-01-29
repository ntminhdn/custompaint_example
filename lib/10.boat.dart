import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('10. Chiếc thuyền ngoài xa'),
        ),
        body: const Center(
          child: BoatWidget(),
        ),
      ),
    ),
  );
}

class BoatWidget extends StatelessWidget {
  const BoatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => CustomPaint(
        painter: BoatPainter(),
        size: constraints.biggest,
      ),
    );
  }
}

class BoatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(12);
    final path = Path()
      ..moveTo(14.9779999, 14.8947754)
      ..lineTo(15.9663088, 13.0660401)
      ..cubicTo(11.5941439, 13.06604, 5.46444796, 13.5757852, 3.07751483, 12.0299073)
      ..cubicTo(0.0275658979, 11.5240048, 0.0419999999, 11.0000001, 0.0419999999, 11.0000001)
      ..cubicTo(0.0419999999, 11.0000001, 0.722656254, 14.8947754, 3.07751474, 14.8947754)
      ..cubicTo(6.27148456, 14.8947754, 14.9779999, 14.8947754, 14.9779999, 14.8947754)
      ..close()
      ..moveTo(11.0167695, 10.9907832)
      ..lineTo(11.014, 2)
      ..lineTo(15.9125977, 10.9907827)
      ..lineTo(11.0167695, 10.9907832)
      ..close()
      ..moveTo(10.0148926, 11.0224609)
      ..lineTo(10.0148926, -0.0520019531)
      ..lineTo(5, 10.253)
      ..lineTo(10.0148926, 11.0224609)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.orange);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
