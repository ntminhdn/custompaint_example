import 'dart:ui';

import 'package:custompaint_example/utils.dart';
import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SafeArea(
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: PieChart(),
          ),
        ),
      ),
    );
  }
}

class PieChart extends StatelessWidget {
  const PieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PieChartPainter([
        Pie(IconType.bus, 1.8),
        Pie(IconType.taxi, 0.2),
        Pie(IconType.automobile, 0.05),
        Pie(IconType.walking, 45.90),
        Pie(IconType.train, 28),
        Pie(IconType.bicycle, 4.0),
        Pie(IconType.motocycle, 11.0),
        Pie(IconType.plane, 9.0),
        Pie(IconType.ev, 0.05),
      ]),
      size: Size.infinite,
    );
  }
}

class PieChartPainter extends CustomPainter {
  static final colors = [
    Colors.blue,
    Colors.red,
    Colors.yellow,
    Colors.greenAccent,
    Colors.green,
    Colors.deepPurple,
    Colors.purple,
    Colors.pink,
    Colors.orange,
  ];

  static const minPercentToDrawIconInside = 12; // pie nào >= 12% thì mới vẽ icon ở trong

  static const textStyle = TextStyle(fontSize: 13, color: Colors.black);

  final List<Pie> pies;

  PieChartPainter(List<Pie> p) : pies = p.sorted((a, b) => (b.percent - a.percent).toInt());

  final Paint piePaint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.fill;

  final Paint linePaint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.fill;

  final Paint pointPaint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 2;

  @override
  void paint(Canvas canvas, Size size) {
    // width bao gồm các arrow
    final double width = size.width;

    // height bao gồm arrow
    final double height = size.height;

    // bán kính chart
    final double r = width / 3.5;

    // do chart bắt đầu từ vị trí -pi/2
    var startAngle = -pi / 2;

    // trước khi translate canvas phải save
    canvas.save();

    // translate gốc toạ độ đến chính giữa hình
    // cứ vẽ gì mà liên quan đến hình tròn thì nên translate đến tâm hình tròn cho dễ tính toạ độ
    canvas.translate(width / 2, height / 2);

    for (var i = 0; i < pies.length; i++) {
      final percent = pies[i].percent;

      final sweepAngle = (2 * pi * percent) / 100;

      // nếu % >=12% thì vẽ icon bên trong pie
      if (percent > minPercentToDrawIconInside) {
        // vẽ pie
        _drawPie(canvas, colors.elementAtOrNull(i), r, startAngle, sweepAngle);
      } else {
        // vẽ pie
        _drawPie(canvas, colors.elementAtOrNull(i), r, startAngle, sweepAngle);
      }

      startAngle += sweepAngle;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  void _drawPie(
    Canvas canvas,
    Color? color,
    double r,
    double startAngle,
    double sweepAngle,
  ) {
    piePaint.color = color ?? generateRandomColor();
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: r),
      startAngle,
      sweepAngle,
      true,
      piePaint,
    );
  }
}

class Pie {
  final IconType iconType;
  final double percent;

  Pie(this.iconType, this.percent);
}

enum IconType { train, plane, ev, bicycle, walking, taxi, motocycle, bus, automobile }
