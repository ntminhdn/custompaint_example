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
  static const maximumIconSize = 40; // = icon size là 30 + 10 (khoảng cách an toàn giữa các icon)
  static const iconSize = Size(30, 30);

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

  // vẽ mũi tên về phía bên trái hay bên phải
  bool _drawOnRight = true;

  @override
  void paint(Canvas canvas, Size size) {
    // width bao gồm các arrow
    final double width = size.width;

    // height bao gồm arrow
    final double height = size.height;

    // bán kính chart
    final double r = width / 3.5;

    // tỷ lệ arrow / bán kính lý tưởng
    const double idealBisectorAndRadiusFactor = 1.2;

    // do chart bắt đầu từ vị trí -pi/2
    var startAngle = -pi / 2;

    // tỷ lệ arrow / bán kính trong thực tế sẽ >= 1.2, vì có arrow dài, có arrow ngắn
    var realBisectorAndRadiusFactor = idealBisectorAndRadiusFactor;

    // biến lưu lại tung độ của điểm giao nhau của đoạn thẳng phân giác và đường tròn của previous pie
    // ta dùng nó để tính toán factor hợp lý sao cho các icon ko bị đè lên nhau
    var previousIntersectionPointY = 0.0;

    // trước khi translate canvas phải save
    canvas.save();

    // translate gốc toạ độ đến chính giữa hình
    // cứ vẽ gì mà liên quan đến hình tròn thì nên translate đến tâm hình tròn cho dễ tính toạ độ
    canvas.translate(width / 2, height / 2);

    for (var i = 0; i < pies.length; i++) {
      final percent = pies[i].percent;

      final sweepAngle = (2 * pi * percent) / 100;
      final halfSweepAngle = sweepAngle / 2;

      // toạ độ điểm giao nhau giữa tia phân giác và đường tròn
      final intersectionPointX = r * cos(startAngle + halfSweepAngle);
      final intersectionPointY = r * sin(startAngle + halfSweepAngle);

      // nếu % >=12% thì vẽ icon bên trong pie
      if (percent > minPercentToDrawIconInside) {
        // lấy vector phân giác nhân factor để kéo dài tia phân giác ra 1 xí
        final bisectorEndPoint = Offset(intersectionPointX, intersectionPointY) * realBisectorAndRadiusFactor;

        // vẽ tia phân giác trước vẽ pie để nó nằm dưới cái pie
        _drawLine(canvas, Offset.zero, bisectorEndPoint);

        // vẽ pie
        _drawPie(canvas, colors.elementAtOrNull(i), r, startAngle, sweepAngle);

        // vẽ line ngang
        // y = y điểm cuối tia phân giác
        // x = nếu vẽ ở bên phải thì = width/2, vẽ bên trái thì = -width/2
        // ae có thể trừ bớt chiều dài của x để cái line nó ngắn lại tí cho đẹp, ví dụ mình đang để bên trái thì co lại 40 pixel
        final arrowEndPoint = Offset(
            bisectorEndPoint.dx >= 0 ? (width / 2) : -((width / 2) - maximumIconSize),
            bisectorEndPoint.dy);

        _drawLine(canvas, bisectorEndPoint, arrowEndPoint);

        // vẽ điểm kết thúc arrow
        _drawPoint(canvas, arrowEndPoint);
      } else {
        // ngược lại, nếu % < 12% thì vẽ icon bên ngoài pie vì pie bé quá

        // lấy vector phân giác nhân factor để kéo dài tia phân giác ra 1 xí
        final bisectorEndPoint = Offset(intersectionPointX, intersectionPointY) * realBisectorAndRadiusFactor;

        // trường hợp tung độ chưa cao hơn bán kính thì icon ko thể đè lên nhau
        if (bisectorEndPoint.dy.abs() < r) {
          // lưu lại tung độ điểm giao của đoạn phân giác và đường tròn của previous pie
          previousIntersectionPointY = intersectionPointY.abs();

          // vẽ tia phân giác
          _drawLine(canvas, Offset.zero, bisectorEndPoint);

          // vẽ line ngang
          // Tương tự cách tính ở trên, y = y điểm cuối tia phân giác
          // nhưng khác là x phải lấy width / 2 - 40,
          // khác với ở trên, ta ko cần - 40 vì ở trên ko cần vẽ icon, nhưng ở đây phải trừ 40 để chừa chỗ vẽ icon
          final arrowEndPoint = Offset(
              bisectorEndPoint.dx >= 0
                  ? (width / 2) - maximumIconSize
                  : -((width / 2) - maximumIconSize),
              bisectorEndPoint.dy);

          _drawLine(
            canvas,
            bisectorEndPoint,
            arrowEndPoint,
          );

          // vẽ điểm kết thúc arrow
          _drawPoint(canvas, arrowEndPoint);
        } else {
          // trường hợp tung độ > bán kính thì icon có khả năng đè lên nhau
          // vì vậy hệ số factor nên > 1.2 để kéo dài tia phân giác ra dài hơn nữa

          // tính toán độ dài arrow để icon ko đè lên nhau
          // nếu tung độ điểm giao của đoạn phân giác và đường tròn nằm ở nửa trên thì mới sợ đè nhau, nửa dưới thì ko sợ
          if (previousIntersectionPointY > 0) {
            // nếu khoảng cách giữa 2 điểm giao < 40 thì chắc chắn icon này sẽ đè lên previous icon
            // 40 = icon size + 10, icon size là 30, nhưng + thêm 10 pixel để tạo khoảng trống giữa các icon
            if (intersectionPointY.abs() - previousIntersectionPointY < maximumIconSize) {
              // vậy ta cần tăng factor lên thêm nữa để kéo dài đoạn phân giác sao cho icon ko đè lên nhau
              // sở dĩ chỉ cần maximumIconSize / 2 thay vì maximumIconSize là vì ta sẽ bố trí icon xen kẽ nhau, 1 cái bên trái thì cái tiếp theo sẽ bên phải và cứ thế
              // tuy nhiên, để an toàn thì factor nên tăng tối thiểu là 0.2
              realBisectorAndRadiusFactor +=
                  max(((previousIntersectionPointY + (maximumIconSize / 2)) / intersectionPointY.abs()) - 1, 0.2);
              print(realBisectorAndRadiusFactor);
            }
          }

          // lưu lại tung độ điểm giao của đoạn phân giác và đường tròn của previous pie
          previousIntersectionPointY = intersectionPointY.abs();

          // vẽ tia phân giác
          _drawLine(canvas, Offset.zero, bisectorEndPoint);

          // vẽ line ngang
          // Tương tự cách tính ở trên, y = y điểm cuối tia phân giác, x = width / 2 - 40
          // nhưng khác 1 chỗ là ta ko xét bisectorEndPoint.dx >= 0 hay ko nữa
          // vì chỗ này là những pie cuối nên luôn nằm bên trái, do đó chắc chắn bisectorEndPoint.dx < 0 rồi
          // lúc này ta cần xét biến _drawOnRight đang cần vẽ bên trái hay vẽ bên phải
          final arrowEndPoint = Offset(
              _drawOnRight ? (width / 2) - maximumIconSize : -((width / 2) - maximumIconSize),
              bisectorEndPoint.dy);

          _drawLine(
            canvas,
            bisectorEndPoint,
            arrowEndPoint,
          );

          // vẽ điểm kết thúc arrow
          _drawPoint(canvas, arrowEndPoint);

          // lúc nảy vẽ mũi tên bên trái thì đổi sang vẽ bên phải và ngược lại
          _drawOnRight = !_drawOnRight;
        }
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

  void _drawLine(Canvas canvas, Offset start, Offset end) {
    canvas.drawLine(start, end, linePaint);
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

  void _drawPoint(Canvas canvas, Offset point) {
    canvas.drawPoints(
      PointMode.points,
      [point],
      pointPaint,
    );
  }
}

class Pie {
  final IconType iconType;
  final double percent;

  Pie(this.iconType, this.percent);
}

enum IconType { train, plane, ev, bicycle, walking, taxi, motocycle, bus, automobile }
