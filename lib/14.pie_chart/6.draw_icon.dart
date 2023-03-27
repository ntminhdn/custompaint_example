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
      final iconType = pies[i].iconType;

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

        // vẽ icon nằm bên trong ở giữa pie, mình chọn vẽ ở vị trí trung điểm đoạn phân giác
        // Nếu isInside bằng true thì mình sẽ tô lại màu trắng cho icon thay vì để màu giống ảnh svg
        _drawIcon(
          canvas,
          iconType,
          x: (intersectionPointX - iconSize.width) / 2,
          y: (intersectionPointY - iconSize.height) / 2,
          isInside: true,
        );

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

        // vẽ text ở chính giữa line ngang
        final horizontalLineMidPoint = (bisectorEndPoint + arrowEndPoint) / 2;
        canvas.drawText(
          text: '$percent%',
          textStyle: textStyle,
          x: horizontalLineMidPoint.dx,
          y: horizontalLineMidPoint.dy,
          alignment: TextAlignment.bottomCenter,
        );
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

          // vẽ icon nằm ngoài pie nhưng ko phải trên cùng
          // Nếu isInside bằng false thì mình sẽ giữ nguyên màu icon giống ảnh svg
          // để align icon và line thẳng hàng với nhau, ta phải trừ bớt y 1 lượng bằng iconSize.height / 2
          _drawIcon(
            canvas,
            iconType,
            x: bisectorEndPoint.dx >= 0 ? (width / 2) - iconSize.width : -width / 2,
            y: bisectorEndPoint.dy - (iconSize.height / 2),
            isInside: false,
          );

          // vẽ text ở chính giữa line ngang
          final horizontalLineMidPoint = (bisectorEndPoint + arrowEndPoint) / 2;
          canvas.drawText(
            text: '$percent%',
            textStyle: textStyle,
            x: horizontalLineMidPoint.dx,
            y: horizontalLineMidPoint.dy,
            alignment: TextAlignment.bottomCenter,
          );
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

          // vẽ icon nằm ngoài pie nhưng ko phải trên cùng
          // để align icon và line thẳng hàng với nhau, ta phải trừ bớt y 1 lượng bằng iconSize.height / 2
          _drawIcon(
            canvas,
            iconType,
            x: _drawOnRight ? (width / 2) - iconSize.width : -width / 2,
            y: bisectorEndPoint.dy - (iconSize.height / 2),
            isInside: false,
          );

          // vẽ text ở chính giữa line ngang
          final horizontalLineMidPoint = (bisectorEndPoint + arrowEndPoint) / 2;
          canvas.drawText(
            text: '$percent%',
            textStyle: textStyle,
            x: horizontalLineMidPoint.dx,
            y: horizontalLineMidPoint.dy,
            alignment: TextAlignment.bottomCenter,
          );

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

  void _drawIcon(
    Canvas canvas,
    IconType iconType, {
    required double x,
    required double y,
    required bool isInside,
  }) {
    canvas.save();
    canvas.translate(x, y);
    _drawIconByType(canvas, iconType, isInside);
    canvas.restore();
  }

  void _drawIconByType(Canvas canvas, IconType iconType, bool isInside) {
    switch (iconType) {
      case IconType.train:
        _drawTrain(canvas, isInside);
        break;
      case IconType.plane:
        _drawPlane(canvas, isInside);
        break;
      case IconType.ev:
        _drawEv(canvas, isInside);
        break;
      case IconType.bicycle:
        _drawBicycle(canvas, isInside);
        break;
      case IconType.walking:
        _drawWalking(canvas, isInside);
        break;
      case IconType.taxi:
        _drawTaxi(canvas, isInside);
        break;
      case IconType.motocycle:
        _drawMotocycle(canvas, isInside);
        break;
      case IconType.bus:
        _drawBus(canvas, isInside);
        break;
      case IconType.automobile:
        _drawAutomobile(canvas, isInside);
        break;
    }
  }

  void _drawWalking(Canvas canvas, bool isInside) {
    Path path_0 = Path();
    path_0.moveTo(iconSize.width * 0.5937500, iconSize.height * 0.4758750);
    path_0.lineTo(iconSize.width * 0.6595750, iconSize.height * 0.5583750);
    path_0.arcToPoint(Offset(iconSize.width * 0.7348750, iconSize.height * 0.5474250),
        radius: Radius.elliptical(iconSize.width * 0.04367500, iconSize.height * 0.04367500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.cubicTo(
        iconSize.width * 0.7406250,
        iconSize.height * 0.5327250,
        iconSize.width * 0.7378750,
        iconSize.height * 0.5161250,
        iconSize.width * 0.7279250,
        iconSize.height * 0.5039250);
    path_0.lineTo(iconSize.width * 0.6472750, iconSize.height * 0.4005000);
    path_0.lineTo(iconSize.width * 0.5937500, iconSize.height * 0.3002000);
    path_0.close();
    path_0.moveTo(iconSize.width * 0.3986250, iconSize.height * 0.6000000);
    path_0.arcToPoint(Offset(iconSize.width * 0.3929750, iconSize.height * 0.5911250),
        radius: Radius.elliptical(iconSize.width * 0.1236250, iconSize.height * 0.1236250),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.lineTo(iconSize.width * 0.3635750, iconSize.height * 0.7769500);
    path_0.lineTo(iconSize.width * 0.2381750, iconSize.height * 0.9162000);
    path_0.arcToPoint(Offset(iconSize.width * 0.2412000, iconSize.height * 0.9869250),
        radius: Radius.elliptical(iconSize.width * 0.04995000, iconSize.height * 0.04995000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.arcToPoint(Offset(iconSize.width * 0.3119250, iconSize.height * 0.9838750),
        radius: Radius.elliptical(iconSize.width * 0.05002500, iconSize.height * 0.05002500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.4494250, iconSize.height * 0.8338750);
    path_0.cubicTo(
        iconSize.width * 0.4556750,
        iconSize.height * 0.8270500,
        iconSize.width * 0.4598750,
        iconSize.height * 0.8185500,
        iconSize.width * 0.4616250,
        iconSize.height * 0.8094750);
    path_0.lineTo(iconSize.width * 0.4770500, iconSize.height * 0.7286250);
    path_0.close();
    path_0.moveTo(iconSize.width * 0.3986250, iconSize.height * 0.6000000);

    Paint paint0Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint0Fill.color = const Color(0xff518fcc).withOpacity(1);
    canvas.drawPath(path_0, paint0Fill);

    Path path_1 = Path();
    path_1.moveTo(iconSize.width * 0.2262500, iconSize.height * 0.5066500);
    path_1.arcToPoint(Offset(iconSize.width * 0.2987000, iconSize.height * 0.5558750),
        radius: Radius.elliptical(iconSize.width * 0.04380000, iconSize.height * 0.04380000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_1.lineTo(iconSize.width * 0.4312500, iconSize.height * 0.3664000);
    path_1.arcToPoint(Offset(iconSize.width * 0.4517500, iconSize.height * 0.3807500),
        radius: Radius.elliptical(iconSize.width * 0.01250000, iconSize.height * 0.01250000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_1.lineTo(iconSize.width * 0.3984250, iconSize.height * 0.4570250);
    path_1.lineTo(iconSize.width * 0.4001000, iconSize.height * 0.5254000);
    path_1.cubicTo(
        iconSize.width * 0.4003000,
        iconSize.height * 0.5472750,
        iconSize.width * 0.4071250,
        iconSize.height * 0.5686500,
        iconSize.width * 0.4197250,
        iconSize.height * 0.5866250);
    path_1.lineTo(iconSize.width * 0.6557500, iconSize.height * 0.9733500);
    path_1.arcToPoint(Offset(iconSize.width * 0.7429750, iconSize.height * 0.9770500),
        radius: Radius.elliptical(iconSize.width * 0.05007500, iconSize.height * 0.05007500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_1.cubicTo(
        iconSize.width * 0.7524500,
        iconSize.height * 0.9616250,
        iconSize.width * 0.7529250,
        iconSize.height * 0.9423000,
        iconSize.width * 0.7441500,
        iconSize.height * 0.9264750);
    path_1.lineTo(iconSize.width * 0.5574000, iconSize.height * 0.5721750);
    path_1.cubicTo(
        iconSize.width * 0.5646500,
        iconSize.height * 0.5543000,
        iconSize.width * 0.5685500,
        iconSize.height * 0.5353500,
        iconSize.width * 0.5687500,
        iconSize.height * 0.5161250);
    path_1.lineTo(iconSize.width * 0.5687500, iconSize.height * 0.2750000);
    path_1.arcToPoint(Offset(iconSize.width * 0.4065500, iconSize.height * 0.2296000),
        radius: Radius.elliptical(iconSize.width * 0.08750000, iconSize.height * 0.08750000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_1.close();
    path_1.moveTo(iconSize.width * 0.2262500, iconSize.height * 0.5066500);

    Paint paint1Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint1Fill.color = const Color(0xff518fcc).withOpacity(1);
    canvas.drawPath(path_1, paint1Fill);

    Path path_2 = Path();
    path_2.moveTo(iconSize.width * 0.5875000, iconSize.height * 0.08750000);
    path_2.arcToPoint(Offset(iconSize.width * 0.4125000, iconSize.height * 0.08750000),
        radius: Radius.elliptical(iconSize.width * 0.08750000, iconSize.height * 0.08750000),
        rotation: 0,
        largeArc: true,
        clockwise: true);
    path_2.arcToPoint(Offset(iconSize.width * 0.5875000, iconSize.height * 0.08750000),
        radius: Radius.elliptical(iconSize.width * 0.08750000, iconSize.height * 0.08750000),
        rotation: 0,
        largeArc: true,
        clockwise: true);

    Paint paint2Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint2Fill.color = const Color(0xff518fcc).withOpacity(1);
    canvas.drawPath(path_2, paint2Fill);
  }

  void _drawTrain(Canvas canvas, bool isInside) {
    Path path_0 = Path();
    path_0.moveTo(iconSize.width * 0.7250000, iconSize.height * 0.8500000);
    path_0.lineTo(iconSize.width * 0.6642500, iconSize.height * 0.8500000);
    path_0.lineTo(iconSize.width * 0.6859250, iconSize.height * 0.8875000);
    path_0.lineTo(iconSize.width * 0.3140750, iconSize.height * 0.8875000);
    path_0.lineTo(iconSize.width * 0.3357750, iconSize.height * 0.8500000);
    path_0.lineTo(iconSize.width * 0.2750000, iconSize.height * 0.8500000);
    path_0.arcToPoint(Offset(iconSize.width * 0.2504000, iconSize.height * 0.8477500),
        radius: Radius.elliptical(iconSize.width * 0.1478500, iconSize.height * 0.1478500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.lineTo(iconSize.width * 0.1625000, iconSize.height);
    path_0.lineTo(iconSize.width * 0.2491250, iconSize.height);
    path_0.lineTo(iconSize.width * 0.2851500, iconSize.height * 0.9375000);
    path_0.lineTo(iconSize.width * 0.7148500, iconSize.height * 0.9375000);
    path_0.lineTo(iconSize.width * 0.7508750, iconSize.height);
    path_0.lineTo(iconSize.width * 0.8375000, iconSize.height);
    path_0.lineTo(iconSize.width * 0.7496000, iconSize.height * 0.8477500);
    path_0.arcToPoint(Offset(iconSize.width * 0.7250000, iconSize.height * 0.8500000),
        radius: Radius.elliptical(iconSize.width * 0.1478500, iconSize.height * 0.1478500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.moveTo(iconSize.width * 0.7250000, 0);
    path_0.lineTo(iconSize.width * 0.2750000, 0);
    path_0.arcToPoint(Offset(iconSize.width * 0.1500000, iconSize.height * 0.1250000),
        radius: Radius.elliptical(iconSize.width * 0.1250000, iconSize.height * 0.1250000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.1500000, iconSize.height * 0.7000000);
    path_0.arcToPoint(Offset(iconSize.width * 0.2750000, iconSize.height * 0.8250000),
        radius: Radius.elliptical(iconSize.width * 0.1250000, iconSize.height * 0.1250000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.7250000, iconSize.height * 0.8250000);
    path_0.arcToPoint(Offset(iconSize.width * 0.8500000, iconSize.height * 0.7000000),
        radius: Radius.elliptical(iconSize.width * 0.1250000, iconSize.height * 0.1250000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.8500000, iconSize.height * 0.1250000);
    path_0.arcToPoint(Offset(iconSize.width * 0.7250000, 0),
        radius: Radius.elliptical(iconSize.width * 0.1250000, iconSize.height * 0.1250000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.moveTo(iconSize.width * 0.3500000, iconSize.height * 0.07500000);
    path_0.lineTo(iconSize.width * 0.6500000, iconSize.height * 0.07500000);
    path_0.lineTo(iconSize.width * 0.6500000, iconSize.height * 0.1250000);
    path_0.lineTo(iconSize.width * 0.3500000, iconSize.height * 0.1250000);
    path_0.close();
    path_0.moveTo(iconSize.width * 0.3000000, iconSize.height * 0.7250000);
    path_0.arcToPoint(Offset(iconSize.width * 0.3000000, iconSize.height * 0.6250000),
        radius: Radius.elliptical(iconSize.width * 0.04997500, iconSize.height * 0.04997500),
        rotation: 0,
        largeArc: true,
        clockwise: true);
    path_0.arcToPoint(Offset(iconSize.width * 0.3000000, iconSize.height * 0.7250000),
        radius: Radius.elliptical(iconSize.width * 0.04997500, iconSize.height * 0.04997500),
        rotation: 0,
        largeArc: true,
        clockwise: true);
    path_0.moveTo(iconSize.width * 0.7000000, iconSize.height * 0.7250000);
    path_0.arcToPoint(Offset(iconSize.width * 0.7000000, iconSize.height * 0.6250000),
        radius: Radius.elliptical(iconSize.width * 0.04997500, iconSize.height * 0.04997500),
        rotation: 0,
        largeArc: true,
        clockwise: true);
    path_0.arcToPoint(Offset(iconSize.width * 0.7000000, iconSize.height * 0.7250000),
        radius: Radius.elliptical(iconSize.width * 0.04997500, iconSize.height * 0.04997500),
        rotation: 0,
        largeArc: true,
        clockwise: true);
    path_0.moveTo(iconSize.width * 0.7500000, iconSize.height * 0.4375000);
    path_0.cubicTo(
        iconSize.width * 0.7500000,
        iconSize.height * 0.4512500,
        iconSize.width * 0.7387500,
        iconSize.height * 0.4625000,
        iconSize.width * 0.7250000,
        iconSize.height * 0.4625000);
    path_0.lineTo(iconSize.width * 0.2750000, iconSize.height * 0.4625000);
    path_0.cubicTo(
        iconSize.width * 0.2612500,
        iconSize.height * 0.4625000,
        iconSize.width * 0.2500000,
        iconSize.height * 0.4512500,
        iconSize.width * 0.2500000,
        iconSize.height * 0.4375000);
    path_0.lineTo(iconSize.width * 0.2500000, iconSize.height * 0.2250000);
    path_0.cubicTo(
        iconSize.width * 0.2500000,
        iconSize.height * 0.2112500,
        iconSize.width * 0.2612500,
        iconSize.height * 0.2000000,
        iconSize.width * 0.2750000,
        iconSize.height * 0.2000000);
    path_0.lineTo(iconSize.width * 0.7250000, iconSize.height * 0.2000000);
    path_0.cubicTo(
        iconSize.width * 0.7387500,
        iconSize.height * 0.2000000,
        iconSize.width * 0.7500000,
        iconSize.height * 0.2112500,
        iconSize.width * 0.7500000,
        iconSize.height * 0.2250000);
    path_0.close();
    path_0.moveTo(iconSize.width * 0.7500000, iconSize.height * 0.4375000);

    Paint paint0Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint0Fill.color = const Color(0xffe06666).withOpacity(1);
    canvas.drawPath(path_0, paint0Fill);
  }

  void _drawBus(Canvas canvas, bool isInside) {
    Path path_0 = Path();
    path_0.moveTo(iconSize.width * 0.7578250, iconSize.height * 0.8984500);
    path_0.lineTo(iconSize.width * 0.6757500, iconSize.height * 0.8984500);
    path_0.lineTo(iconSize.width * 0.6757500, iconSize.height * 0.9453000);
    path_0.arcToPoint(Offset(iconSize.width * 0.6992000, iconSize.height * 0.9687500),
        radius: Radius.elliptical(iconSize.width * 0.02342500, iconSize.height * 0.02342500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.7929500, iconSize.height * 0.9687500);
    path_0.arcToPoint(Offset(iconSize.width * 0.8163750, iconSize.height * 0.9453000),
        radius: Radius.elliptical(iconSize.width * 0.02342500, iconSize.height * 0.02342500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.8163750, iconSize.height * 0.8855500);
    path_0.arcToPoint(Offset(iconSize.width * 0.7578000, iconSize.height * 0.8984500),
        radius: Radius.elliptical(iconSize.width * 0.1396000, iconSize.height * 0.1396000),
        rotation: 0,
        largeArc: false,
        clockwise: true);

    Paint paint0Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint0Fill.color = const Color(0xffcccc00).withOpacity(1);
    canvas.drawPath(path_0, paint0Fill);

    Path path_1 = Path();
    path_1.moveTo(iconSize.width * 0.2422000, iconSize.height * 0.8984500);
    path_1.lineTo(iconSize.width * 0.3242000, iconSize.height * 0.8984500);
    path_1.lineTo(iconSize.width * 0.3242000, iconSize.height * 0.9453000);
    path_1.arcToPoint(Offset(iconSize.width * 0.3007750, iconSize.height * 0.9687500),
        radius: Radius.elliptical(iconSize.width * 0.02342500, iconSize.height * 0.02342500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_1.lineTo(iconSize.width * 0.2070250, iconSize.height * 0.9687500);
    path_1.arcToPoint(Offset(iconSize.width * 0.1836000, iconSize.height * 0.9453000),
        radius: Radius.elliptical(iconSize.width * 0.02342500, iconSize.height * 0.02342500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_1.lineTo(iconSize.width * 0.1836000, iconSize.height * 0.8855500);
    path_1.cubicTo(
        iconSize.width * 0.2019500,
        iconSize.height * 0.8940500,
        iconSize.width * 0.2219750,
        iconSize.height * 0.8984500,
        iconSize.width * 0.2421750,
        iconSize.height * 0.8984500);

    Paint paint1Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint1Fill.color = const Color(0xffcccc00).withOpacity(1);
    canvas.drawPath(path_1, paint1Fill);

    Path path_2 = Path();
    path_2.moveTo(iconSize.width * 0.7578250, iconSize.height * 0.03125000);
    path_2.lineTo(iconSize.width * 0.2422000, iconSize.height * 0.03125000);
    path_2.arcToPoint(Offset(iconSize.width * 0.1250000, iconSize.height * 0.1484500),
        radius: Radius.elliptical(iconSize.width * 0.1171500, iconSize.height * 0.1171500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_2.lineTo(iconSize.width * 0.1250000, iconSize.height * 0.7578250);
    path_2.arcToPoint(Offset(iconSize.width * 0.2422000, iconSize.height * 0.8750000),
        radius: Radius.elliptical(iconSize.width * 0.1171500, iconSize.height * 0.1171500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_2.lineTo(iconSize.width * 0.7578000, iconSize.height * 0.8750000);
    path_2.arcToPoint(Offset(iconSize.width * 0.8750000, iconSize.height * 0.7578000),
        radius: Radius.elliptical(iconSize.width * 0.1171500, iconSize.height * 0.1171500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_2.lineTo(iconSize.width * 0.8750000, iconSize.height * 0.1484500);
    path_2.arcToPoint(Offset(iconSize.width * 0.7578000, iconSize.height * 0.03127500),
        radius: Radius.elliptical(iconSize.width * 0.1171500, iconSize.height * 0.1171500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_2.moveTo(iconSize.width * 0.3125000, iconSize.height * 0.1015750);
    path_2.lineTo(iconSize.width * 0.6875000, iconSize.height * 0.1015750);
    path_2.lineTo(iconSize.width * 0.6875000, iconSize.height * 0.1601500);
    path_2.lineTo(iconSize.width * 0.3125000, iconSize.height * 0.1601500);
    path_2.close();
    path_2.moveTo(iconSize.width * 0.2539000, iconSize.height * 0.7578250);
    path_2.arcToPoint(Offset(iconSize.width * 0.2539250, iconSize.height * 0.6640500),
        radius: Radius.elliptical(iconSize.width * 0.04687500, iconSize.height * 0.04687500),
        rotation: 0,
        largeArc: true,
        clockwise: true);
    path_2.arcToPoint(Offset(iconSize.width * 0.2539250, iconSize.height * 0.7578000),
        radius: Radius.elliptical(iconSize.width * 0.04687500, iconSize.height * 0.04687500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_2.moveTo(iconSize.width * 0.5937500, iconSize.height * 0.8281250);
    path_2.lineTo(iconSize.width * 0.4062500, iconSize.height * 0.8281250);
    path_2.lineTo(iconSize.width * 0.4062500, iconSize.height * 0.7812500);
    path_2.lineTo(iconSize.width * 0.5937500, iconSize.height * 0.7812500);
    path_2.close();
    path_2.moveTo(iconSize.width * 0.7461000, iconSize.height * 0.7578000);
    path_2.arcToPoint(Offset(iconSize.width * 0.7461000, iconSize.height * 0.6640500),
        radius: Radius.elliptical(iconSize.width * 0.04687500, iconSize.height * 0.04687500),
        rotation: 0,
        largeArc: true,
        clockwise: true);
    path_2.arcToPoint(Offset(iconSize.width * 0.7461000, iconSize.height * 0.7578000),
        radius: Radius.elliptical(iconSize.width * 0.04687500, iconSize.height * 0.04687500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_2.moveTo(iconSize.width * 0.7929750, iconSize.height * 0.5468750);
    path_2.arcToPoint(Offset(iconSize.width * 0.7695250, iconSize.height * 0.5703250),
        radius: Radius.elliptical(iconSize.width * 0.02342500, iconSize.height * 0.02342500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_2.lineTo(iconSize.width * 0.2305000, iconSize.height * 0.5703250);
    path_2.arcToPoint(Offset(iconSize.width * 0.2070500, iconSize.height * 0.5469750),
        radius: Radius.elliptical(iconSize.width * 0.02342500, iconSize.height * 0.02342500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_2.lineTo(iconSize.width * 0.2070500, iconSize.height * 0.2539000);
    path_2.cubicTo(
        iconSize.width * 0.2070500,
        iconSize.height * 0.2476500,
        iconSize.width * 0.2095000,
        iconSize.height * 0.2417000,
        iconSize.width * 0.2140000,
        iconSize.height * 0.2373000);
    path_2.arcToPoint(Offset(iconSize.width * 0.2305000, iconSize.height * 0.2304750),
        radius: Radius.elliptical(iconSize.width * 0.02337500, iconSize.height * 0.02337500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_2.lineTo(iconSize.width * 0.7695000, iconSize.height * 0.2304750);
    path_2.arcToPoint(Offset(iconSize.width * 0.7929500, iconSize.height * 0.2539000),
        radius: Radius.elliptical(iconSize.width * 0.02342500, iconSize.height * 0.02342500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_2.close();
    path_2.moveTo(iconSize.width * 0.7929750, iconSize.height * 0.5468750);

    Paint paint2Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint2Fill.color = const Color(0xffcccc00).withOpacity(1);
    canvas.drawPath(path_2, paint2Fill);
  }

  void _drawEv(Canvas canvas, bool isInside) {
    Path path_0 = Path();
    path_0.moveTo(iconSize.width * 0.07900000, iconSize.height * 0.2500000);
    path_0.lineTo(iconSize.width * 0.1200000, iconSize.height * 0.1500000);
    path_0.lineTo(iconSize.width * 0.05000000, iconSize.height * 0.1500000);
    path_0.arcToPoint(Offset(iconSize.width * 0.05000000, iconSize.height * 0.2500000),
        radius: Radius.elliptical(iconSize.width * 0.04997500, iconSize.height * 0.04997500),
        rotation: 0,
        largeArc: true,
        clockwise: false);
    path_0.close();
    path_0.moveTo(iconSize.width * 0.9499000, iconSize.height * 0.1500000);
    path_0.lineTo(iconSize.width * 0.8799000, iconSize.height * 0.1500000);
    path_0.lineTo(iconSize.width * 0.9208000, iconSize.height * 0.2500000);
    path_0.lineTo(iconSize.width * 0.9499000, iconSize.height * 0.2500000);
    path_0.cubicTo(
        iconSize.width * 0.9775500,
        iconSize.height * 0.2500000,
        iconSize.width * 0.9999000,
        iconSize.height * 0.2276250,
        iconSize.width * 0.9999000,
        iconSize.height * 0.2000000);
    path_0.cubicTo(
        iconSize.width * 0.9999000,
        iconSize.height * 0.1723750,
        iconSize.width * 0.9775500,
        iconSize.height * 0.1500000,
        iconSize.width * 0.9499000,
        iconSize.height * 0.1500000);
    path_0.moveTo(iconSize.width * 0.08750000, iconSize.height * 0.6241250);
    path_0.lineTo(iconSize.width * 0.08750000, iconSize.height * 0.6812500);
    path_0.arcToPoint(Offset(iconSize.width * 0.2250000, iconSize.height * 0.6812500),
        radius: Radius.elliptical(iconSize.width * 0.06872500, iconSize.height * 0.06872500),
        rotation: 0,
        largeArc: true,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.2250000, iconSize.height * 0.6250000);
    path_0.lineTo(iconSize.width * 0.1000000, iconSize.height * 0.6250000);
    path_0.cubicTo(
        iconSize.width * 0.09580000,
        iconSize.height * 0.6250000,
        iconSize.width * 0.09160000,
        iconSize.height * 0.6247000,
        iconSize.width * 0.08750000,
        iconSize.height * 0.6241250);
    path_0.moveTo(iconSize.width * 0.7750000, iconSize.height * 0.6250000);
    path_0.lineTo(iconSize.width * 0.7750000, iconSize.height * 0.6812500);
    path_0.arcToPoint(Offset(iconSize.width * 0.9125000, iconSize.height * 0.6812500),
        radius: Radius.elliptical(iconSize.width * 0.06872500, iconSize.height * 0.06872500),
        rotation: 0,
        largeArc: true,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.9125000, iconSize.height * 0.6241250);
    path_0.arcToPoint(Offset(iconSize.width * 0.9000000, iconSize.height * 0.6250000),
        radius: Radius.elliptical(iconSize.width * 0.08862500, iconSize.height * 0.08862500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.close();
    path_0.moveTo(iconSize.width * 0.9530250, iconSize.height * 0.3176750);
    path_0.lineTo(iconSize.width * 0.9002000, iconSize.height * 0.2650500);
    path_0.lineTo(iconSize.width * 0.7969500, iconSize.height * 0.05020000);
    path_0.arcToPoint(Offset(iconSize.width * 0.7167250, 0),
        radius: Radius.elliptical(iconSize.width * 0.08772500, iconSize.height * 0.08772500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.2833000, 0);
    path_0.arcToPoint(Offset(iconSize.width * 0.2030500, iconSize.height * 0.05020000),
        radius: Radius.elliptical(iconSize.width * 0.08772500, iconSize.height * 0.08772500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.09970000, iconSize.height * 0.2650500);
    path_0.lineTo(iconSize.width * 0.04695000, iconSize.height * 0.3176750);
    path_0.arcToPoint(Offset(iconSize.width * 0.02500000, iconSize.height * 0.3707000),
        radius: Radius.elliptical(iconSize.width * 0.07412500, iconSize.height * 0.07412500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.02500000, iconSize.height * 0.5250000);
    path_0.arcToPoint(Offset(iconSize.width * 0.1000000, iconSize.height * 0.6000000),
        radius: Radius.elliptical(iconSize.width * 0.07500000, iconSize.height * 0.07500000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.9000000, iconSize.height * 0.6000000);
    path_0.arcToPoint(Offset(iconSize.width * 0.9750000, iconSize.height * 0.5250000),
        radius: Radius.elliptical(iconSize.width * 0.07500000, iconSize.height * 0.07500000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.9750000, iconSize.height * 0.3707000);
    path_0.arcToPoint(Offset(iconSize.width * 0.9530250, iconSize.height * 0.3176750),
        radius: Radius.elliptical(iconSize.width * 0.07412500, iconSize.height * 0.07412500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.moveTo(iconSize.width * 0.1880000, iconSize.height * 0.2520500);
    path_0.lineTo(iconSize.width * 0.2713750, iconSize.height * 0.08115000);
    path_0.arcToPoint(Offset(iconSize.width * 0.2833000, iconSize.height * 0.07500000),
        radius: Radius.elliptical(iconSize.width * 0.01307500, iconSize.height * 0.01307500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.lineTo(iconSize.width * 0.7167000, iconSize.height * 0.07500000);
    path_0.arcToPoint(Offset(iconSize.width * 0.7287000, iconSize.height * 0.08125000),
        radius: Radius.elliptical(iconSize.width * 0.01310000, iconSize.height * 0.01310000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.lineTo(iconSize.width * 0.8120000, iconSize.height * 0.2520500);
    path_0.arcToPoint(Offset(iconSize.width * 0.8115000, iconSize.height * 0.2570500),
        radius: Radius.elliptical(iconSize.width * 0.004625000, iconSize.height * 0.004625000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.arcToPoint(Offset(iconSize.width * 0.8000000, iconSize.height * 0.2625000),
        radius: Radius.elliptical(iconSize.width * 0.01312500, iconSize.height * 0.01312500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.lineTo(iconSize.width * 0.2000000, iconSize.height * 0.2625000);
    path_0.arcToPoint(Offset(iconSize.width * 0.1885000, iconSize.height * 0.2571250),
        radius: Radius.elliptical(iconSize.width * 0.01302500, iconSize.height * 0.01302500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.arcToPoint(Offset(iconSize.width * 0.1880000, iconSize.height * 0.2521250),
        radius: Radius.elliptical(iconSize.width * 0.004450000, iconSize.height * 0.004450000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.moveTo(iconSize.width * 0.1875000, iconSize.height * 0.5000000);
    path_0.arcToPoint(Offset(iconSize.width * 0.1250000, iconSize.height * 0.4375000),
        radius: Radius.elliptical(iconSize.width * 0.06255000, iconSize.height * 0.06255000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.cubicTo(
        iconSize.width * 0.1250000,
        iconSize.height * 0.4030250,
        iconSize.width * 0.1530250,
        iconSize.height * 0.3750000,
        iconSize.width * 0.1875000,
        iconSize.height * 0.3750000);
    path_0.cubicTo(
        iconSize.width * 0.2219750,
        iconSize.height * 0.3750000,
        iconSize.width * 0.2500000,
        iconSize.height * 0.4030250,
        iconSize.width * 0.2500000,
        iconSize.height * 0.4375000);
    path_0.cubicTo(
        iconSize.width * 0.2500000,
        iconSize.height * 0.4719750,
        iconSize.width * 0.2219750,
        iconSize.height * 0.5000000,
        iconSize.width * 0.1875000,
        iconSize.height * 0.5000000);
    path_0.moveTo(iconSize.width * 0.6250000, iconSize.height * 0.5375000);
    path_0.cubicTo(
        iconSize.width * 0.6250000,
        iconSize.height * 0.5444250,
        iconSize.width * 0.6194250,
        iconSize.height * 0.5500000,
        iconSize.width * 0.6125000,
        iconSize.height * 0.5500000);
    path_0.lineTo(iconSize.width * 0.3875000, iconSize.height * 0.5500000);
    path_0.arcToPoint(Offset(iconSize.width * 0.3750000, iconSize.height * 0.5375000),
        radius: Radius.elliptical(iconSize.width * 0.01245000, iconSize.height * 0.01245000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.lineTo(iconSize.width * 0.3750000, iconSize.height * 0.4625000);
    path_0.cubicTo(
        iconSize.width * 0.3750000,
        iconSize.height * 0.4555750,
        iconSize.width * 0.3805750,
        iconSize.height * 0.4500000,
        iconSize.width * 0.3875000,
        iconSize.height * 0.4500000);
    path_0.lineTo(iconSize.width * 0.6125000, iconSize.height * 0.4500000);
    path_0.cubicTo(
        iconSize.width * 0.6194250,
        iconSize.height * 0.4500000,
        iconSize.width * 0.6250000,
        iconSize.height * 0.4555750,
        iconSize.width * 0.6250000,
        iconSize.height * 0.4625000);
    path_0.close();
    path_0.moveTo(iconSize.width * 0.8125000, iconSize.height * 0.5000000);
    path_0.arcToPoint(Offset(iconSize.width * 0.7500000, iconSize.height * 0.4375000),
        radius: Radius.elliptical(iconSize.width * 0.06255000, iconSize.height * 0.06255000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.cubicTo(
        iconSize.width * 0.7500000,
        iconSize.height * 0.4030250,
        iconSize.width * 0.7780250,
        iconSize.height * 0.3750000,
        iconSize.width * 0.8125000,
        iconSize.height * 0.3750000);
    path_0.cubicTo(
        iconSize.width * 0.8469750,
        iconSize.height * 0.3750000,
        iconSize.width * 0.8750000,
        iconSize.height * 0.4030250,
        iconSize.width * 0.8750000,
        iconSize.height * 0.4375000);
    path_0.cubicTo(
        iconSize.width * 0.8750000,
        iconSize.height * 0.4719750,
        iconSize.width * 0.8469750,
        iconSize.height * 0.5000000,
        iconSize.width * 0.8125000,
        iconSize.height * 0.5000000);

    Paint paint0Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint0Fill.color = const Color(0xff1abda4).withOpacity(1);
    canvas.drawPath(path_0, paint0Fill);

    Path path_1 = Path();
    path_1.moveTo(iconSize.width * 0.4683500, iconSize.height * 0.7979500);
    path_1.lineTo(iconSize.width * 0.4683500, iconSize.height * 0.8354500);
    path_1.lineTo(iconSize.width * 0.3502000, iconSize.height * 0.8354500);
    path_1.lineTo(iconSize.width * 0.3502000, iconSize.height * 0.8770500);
    path_1.lineTo(iconSize.width * 0.4633750, iconSize.height * 0.8770500);
    path_1.lineTo(iconSize.width * 0.4633750, iconSize.height * 0.9130750);
    path_1.lineTo(iconSize.width * 0.3502000, iconSize.height * 0.9130750);
    path_1.lineTo(iconSize.width * 0.3502000, iconSize.height * 0.9576250);
    path_1.lineTo(iconSize.width * 0.4709000, iconSize.height * 0.9576250);
    path_1.lineTo(iconSize.width * 0.4709000, iconSize.height * 0.9951250);
    path_1.lineTo(iconSize.width * 0.3091750, iconSize.height * 0.9951250);
    path_1.lineTo(iconSize.width * 0.3091750, iconSize.height * 0.7979500);
    path_1.close();
    path_1.moveTo(iconSize.width * 0.4683500, iconSize.height * 0.7979500);

    Paint paint1Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint1Fill.color = const Color(0xff1abda4).withOpacity(1);
    canvas.drawPath(path_1, paint1Fill);

    Path path_2 = Path();
    path_2.moveTo(iconSize.width * 0.5566500, iconSize.height * 0.7979500);
    path_2.lineTo(iconSize.width * 0.6069250, iconSize.height * 0.9527250);
    path_2.lineTo(iconSize.width * 0.6569250, iconSize.height * 0.7979500);
    path_2.lineTo(iconSize.width * 0.7026250, iconSize.height * 0.7979500);
    path_2.lineTo(iconSize.width * 0.6338750, iconSize.height * 0.9950250);
    path_2.lineTo(iconSize.width * 0.5796000, iconSize.height * 0.9950250);
    path_2.lineTo(iconSize.width * 0.5108500, iconSize.height * 0.7979500);
    path_2.close();
    path_2.moveTo(iconSize.width * 0.5566500, iconSize.height * 0.7979500);

    Paint paint2Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint2Fill.color = const Color(0xff1abda4).withOpacity(1);
    canvas.drawPath(path_2, paint2Fill);
  }

  void _drawTaxi(Canvas canvas, bool isInside) {
    Path path_0 = Path();
    path_0.moveTo(iconSize.width * 0.07850000, iconSize.height * 0.4908250);
    path_0.lineTo(iconSize.width * 0.1191500, iconSize.height * 0.3914000);
    path_0.lineTo(iconSize.width * 0.04970000, iconSize.height * 0.3914000);
    path_0.arcToPoint(Offset(iconSize.width * 0.04970000, iconSize.height * 0.4908250),
        radius: Radius.elliptical(iconSize.width * 0.04972500, iconSize.height * 0.04972500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.close();
    path_0.moveTo(iconSize.width * 0.07850000, iconSize.height * 0.4908250);

    Paint paint0Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint0Fill.color = const Color(0xff70c519).withOpacity(1);
    canvas.drawPath(path_0, paint0Fill);

    Path path_1 = Path();
    path_1.moveTo(iconSize.width * 0.9439500, iconSize.height * 0.3914000);
    path_1.lineTo(iconSize.width * 0.8744250, iconSize.height * 0.3914000);
    path_1.lineTo(iconSize.width * 0.9150500, iconSize.height * 0.4908250);
    path_1.lineTo(iconSize.width * 0.9439500, iconSize.height * 0.4908250);
    path_1.arcToPoint(Offset(iconSize.width * 0.9439500, iconSize.height * 0.3914000),
        radius: Radius.elliptical(iconSize.width * 0.04970000, iconSize.height * 0.04970000),
        rotation: 0,
        largeArc: false,
        clockwise: false);

    Paint paint1Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint1Fill.color = const Color(0xff70c519).withOpacity(1);
    canvas.drawPath(path_1, paint1Fill);

    Path path_2 = Path();
    path_2.moveTo(iconSize.width * 0.08692500, iconSize.height * 0.8749000);
    path_2.lineTo(iconSize.width * 0.08692500, iconSize.height * 0.9316500);
    path_2.arcToPoint(Offset(iconSize.width * 0.2235500, iconSize.height * 0.9316500),
        radius: Radius.elliptical(iconSize.width * 0.06830000, iconSize.height * 0.06830000),
        rotation: 0,
        largeArc: true,
        clockwise: false);
    path_2.lineTo(iconSize.width * 0.2235500, iconSize.height * 0.8757500);
    path_2.lineTo(iconSize.width * 0.09940000, iconSize.height * 0.8757500);
    path_2.cubicTo(
        iconSize.width * 0.09530000,
        iconSize.height * 0.8757500,
        iconSize.width * 0.09110000,
        iconSize.height * 0.8754750,
        iconSize.width * 0.08690000,
        iconSize.height * 0.8748750);
    path_2.moveTo(iconSize.width * 0.7700000, iconSize.height * 0.8757750);
    path_2.lineTo(iconSize.width * 0.7700000, iconSize.height * 0.9316500);
    path_2.arcToPoint(Offset(iconSize.width * 0.9066500, iconSize.height * 0.9316500),
        radius: Radius.elliptical(iconSize.width * 0.06830000, iconSize.height * 0.06830000),
        rotation: 0,
        largeArc: true,
        clockwise: false);
    path_2.lineTo(iconSize.width * 0.9066500, iconSize.height * 0.8749000);
    path_2.arcToPoint(Offset(iconSize.width * 0.8941500, iconSize.height * 0.8757750),
        radius: Radius.elliptical(iconSize.width * 0.08862500, iconSize.height * 0.08862500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_2.close();
    path_2.moveTo(iconSize.width * 0.8944250, iconSize.height * 0.5055750);
    path_2.lineTo(iconSize.width * 0.7920000, iconSize.height * 0.2797500);
    path_2.arcToPoint(Offset(iconSize.width * 0.7121000, iconSize.height * 0.2300000),
        radius: Radius.elliptical(iconSize.width * 0.08717500, iconSize.height * 0.08717500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_2.lineTo(iconSize.width * 0.2815500, iconSize.height * 0.2300000);
    path_2.arcToPoint(Offset(iconSize.width * 0.2017500, iconSize.height * 0.2799000),
        radius: Radius.elliptical(iconSize.width * 0.08700000, iconSize.height * 0.08700000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_2.lineTo(iconSize.width * 0.09925000, iconSize.height * 0.5055750);
    path_2.lineTo(iconSize.width * 0.04675000, iconSize.height * 0.5581000);
    path_2.arcToPoint(Offset(iconSize.width * 0.02477500, iconSize.height * 0.6107500),
        radius: Radius.elliptical(iconSize.width * 0.07387500, iconSize.height * 0.07387500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_2.lineTo(iconSize.width * 0.02477500, iconSize.height * 0.7764750);
    path_2.arcToPoint(Offset(iconSize.width * 0.09940000, iconSize.height * 0.8509750),
        radius: Radius.elliptical(iconSize.width * 0.07465000, iconSize.height * 0.07465000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_2.lineTo(iconSize.width * 0.8942500, iconSize.height * 0.8509750);
    path_2.arcToPoint(Offset(iconSize.width * 0.9687500, iconSize.height * 0.7764750),
        radius: Radius.elliptical(iconSize.width * 0.07455000, iconSize.height * 0.07455000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_2.lineTo(iconSize.width * 0.9687500, iconSize.height * 0.6107250);
    path_2.arcToPoint(Offset(iconSize.width * 0.9469750, iconSize.height * 0.5580000),
        radius: Radius.elliptical(iconSize.width * 0.07407500, iconSize.height * 0.07407500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_2.close();
    path_2.moveTo(iconSize.width * 0.1868250, iconSize.height * 0.4928750);
    path_2.lineTo(iconSize.width * 0.2696250, iconSize.height * 0.3106250);
    path_2.arcToPoint(Offset(iconSize.width * 0.2815500, iconSize.height * 0.3045000),
        radius: Radius.elliptical(iconSize.width * 0.01307500, iconSize.height * 0.01307500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_2.lineTo(iconSize.width * 0.7121000, iconSize.height * 0.3045000);
    path_2.arcToPoint(Offset(iconSize.width * 0.7240250, iconSize.height * 0.3106500),
        radius: Radius.elliptical(iconSize.width * 0.01307500, iconSize.height * 0.01307500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_2.lineTo(iconSize.width * 0.8068250, iconSize.height * 0.4928750);
    path_2.arcToPoint(Offset(iconSize.width * 0.8063250, iconSize.height * 0.4978750),
        radius: Radius.elliptical(iconSize.width * 0.004850000, iconSize.height * 0.004850000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_2.arcToPoint(Offset(iconSize.width * 0.7949250, iconSize.height * 0.5032250),
        radius: Radius.elliptical(iconSize.width * 0.01310000, iconSize.height * 0.01310000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_2.lineTo(iconSize.width * 0.1987250, iconSize.height * 0.5032250);
    path_2.arcToPoint(Offset(iconSize.width * 0.1872250, iconSize.height * 0.4978500),
        radius: Radius.elliptical(iconSize.width * 0.01325000, iconSize.height * 0.01325000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_2.arcToPoint(Offset(iconSize.width * 0.1868250, iconSize.height * 0.4928500),
        radius: Radius.elliptical(iconSize.width * 0.004625000, iconSize.height * 0.004625000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_2.moveTo(iconSize.width * 0.1863250, iconSize.height * 0.7515750);
    path_2.arcToPoint(Offset(iconSize.width * 0.1863250, iconSize.height * 0.6274500),
        radius: Radius.elliptical(iconSize.width * 0.06207500, iconSize.height * 0.06207500),
        rotation: 0,
        largeArc: true,
        clockwise: true);
    path_2.arcToPoint(Offset(iconSize.width * 0.1863250, iconSize.height * 0.7515750),
        radius: Radius.elliptical(iconSize.width * 0.06205000, iconSize.height * 0.06205000),
        rotation: 0,
        largeArc: true,
        clockwise: true);
    path_2.moveTo(iconSize.width * 0.6210000, iconSize.height * 0.7888750);
    path_2.cubicTo(
        iconSize.width * 0.6210000,
        iconSize.height * 0.7958000,
        iconSize.width * 0.6154250,
        iconSize.height * 0.8013750,
        iconSize.width * 0.6085000,
        iconSize.height * 0.8013750);
    path_2.lineTo(iconSize.width * 0.3850500, iconSize.height * 0.8013750);
    path_2.arcToPoint(Offset(iconSize.width * 0.3725500, iconSize.height * 0.7888750),
        radius: Radius.elliptical(iconSize.width * 0.01245000, iconSize.height * 0.01245000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_2.lineTo(iconSize.width * 0.3725500, iconSize.height * 0.7143750);
    path_2.cubicTo(
        iconSize.width * 0.3725500,
        iconSize.height * 0.7074250,
        iconSize.width * 0.3781250,
        iconSize.height * 0.7018750,
        iconSize.width * 0.3850500,
        iconSize.height * 0.7018750);
    path_2.lineTo(iconSize.width * 0.6086000, iconSize.height * 0.7018750);
    path_2.cubicTo(
        iconSize.width * 0.6155250,
        iconSize.height * 0.7018750,
        iconSize.width * 0.6211000,
        iconSize.height * 0.7074250,
        iconSize.width * 0.6211000,
        iconSize.height * 0.7143750);
    path_2.close();
    path_2.moveTo(iconSize.width * 0.8073250, iconSize.height * 0.7515750);
    path_2.arcToPoint(Offset(iconSize.width * 0.8073250, iconSize.height * 0.6274500),
        radius: Radius.elliptical(iconSize.width * 0.06207500, iconSize.height * 0.06207500),
        rotation: 0,
        largeArc: true,
        clockwise: true);
    path_2.arcToPoint(Offset(iconSize.width * 0.8073250, iconSize.height * 0.7515750),
        radius: Radius.elliptical(iconSize.width * 0.06205000, iconSize.height * 0.06205000),
        rotation: 0,
        largeArc: true,
        clockwise: true);

    Paint paint2Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint2Fill.color = const Color(0xff70c519).withOpacity(1);
    canvas.drawPath(path_2, paint2Fill);

    Path path_3 = Path();
    path_3.moveTo(iconSize.width * 0.2980500, iconSize.height * 0.08095000);
    path_3.lineTo(iconSize.width * 0.6956000, iconSize.height * 0.08095000);
    path_3.lineTo(iconSize.width * 0.6956000, iconSize.height * 0.2050750);
    path_3.lineTo(iconSize.width * 0.7452250, iconSize.height * 0.2050750);
    path_3.lineTo(iconSize.width * 0.7452250, iconSize.height * 0.08095000);
    path_3.cubicTo(
        iconSize.width * 0.7452250,
        iconSize.height * 0.05352500,
        iconSize.width * 0.7229500,
        iconSize.height * 0.03125000,
        iconSize.width * 0.6955000,
        iconSize.height * 0.03125000);
    path_3.lineTo(iconSize.width * 0.2980500, iconSize.height * 0.03125000);
    path_3.arcToPoint(Offset(iconSize.width * 0.2484250, iconSize.height * 0.08095000),
        radius: Radius.elliptical(iconSize.width * 0.04970000, iconSize.height * 0.04970000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_3.lineTo(iconSize.width * 0.2484250, iconSize.height * 0.2050750);
    path_3.lineTo(iconSize.width * 0.2980500, iconSize.height * 0.2050750);
    path_3.close();
    path_3.moveTo(iconSize.width * 0.2980500, iconSize.height * 0.08095000);

    Paint paint3Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint3Fill.color = const Color(0xff70c519).withOpacity(1);
    canvas.drawPath(path_3, paint3Fill);

    Path path_4 = Path();
    path_4.moveTo(iconSize.width * 0.3731500, iconSize.height * 0.1927500);
    path_4.lineTo(iconSize.width * 0.3984250, iconSize.height * 0.1927500);
    path_4.cubicTo(
        iconSize.width * 0.3991250,
        iconSize.height * 0.1927500,
        iconSize.width * 0.3997000,
        iconSize.height * 0.1922000,
        iconSize.width * 0.3997000,
        iconSize.height * 0.1915000);
    path_4.lineTo(iconSize.width * 0.3997000, iconSize.height * 0.1297750);
    path_4.cubicTo(
        iconSize.width * 0.3997000,
        iconSize.height * 0.1291000,
        iconSize.width * 0.4003000,
        iconSize.height * 0.1285250,
        iconSize.width * 0.4009750,
        iconSize.height * 0.1285250);
    path_4.lineTo(iconSize.width * 0.4227500, iconSize.height * 0.1285250);
    path_4.cubicTo(
        iconSize.width * 0.4234250,
        iconSize.height * 0.1285250,
        iconSize.width * 0.4240000,
        iconSize.height * 0.1279250,
        iconSize.width * 0.4240000,
        iconSize.height * 0.1272500);
    path_4.lineTo(iconSize.width * 0.4240000, iconSize.height * 0.1070000);
    path_4.arcToPoint(Offset(iconSize.width * 0.4227500, iconSize.height * 0.1057500),
        radius: Radius.elliptical(iconSize.width * 0.001300000, iconSize.height * 0.001300000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_4.lineTo(iconSize.width * 0.3490000, iconSize.height * 0.1057500);
    path_4.arcToPoint(Offset(iconSize.width * 0.3477500, iconSize.height * 0.1070000),
        radius: Radius.elliptical(iconSize.width * 0.001300000, iconSize.height * 0.001300000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_4.lineTo(iconSize.width * 0.3477500, iconSize.height * 0.1272250);
    path_4.cubicTo(
        iconSize.width * 0.3477500,
        iconSize.height * 0.1279000,
        iconSize.width * 0.3483500,
        iconSize.height * 0.1284750,
        iconSize.width * 0.3490000,
        iconSize.height * 0.1284750);
    path_4.lineTo(iconSize.width * 0.3707000, iconSize.height * 0.1284750);
    path_4.cubicTo(
        iconSize.width * 0.3713750,
        iconSize.height * 0.1284750,
        iconSize.width * 0.3719500,
        iconSize.height * 0.1290750,
        iconSize.width * 0.3719500,
        iconSize.height * 0.1297500);
    path_4.lineTo(iconSize.width * 0.3719500, iconSize.height * 0.1915000);
    path_4.cubicTo(
        iconSize.width * 0.3719500,
        iconSize.height * 0.1921750,
        iconSize.width * 0.3724500,
        iconSize.height * 0.1927500,
        iconSize.width * 0.3731500,
        iconSize.height * 0.1927500);
    path_4.moveTo(iconSize.width * 0.4215750, iconSize.height * 0.1927500);
    path_4.lineTo(iconSize.width * 0.4463000, iconSize.height * 0.1927500);
    path_4.cubicTo(
        iconSize.width * 0.4472750,
        iconSize.height * 0.1926750,
        iconSize.width * 0.4482500,
        iconSize.height * 0.1921000,
        iconSize.width * 0.4485500,
        iconSize.height * 0.1911250);
    path_4.lineTo(iconSize.width * 0.4529250, iconSize.height * 0.1792000);
    path_4.arcToPoint(Offset(iconSize.width * 0.4552750, iconSize.height * 0.1775500),
        radius: Radius.elliptical(iconSize.width * 0.002525000, iconSize.height * 0.002525000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_4.lineTo(iconSize.width * 0.4831000, iconSize.height * 0.1775500);
    path_4.cubicTo(
        iconSize.width * 0.4841750,
        iconSize.height * 0.1775500,
        iconSize.width * 0.4850500,
        iconSize.height * 0.1782250,
        iconSize.width * 0.4854500,
        iconSize.height * 0.1792000);
    path_4.lineTo(iconSize.width * 0.4898500, iconSize.height * 0.1911250);
    path_4.cubicTo(
        iconSize.width * 0.4901250,
        iconSize.height * 0.1921000,
        iconSize.width * 0.4911000,
        iconSize.height * 0.1927750,
        iconSize.width * 0.4921000,
        iconSize.height * 0.1927750);
    path_4.lineTo(iconSize.width * 0.5172750, iconSize.height * 0.1927750);
    path_4.cubicTo(
        iconSize.width * 0.5174750,
        iconSize.height * 0.1927750,
        iconSize.width * 0.5175750,
        iconSize.height * 0.1925750,
        iconSize.width * 0.5177750,
        iconSize.height * 0.1924750);
    path_4.cubicTo(
        iconSize.width * 0.5179750,
        iconSize.height * 0.1923750,
        iconSize.width * 0.5180750,
        iconSize.height * 0.1927750,
        iconSize.width * 0.5182750,
        iconSize.height * 0.1927750);
    path_4.lineTo(iconSize.width * 0.5468750, iconSize.height * 0.1927750);
    path_4.cubicTo(
        iconSize.width * 0.5473750,
        iconSize.height * 0.1927750,
        iconSize.width * 0.5477500,
        iconSize.height * 0.1924750,
        iconSize.width * 0.5479500,
        iconSize.height * 0.1921750);
    path_4.lineTo(iconSize.width * 0.5604500, iconSize.height * 0.1713000);
    path_4.arcToPoint(Offset(iconSize.width * 0.5615250, iconSize.height * 0.1707000),
        radius: Radius.elliptical(iconSize.width * 0.001350000, iconSize.height * 0.001350000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_4.cubicTo(
        iconSize.width * 0.5620250,
        iconSize.height * 0.1707000,
        iconSize.width * 0.5624000,
        iconSize.height * 0.1709000,
        iconSize.width * 0.5626000,
        iconSize.height * 0.1713000);
    path_4.lineTo(iconSize.width * 0.5754000, iconSize.height * 0.1921750);
    path_4.arcToPoint(Offset(iconSize.width * 0.5764750, iconSize.height * 0.1927750),
        radius: Radius.elliptical(iconSize.width * 0.001350000, iconSize.height * 0.001350000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_4.lineTo(iconSize.width * 0.6052750, iconSize.height * 0.1927750);
    path_4.arcToPoint(Offset(iconSize.width * 0.6063500, iconSize.height * 0.1921000),
        radius: Radius.elliptical(iconSize.width * 0.001325000, iconSize.height * 0.001325000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_4.arcToPoint(Offset(iconSize.width * 0.6062500, iconSize.height * 0.1908250),
        radius: Radius.elliptical(iconSize.width * 0.001200000, iconSize.height * 0.001200000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_4.lineTo(iconSize.width * 0.5776250, iconSize.height * 0.1484250);
    path_4.arcToPoint(Offset(iconSize.width * 0.5776250, iconSize.height * 0.1470750),
        radius: Radius.elliptical(iconSize.width * 0.001175000, iconSize.height * 0.001175000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_4.lineTo(iconSize.width * 0.6045000, iconSize.height * 0.1077250);
    path_4.arcToPoint(Offset(iconSize.width * 0.6046000, iconSize.height * 0.1064500),
        radius: Radius.elliptical(iconSize.width * 0.001200000, iconSize.height * 0.001200000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_4.arcToPoint(Offset(iconSize.width * 0.6035250, iconSize.height * 0.1057500),
        radius: Radius.elliptical(iconSize.width * 0.001325000, iconSize.height * 0.001325000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_4.lineTo(iconSize.width * 0.5765750, iconSize.height * 0.1057500);
    path_4.arcToPoint(Offset(iconSize.width * 0.5755750, iconSize.height * 0.1063500),
        radius: Radius.elliptical(iconSize.width * 0.001075000, iconSize.height * 0.001075000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_4.lineTo(iconSize.width * 0.5632750, iconSize.height * 0.1259750);
    path_4.arcToPoint(Offset(iconSize.width * 0.5622000, iconSize.height * 0.1265750),
        radius: Radius.elliptical(iconSize.width * 0.001325000, iconSize.height * 0.001325000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_4.cubicTo(
        iconSize.width * 0.5618250,
        iconSize.height * 0.1265750,
        iconSize.width * 0.5614250,
        iconSize.height * 0.1262750,
        iconSize.width * 0.5611250,
        iconSize.height * 0.1259750);
    path_4.lineTo(iconSize.width * 0.5486250, iconSize.height * 0.1063500);
    path_4.cubicTo(
        iconSize.width * 0.5484250,
        iconSize.height * 0.1059500,
        iconSize.width * 0.5479500,
        iconSize.height * 0.1057500,
        iconSize.width * 0.5475500,
        iconSize.height * 0.1057500);
    path_4.lineTo(iconSize.width * 0.5192500, iconSize.height * 0.1057500);
    path_4.arcToPoint(Offset(iconSize.width * 0.5181750, iconSize.height * 0.1064500),
        radius: Radius.elliptical(iconSize.width * 0.001200000, iconSize.height * 0.001200000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_4.arcToPoint(Offset(iconSize.width * 0.5182500, iconSize.height * 0.1077000),
        radius: Radius.elliptical(iconSize.width * 0.001200000, iconSize.height * 0.001200000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_4.lineTo(iconSize.width * 0.5453000, iconSize.height * 0.1482500);
    path_4.cubicTo(
        iconSize.width * 0.5456000,
        iconSize.height * 0.1487500,
        iconSize.width * 0.5456000,
        iconSize.height * 0.1492250,
        iconSize.width * 0.5453000,
        iconSize.height * 0.1497000);
    path_4.lineTo(iconSize.width * 0.5180000, iconSize.height * 0.1897500);
    path_4.lineTo(iconSize.width * 0.4835000, iconSize.height * 0.1065500);
    path_4.cubicTo(
        iconSize.width * 0.4833250,
        iconSize.height * 0.1060500,
        iconSize.width * 0.4828500,
        iconSize.height * 0.1057500,
        iconSize.width * 0.4822500,
        iconSize.height * 0.1057500);
    path_4.lineTo(iconSize.width * 0.4566750, iconSize.height * 0.1057500);
    path_4.arcToPoint(Offset(iconSize.width * 0.4555000, iconSize.height * 0.1065500),
        radius: Radius.elliptical(iconSize.width * 0.001175000, iconSize.height * 0.001175000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_4.lineTo(iconSize.width * 0.4204000, iconSize.height * 0.1910000);
    path_4.cubicTo(
        iconSize.width * 0.4203250,
        iconSize.height * 0.1913750,
        iconSize.width * 0.4203250,
        iconSize.height * 0.1917500,
        iconSize.width * 0.4206000,
        iconSize.height * 0.1921500);
    path_4.cubicTo(
        iconSize.width * 0.4208000,
        iconSize.height * 0.1924500,
        iconSize.width * 0.4212000,
        iconSize.height * 0.1926500,
        iconSize.width * 0.4216000,
        iconSize.height * 0.1927500);
    path_4.moveTo(iconSize.width * 0.4691500, iconSize.height * 0.1345500);
    path_4.lineTo(iconSize.width * 0.4771500, iconSize.height * 0.1564250);
    path_4.lineTo(iconSize.width * 0.4610250, iconSize.height * 0.1564250);
    path_4.close();
    path_4.moveTo(iconSize.width * 0.6205000, iconSize.height * 0.1057500);
    path_4.lineTo(iconSize.width * 0.6433500, iconSize.height * 0.1057500);
    path_4.arcToPoint(Offset(iconSize.width * 0.6458000, iconSize.height * 0.1083000),
        radius: Radius.elliptical(iconSize.width * 0.002500000, iconSize.height * 0.002500000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_4.lineTo(iconSize.width * 0.6458000, iconSize.height * 0.1902250);
    path_4.arcToPoint(Offset(iconSize.width * 0.6433500, iconSize.height * 0.1927750),
        radius: Radius.elliptical(iconSize.width * 0.002500000, iconSize.height * 0.002500000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_4.lineTo(iconSize.width * 0.6205000, iconSize.height * 0.1927750);
    path_4.arcToPoint(Offset(iconSize.width * 0.6180750, iconSize.height * 0.1902250),
        radius: Radius.elliptical(iconSize.width * 0.002500000, iconSize.height * 0.002500000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_4.lineTo(iconSize.width * 0.6180750, iconSize.height * 0.1083000);
    path_4.arcToPoint(Offset(iconSize.width * 0.6205000, iconSize.height * 0.1057500),
        radius: Radius.elliptical(iconSize.width * 0.002500000, iconSize.height * 0.002500000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_4.close();
    path_4.moveTo(iconSize.width * 0.6205000, iconSize.height * 0.1057500);

    Paint paint4Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint4Fill.color = const Color(0xff70c519).withOpacity(1);
    canvas.drawPath(path_4, paint4Fill);
  }

  void _drawAutomobile(Canvas canvas, bool isInside) {
    Path path_0 = Path();
    path_0.moveTo(iconSize.width * 0.07897950, iconSize.height * 0.2500000);
    path_0.lineTo(iconSize.width * 0.1198731, iconSize.height * 0.1500244);
    path_0.lineTo(iconSize.width * 0.05004881, iconSize.height * 0.1500244);
    path_0.cubicTo(
        iconSize.width * 0.02233887,
        iconSize.height * 0.1500244,
        iconSize.width * -1.387779e-17,
        iconSize.height * 0.1723633,
        iconSize.width * -1.387779e-17,
        iconSize.height * 0.1999512);
    path_0.cubicTo(
        iconSize.width * -1.387779e-17,
        iconSize.height * 0.2276611,
        iconSize.width * 0.02233887,
        iconSize.height * 0.2500000,
        iconSize.width * 0.05004881,
        iconSize.height * 0.2500000);
    path_0.close();
    path_0.moveTo(iconSize.width * 0.07897950, iconSize.height * 0.2500000);

    Paint paint0Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint0Fill.color = const Color(0xff00b359).withOpacity(1.0);
    canvas.drawPath(path_0, paint0Fill);

    Path path_1 = Path();
    path_1.moveTo(iconSize.width * 0.9499512, iconSize.height * 0.1500244);
    path_1.lineTo(iconSize.width * 0.8800049, iconSize.height * 0.1500244);
    path_1.lineTo(iconSize.width * 0.9208984, iconSize.height * 0.2500000);
    path_1.lineTo(iconSize.width * 0.9499512, iconSize.height * 0.2500000);
    path_1.cubicTo(iconSize.width * 0.9775391, iconSize.height * 0.2500000, iconSize.width,
        iconSize.height * 0.2276611, iconSize.width, iconSize.height * 0.1999512);
    path_1.cubicTo(iconSize.width, iconSize.height * 0.1723633, iconSize.width * 0.9775391,
        iconSize.height * 0.1500244, iconSize.width * 0.9499512, iconSize.height * 0.1500244);

    Paint paint1Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint1Fill.color = const Color(0xff00b359).withOpacity(1.0);
    canvas.drawPath(path_1, paint1Fill);

    Path path_2 = Path();
    path_2.moveTo(iconSize.width * 0.08752441, iconSize.height * 0.6241455);
    path_2.lineTo(iconSize.width * 0.08752441, iconSize.height * 0.6812744);
    path_2.cubicTo(
        iconSize.width * 0.08752441,
        iconSize.height * 0.7192383,
        iconSize.width * 0.1182861,
        iconSize.height * 0.7500000,
        iconSize.width * 0.1562500,
        iconSize.height * 0.7500000);
    path_2.cubicTo(
        iconSize.width * 0.1942139,
        iconSize.height * 0.7500000,
        iconSize.width * 0.2249756,
        iconSize.height * 0.7192383,
        iconSize.width * 0.2249756,
        iconSize.height * 0.6812744);
    path_2.lineTo(iconSize.width * 0.2249756, iconSize.height * 0.6250000);
    path_2.lineTo(iconSize.width * 0.09997559, iconSize.height * 0.6250000);
    path_2.cubicTo(
        iconSize.width * 0.09582519,
        iconSize.height * 0.6250000,
        iconSize.width * 0.09167481,
        iconSize.height * 0.6246338,
        iconSize.width * 0.08752441,
        iconSize.height * 0.6241455);

    Paint paint2Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint2Fill.color = const Color(0xff00b359).withOpacity(1.0);
    canvas.drawPath(path_2, paint2Fill);

    Path path_3 = Path();
    path_3.moveTo(iconSize.width * 0.7750244, iconSize.height * 0.6250000);
    path_3.lineTo(iconSize.width * 0.7750244, iconSize.height * 0.6812744);
    path_3.cubicTo(
        iconSize.width * 0.7750244,
        iconSize.height * 0.7192383,
        iconSize.width * 0.8057861,
        iconSize.height * 0.7500000,
        iconSize.width * 0.8437500,
        iconSize.height * 0.7500000);
    path_3.cubicTo(
        iconSize.width * 0.8817139,
        iconSize.height * 0.7500000,
        iconSize.width * 0.9124756,
        iconSize.height * 0.7192383,
        iconSize.width * 0.9124756,
        iconSize.height * 0.6812744);
    path_3.lineTo(iconSize.width * 0.9124756, iconSize.height * 0.6241455);
    path_3.cubicTo(
        iconSize.width * 0.9083252,
        iconSize.height * 0.6246338,
        iconSize.width * 0.9041748,
        iconSize.height * 0.6250000,
        iconSize.width * 0.9000244,
        iconSize.height * 0.6250000);
    path_3.close();
    path_3.moveTo(iconSize.width * 0.7750244, iconSize.height * 0.6250000);

    Paint paint3Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint3Fill.color = const Color(0xff00b359).withOpacity(1.0);
    canvas.drawPath(path_3, paint3Fill);

    Path path_4 = Path();
    path_4.moveTo(iconSize.width * 0.9531250, iconSize.height * 0.3176269);
    path_4.lineTo(iconSize.width * 0.9003906, iconSize.height * 0.2648926);
    path_4.lineTo(iconSize.width * 0.7972412, iconSize.height * 0.05017091);
    path_4.cubicTo(
        iconSize.width * 0.7824707,
        iconSize.height * 0.01916503,
        iconSize.width * 0.7509766,
        iconSize.height * -0.0004882813,
        iconSize.width * 0.7166748,
        iconSize.height * -2.081668e-17);
    path_4.lineTo(iconSize.width * 0.2833252, iconSize.height * -2.081668e-17);
    path_4.cubicTo(
        iconSize.width * 0.2491455,
        iconSize.height * -0.0003662125,
        iconSize.width * 0.2177734,
        iconSize.height * 0.01928712,
        iconSize.width * 0.2031250,
        iconSize.height * 0.05017091);
    path_4.lineTo(iconSize.width * 0.09997559, iconSize.height * 0.2648926);
    path_4.lineTo(iconSize.width * 0.04687500, iconSize.height * 0.3176269);
    path_4.cubicTo(
        iconSize.width * 0.03271484,
        iconSize.height * 0.3317871,
        iconSize.width * 0.02490234,
        iconSize.height * 0.3508301,
        iconSize.width * 0.02502441,
        iconSize.height * 0.3708496);
    path_4.lineTo(iconSize.width * 0.02502441, iconSize.height * 0.5250244);
    path_4.cubicTo(
        iconSize.width * 0.02502441,
        iconSize.height * 0.5664063,
        iconSize.width * 0.05859375,
        iconSize.height * 0.5999756,
        iconSize.width * 0.09997559,
        iconSize.height * 0.5999756);
    path_4.lineTo(iconSize.width * 0.9000244, iconSize.height * 0.5999756);
    path_4.cubicTo(
        iconSize.width * 0.9414063,
        iconSize.height * 0.5999756,
        iconSize.width * 0.9749756,
        iconSize.height * 0.5664063,
        iconSize.width * 0.9749756,
        iconSize.height * 0.5250244);
    path_4.lineTo(iconSize.width * 0.9749756, iconSize.height * 0.3707275);
    path_4.cubicTo(
        iconSize.width * 0.9750977,
        iconSize.height * 0.3508301,
        iconSize.width * 0.9672852,
        iconSize.height * 0.3316650,
        iconSize.width * 0.9531250,
        iconSize.height * 0.3176269);
    path_4.moveTo(iconSize.width * 0.1879883, iconSize.height * 0.2520752);
    path_4.lineTo(iconSize.width * 0.2713623, iconSize.height * 0.08129881);
    path_4.cubicTo(
        iconSize.width * 0.2738037,
        iconSize.height * 0.07714844,
        iconSize.width * 0.2784424,
        iconSize.height * 0.07470703,
        iconSize.width * 0.2833252,
        iconSize.height * 0.07495119);
    path_4.lineTo(iconSize.width * 0.7166748, iconSize.height * 0.07495119);
    path_4.cubicTo(
        iconSize.width * 0.7215576,
        iconSize.height * 0.07470703,
        iconSize.width * 0.7260742,
        iconSize.height * 0.07714844,
        iconSize.width * 0.7286377,
        iconSize.height * 0.08129881);
    path_4.lineTo(iconSize.width * 0.8120117, iconSize.height * 0.2520752);
    path_4.cubicTo(
        iconSize.width * 0.8128662,
        iconSize.height * 0.2536621,
        iconSize.width * 0.8126221,
        iconSize.height * 0.2557373,
        iconSize.width * 0.8115234,
        iconSize.height * 0.2570801);
    path_4.cubicTo(
        iconSize.width * 0.8088379,
        iconSize.height * 0.2607422,
        iconSize.width * 0.8044434,
        iconSize.height * 0.2628174,
        iconSize.width * 0.7999268,
        iconSize.height * 0.2624512);
    path_4.lineTo(iconSize.width * 0.1999512, iconSize.height * 0.2624512);
    path_4.cubicTo(
        iconSize.width * 0.1954346,
        iconSize.height * 0.2628174,
        iconSize.width * 0.1910400,
        iconSize.height * 0.2607422,
        iconSize.width * 0.1884766,
        iconSize.height * 0.2570801);
    path_4.cubicTo(
        iconSize.width * 0.1872559,
        iconSize.height * 0.2557373,
        iconSize.width * 0.1871338,
        iconSize.height * 0.2536621,
        iconSize.width * 0.1879883,
        iconSize.height * 0.2520752);
    path_4.moveTo(iconSize.width * 0.1875000, iconSize.height * 0.5000000);
    path_4.cubicTo(
        iconSize.width * 0.1529541,
        iconSize.height * 0.5000000,
        iconSize.width * 0.1250000,
        iconSize.height * 0.4720459,
        iconSize.width * 0.1250000,
        iconSize.height * 0.4375000);
    path_4.cubicTo(
        iconSize.width * 0.1250000,
        iconSize.height * 0.4029541,
        iconSize.width * 0.1529541,
        iconSize.height * 0.3750000,
        iconSize.width * 0.1875000,
        iconSize.height * 0.3750000);
    path_4.cubicTo(
        iconSize.width * 0.2220459,
        iconSize.height * 0.3750000,
        iconSize.width * 0.2500000,
        iconSize.height * 0.4029541,
        iconSize.width * 0.2500000,
        iconSize.height * 0.4375000);
    path_4.cubicTo(
        iconSize.width * 0.2500000,
        iconSize.height * 0.4720459,
        iconSize.width * 0.2220459,
        iconSize.height * 0.5000000,
        iconSize.width * 0.1875000,
        iconSize.height * 0.5000000);
    path_4.moveTo(iconSize.width * 0.6250000, iconSize.height * 0.5374756);
    path_4.cubicTo(
        iconSize.width * 0.6250000,
        iconSize.height * 0.5444336,
        iconSize.width * 0.6193848,
        iconSize.height * 0.5500488,
        iconSize.width * 0.6125488,
        iconSize.height * 0.5500488);
    path_4.lineTo(iconSize.width * 0.3874512, iconSize.height * 0.5500488);
    path_4.cubicTo(
        iconSize.width * 0.3806153,
        iconSize.height * 0.5500488,
        iconSize.width * 0.3750000,
        iconSize.height * 0.5444336,
        iconSize.width * 0.3750000,
        iconSize.height * 0.5374756);
    path_4.lineTo(iconSize.width * 0.3750000, iconSize.height * 0.4625244);
    path_4.cubicTo(
        iconSize.width * 0.3750000,
        iconSize.height * 0.4555664,
        iconSize.width * 0.3806153,
        iconSize.height * 0.4499512,
        iconSize.width * 0.3874512,
        iconSize.height * 0.4499512);
    path_4.lineTo(iconSize.width * 0.6125488, iconSize.height * 0.4499512);
    path_4.cubicTo(
        iconSize.width * 0.6193848,
        iconSize.height * 0.4499512,
        iconSize.width * 0.6250000,
        iconSize.height * 0.4555664,
        iconSize.width * 0.6250000,
        iconSize.height * 0.4625244);
    path_4.close();
    path_4.moveTo(iconSize.width * 0.8125000, iconSize.height * 0.5000000);
    path_4.cubicTo(
        iconSize.width * 0.7779541,
        iconSize.height * 0.5000000,
        iconSize.width * 0.7500000,
        iconSize.height * 0.4720459,
        iconSize.width * 0.7500000,
        iconSize.height * 0.4375000);
    path_4.cubicTo(
        iconSize.width * 0.7500000,
        iconSize.height * 0.4029541,
        iconSize.width * 0.7779541,
        iconSize.height * 0.3750000,
        iconSize.width * 0.8125000,
        iconSize.height * 0.3750000);
    path_4.cubicTo(
        iconSize.width * 0.8470459,
        iconSize.height * 0.3750000,
        iconSize.width * 0.8750000,
        iconSize.height * 0.4029541,
        iconSize.width * 0.8750000,
        iconSize.height * 0.4375000);
    path_4.cubicTo(
        iconSize.width * 0.8750000,
        iconSize.height * 0.4720459,
        iconSize.width * 0.8470459,
        iconSize.height * 0.5000000,
        iconSize.width * 0.8125000,
        iconSize.height * 0.5000000);

    Paint paint4Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint4Fill.color = const Color(0xff00b359).withOpacity(1.0);
    canvas.drawPath(path_4, paint4Fill);

    Path path_5 = Path();
    path_5.moveTo(iconSize.width * 0.2446289, iconSize.height * 0.8327637);
    path_5.lineTo(iconSize.width * 0.2443848, iconSize.height * 0.8671875);
    path_5.cubicTo(
        iconSize.width * 0.2441406,
        iconSize.height * 0.8966064,
        iconSize.width * 0.2419434,
        iconSize.height * 0.9260254,
        iconSize.width * 0.2377930,
        iconSize.height * 0.9552002);
    path_5.cubicTo(
        iconSize.width * 0.2368164,
        iconSize.height * 0.9656982,
        iconSize.width * 0.2315674,
        iconSize.height * 0.9753418,
        iconSize.width * 0.2233887,
        iconSize.height * 0.9819336);
    path_5.cubicTo(
        iconSize.width * 0.2150879,
        iconSize.height * 0.9886475,
        iconSize.width * 0.2045898,
        iconSize.height * 0.9916992,
        iconSize.width * 0.1940918,
        iconSize.height * 0.9904785);
    path_5.cubicTo(
        iconSize.width * 0.1801758,
        iconSize.height * 0.9902344,
        iconSize.width * 0.1662597,
        iconSize.height * 0.9891358,
        iconSize.width * 0.1524658,
        iconSize.height * 0.9871826);
    path_5.lineTo(iconSize.width * 0.1502686, iconSize.height * 0.9511719);
    path_5.cubicTo(
        iconSize.width * 0.1614990,
        iconSize.height * 0.9533691,
        iconSize.width * 0.1730957,
        iconSize.height * 0.9545898,
        iconSize.width * 0.1845703,
        iconSize.height * 0.9549561);
    path_5.cubicTo(
        iconSize.width * 0.1992187,
        iconSize.height * 0.9549561,
        iconSize.width * 0.2008057,
        iconSize.height * 0.9509278,
        iconSize.width * 0.2030029,
        iconSize.height * 0.9407959);
    path_5.cubicTo(
        iconSize.width * 0.2059326,
        iconSize.height * 0.9199219,
        iconSize.width * 0.2076416,
        iconSize.height * 0.8989258,
        iconSize.width * 0.2082519,
        iconSize.height * 0.8779297);
    path_5.lineTo(iconSize.width * 0.2082519, iconSize.height * 0.8664551);
    path_5.lineTo(iconSize.width * 0.1589356, iconSize.height * 0.8664551);
    path_5.cubicTo(
        iconSize.width * 0.1524658,
        iconSize.height * 0.9179688,
        iconSize.width * 0.1231689,
        iconSize.height * 0.9638672,
        iconSize.width * 0.07922362,
        iconSize.height * 0.9914551);
    path_5.lineTo(iconSize.width * 0.05358887, iconSize.height * 0.9653320);
    path_5.cubicTo(
        iconSize.width * 0.09130859,
        iconSize.height * 0.9455566,
        iconSize.width * 0.1168213,
        iconSize.height * 0.9085693,
        iconSize.width * 0.1220703,
        iconSize.height * 0.8663330);
    path_5.lineTo(iconSize.width * 0.06506347, iconSize.height * 0.8663330);
    path_5.lineTo(iconSize.width * 0.06506347, iconSize.height * 0.8325195);
    path_5.lineTo(iconSize.width * 0.1258545, iconSize.height * 0.8325195);
    path_5.cubicTo(
        iconSize.width * 0.1271972,
        iconSize.height * 0.8106689,
        iconSize.width * 0.1271972,
        iconSize.height * 0.8012695,
        iconSize.width * 0.1271972,
        iconSize.height * 0.7943115);
    path_5.lineTo(iconSize.width * 0.1656494, iconSize.height * 0.7945557);
    path_5.cubicTo(
        iconSize.width * 0.1650391,
        iconSize.height * 0.8046875,
        iconSize.width * 0.1645508,
        iconSize.height * 0.8153076,
        iconSize.width * 0.1632080,
        iconSize.height * 0.8325195);
    path_5.close();
    path_5.moveTo(iconSize.width * 0.2103272, iconSize.height * 0.8260498);
    path_5.cubicTo(
        iconSize.width * 0.2084961,
        iconSize.height * 0.8138428,
        iconSize.width * 0.2058106,
        iconSize.height * 0.8017578,
        iconSize.width * 0.2020264,
        iconSize.height * 0.7900391);
    path_5.lineTo(iconSize.width * 0.2219238, iconSize.height * 0.7871094);
    path_5.cubicTo(
        iconSize.width * 0.2259522,
        iconSize.height * 0.7985840,
        iconSize.width * 0.2291260,
        iconSize.height * 0.8104248,
        iconSize.width * 0.2312012,
        iconSize.height * 0.8223877);
    path_5.close();
    path_5.moveTo(iconSize.width * 0.2427978, iconSize.height * 0.8223877);
    path_5.cubicTo(
        iconSize.width * 0.2406006,
        iconSize.height * 0.8107910,
        iconSize.width * 0.2375488,
        iconSize.height * 0.7993164,
        iconSize.width * 0.2333984,
        iconSize.height * 0.7882080);
    path_5.lineTo(iconSize.width * 0.2534180, iconSize.height * 0.7852783);
    path_5.cubicTo(
        iconSize.width * 0.2574463,
        iconSize.height * 0.7961426,
        iconSize.width * 0.2606201,
        iconSize.height * 0.8073731,
        iconSize.width * 0.2628174,
        iconSize.height * 0.8188477);
    path_5.close();
    path_5.moveTo(iconSize.width * 0.2427978, iconSize.height * 0.8223877);

    Paint paint5Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint5Fill.color = const Color(0xff00b359).withOpacity(1.0);
    canvas.drawPath(path_5, paint5Fill);

    Path path_6 = Path();
    path_6.moveTo(iconSize.width * 0.3414307, iconSize.height * 0.8861084);
    path_6.cubicTo(
        iconSize.width * 0.3298340,
        iconSize.height * 0.8637695,
        iconSize.width * 0.3160400,
        iconSize.height * 0.8426514,
        iconSize.width * 0.3001709,
        iconSize.height * 0.8231201);
    path_6.lineTo(iconSize.width * 0.3312988, iconSize.height * 0.8057861);
    path_6.cubicTo(
        iconSize.width * 0.3483887,
        iconSize.height * 0.8236084,
        iconSize.width * 0.3632813,
        iconSize.height * 0.8436279,
        iconSize.width * 0.3753662,
        iconSize.height * 0.8651123);
    path_6.close();
    path_6.moveTo(iconSize.width * 0.3177490, iconSize.height * 0.9576416);
    path_6.cubicTo(
        iconSize.width * 0.3665772,
        iconSize.height * 0.9451904,
        iconSize.width * 0.4287109,
        iconSize.height * 0.9250488,
        iconSize.width * 0.4495850,
        iconSize.height * 0.8012695);
    path_6.lineTo(iconSize.width * 0.4902344, iconSize.height * 0.8095703);
    path_6.cubicTo(
        iconSize.width * 0.4611816,
        iconSize.height * 0.9299316,
        iconSize.width * 0.4134522,
        iconSize.height * 0.9698486,
        iconSize.width * 0.3363037,
        iconSize.height * 0.9903564);
    path_6.close();
    path_6.moveTo(iconSize.width * 0.3177490, iconSize.height * 0.9576416);

    Paint paint6Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint6Fill.color = const Color(0xff00b359).withOpacity(1.0);
    canvas.drawPath(path_6, paint6Fill);

    Path path_7 = Path();
    path_7.moveTo(iconSize.width * 0.5837402, iconSize.height * 0.9243164);
    path_7.lineTo(iconSize.width * 0.5458984, iconSize.height * 0.9243164);
    path_7.lineTo(iconSize.width * 0.5458984, iconSize.height * 0.8007813);
    path_7.lineTo(iconSize.width * 0.5837402, iconSize.height * 0.8007813);
    path_7.close();
    path_7.moveTo(iconSize.width * 0.6925049, iconSize.height * 0.8901367);
    path_7.cubicTo(
        iconSize.width * 0.6925049,
        iconSize.height * 0.9722900,
        iconSize.width * 0.6309814,
        iconSize.height * 0.9855957,
        iconSize.width * 0.5709228,
        iconSize.height * 0.9923096);
    path_7.lineTo(iconSize.width * 0.5573731, iconSize.height * 0.9576416);
    path_7.cubicTo(
        iconSize.width * 0.6206055,
        iconSize.height * 0.9533691,
        iconSize.width * 0.6542969,
        iconSize.height * 0.9411621,
        iconSize.width * 0.6542969,
        iconSize.height * 0.8955078);
    path_7.lineTo(iconSize.width * 0.6542969, iconSize.height * 0.7969971);
    path_7.lineTo(iconSize.width * 0.6922608, iconSize.height * 0.7969971);
    path_7.close();
    path_7.moveTo(iconSize.width * 0.6925049, iconSize.height * 0.8901367);

    Paint paint7Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint7Fill.color = const Color(0xff00b359).withOpacity(1.0);
    canvas.drawPath(path_7, paint7Fill);

    Path path_8 = Path();
    path_8.moveTo(iconSize.width * 0.8204346, iconSize.height * 0.8701172);
    path_8.cubicTo(
        iconSize.width * 0.7984619,
        iconSize.height * 0.8554688,
        iconSize.width * 0.7746582,
        iconSize.height * 0.8437500,
        iconSize.width * 0.7495117,
        iconSize.height * 0.8353272);
    path_8.lineTo(iconSize.width * 0.7657471, iconSize.height * 0.8046875);
    path_8.cubicTo(
        iconSize.width * 0.7916260,
        iconSize.height * 0.8121338,
        iconSize.width * 0.8165283,
        iconSize.height * 0.8229981,
        iconSize.width * 0.8394775,
        iconSize.height * 0.8370361);
    path_8.close();
    path_8.moveTo(iconSize.width * 0.7526856, iconSize.height * 0.9504394);
    path_8.cubicTo(
        iconSize.width * 0.8402100,
        iconSize.height * 0.9434814,
        iconSize.width * 0.8863525,
        iconSize.height * 0.9102783,
        iconSize.width * 0.9121094,
        iconSize.height * 0.8194580);
    path_8.lineTo(iconSize.width * 0.9460449, iconSize.height * 0.8364258);
    path_8.cubicTo(
        iconSize.width * 0.9111328,
        iconSize.height * 0.9538574,
        iconSize.width * 0.8416748,
        iconSize.height * 0.9781494,
        iconSize.width * 0.7646484,
        iconSize.height * 0.9891357);
    path_8.close();
    path_8.moveTo(iconSize.width * 0.7526856, iconSize.height * 0.9504394);

    Paint paint8Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint8Fill.color = const Color(0xff00b359).withOpacity(1.0);
    canvas.drawPath(path_8, paint8Fill);
  }

  void _drawMotocycle(Canvas canvas, bool isInside) {
    Path path_0 = Path();
    path_0.moveTo(iconSize.width * 0.3277500, iconSize.height * 0.3000000);
    path_0.arcToPoint(Offset(iconSize.width * 0.4363250, iconSize.height * 0.4772500),
        radius: Radius.elliptical(iconSize.width * 0.2373250, iconSize.height * 0.2373250),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.arcToPoint(Offset(iconSize.width * 0.4610250, iconSize.height * 0.5000000),
        radius: Radius.elliptical(iconSize.width * 0.02492500, iconSize.height * 0.02492500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.5387750, iconSize.height * 0.5000000);
    path_0.arcToPoint(Offset(iconSize.width * 0.5634750, iconSize.height * 0.4772500),
        radius: Radius.elliptical(iconSize.width * 0.02500000, iconSize.height * 0.02500000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.5635750, iconSize.height * 0.4772500);
    path_0.arcToPoint(Offset(iconSize.width * 0.6722750, iconSize.height * 0.3000000),
        radius: Radius.elliptical(iconSize.width * 0.2374500, iconSize.height * 0.2374500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.close();
    path_0.moveTo(iconSize.width * 0.4250000, iconSize.height * 0.1812500);
    path_0.lineTo(iconSize.width * 0.3325000, iconSize.height * 0.1812500);
    path_0.cubicTo(
        iconSize.width * 0.2744250,
        iconSize.height * 0.1812500,
        iconSize.width * 0.2101500,
        iconSize.height * 0.1437500,
        iconSize.width * 0.1771500,
        iconSize.height * 0.1437500);
    path_0.lineTo(iconSize.width * 0.1250000, iconSize.height * 0.1437500);
    path_0.cubicTo(
        iconSize.width * 0.1112500,
        iconSize.height * 0.1437500,
        iconSize.width * 0.1000000,
        iconSize.height * 0.1550000,
        iconSize.width * 0.1000000,
        iconSize.height * 0.1687500);
    path_0.lineTo(iconSize.width * 0.1000000, iconSize.height * 0.2375000);
    path_0.cubicTo(
        iconSize.width * 0.1000000,
        iconSize.height * 0.2512500,
        iconSize.width * 0.1112500,
        iconSize.height * 0.2625000,
        iconSize.width * 0.1250000,
        iconSize.height * 0.2625000);
    path_0.lineTo(iconSize.width * 0.4250000, iconSize.height * 0.2625000);
    path_0.close();
    path_0.moveTo(iconSize.width * 0.7278250, iconSize.height * 0.2302500);
    path_0.lineTo(iconSize.width * 0.7053750, iconSize.height * 0.1552500);
    path_0.arcToPoint(Offset(iconSize.width * 0.6814500, iconSize.height * 0.1375000),
        radius: Radius.elliptical(iconSize.width * 0.02500000, iconSize.height * 0.02500000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.5632000, iconSize.height * 0.1375000);
    path_0.arcToPoint(Offset(iconSize.width * 0.4625000, iconSize.height * 0.1715750),
        radius: Radius.elliptical(iconSize.width * 0.1969250, iconSize.height * 0.1969250),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.4625000, iconSize.height * 0.2625000);
    path_0.lineTo(iconSize.width * 0.7039000, iconSize.height * 0.2625000);
    path_0.arcToPoint(Offset(iconSize.width * 0.7239250, iconSize.height * 0.2524500),
        radius: Radius.elliptical(iconSize.width * 0.02485000, iconSize.height * 0.02485000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.arcToPoint(Offset(iconSize.width * 0.7278250, iconSize.height * 0.2302750),
        radius: Radius.elliptical(iconSize.width * 0.02467500, iconSize.height * 0.02467500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.moveTo(iconSize.width * 0.2000000, iconSize.height * 0.7000000);
    path_0.arcToPoint(Offset(iconSize.width * 0.4000000, iconSize.height * 0.5000000),
        radius: Radius.elliptical(iconSize.width * 0.2000000, iconSize.height * 0.2000000),
        rotation: 0,
        largeArc: true,
        clockwise: true);
    path_0.arcToPoint(Offset(iconSize.width * 0.2000000, iconSize.height * 0.7000000),
        radius: Radius.elliptical(iconSize.width * 0.2001250, iconSize.height * 0.2001250),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.moveTo(iconSize.width * 0.2000000, iconSize.height * 0.3750000);
    path_0.arcToPoint(Offset(iconSize.width * 0.2000000, iconSize.height * 0.6250000),
        radius: Radius.elliptical(iconSize.width * 0.1250000, iconSize.height * 0.1250000),
        rotation: 0,
        largeArc: true,
        clockwise: false);
    path_0.arcToPoint(Offset(iconSize.width * 0.2000000, iconSize.height * 0.3750000),
        radius: Radius.elliptical(iconSize.width * 0.1250000, iconSize.height * 0.1250000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.moveTo(iconSize.width * 0.8000000, iconSize.height * 0.7000000);
    path_0.arcToPoint(Offset(iconSize.width, iconSize.height * 0.5000000),
        radius: Radius.elliptical(iconSize.width * 0.2000000, iconSize.height * 0.2000000),
        rotation: 0,
        largeArc: true,
        clockwise: true);
    path_0.arcToPoint(Offset(iconSize.width * 0.8000000, iconSize.height * 0.7000000),
        radius: Radius.elliptical(iconSize.width * 0.2001250, iconSize.height * 0.2001250),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.moveTo(iconSize.width * 0.8000000, iconSize.height * 0.3750000);
    path_0.arcToPoint(Offset(iconSize.width * 0.8000000, iconSize.height * 0.6250000),
        radius: Radius.elliptical(iconSize.width * 0.1250000, iconSize.height * 0.1250000),
        rotation: 0,
        largeArc: true,
        clockwise: false);
    path_0.arcToPoint(Offset(iconSize.width * 0.8000000, iconSize.height * 0.3750000),
        radius: Radius.elliptical(iconSize.width * 0.1250000, iconSize.height * 0.1250000),
        rotation: 0,
        largeArc: false,
        clockwise: false);

    Paint paint0Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint0Fill.color = const Color(0xffcc42cc).withOpacity(1);
    canvas.drawPath(path_0, paint0Fill);

    Path path_1 = Path();
    path_1.moveTo(iconSize.width * 0.2500000, iconSize.height * 0.5000000);
    path_1.arcToPoint(Offset(iconSize.width * 0.1500000, iconSize.height * 0.5000000),
        radius: Radius.elliptical(iconSize.width * 0.04997500, iconSize.height * 0.04997500),
        rotation: 0,
        largeArc: true,
        clockwise: true);
    path_1.arcToPoint(Offset(iconSize.width * 0.2500000, iconSize.height * 0.5000000),
        radius: Radius.elliptical(iconSize.width * 0.04997500, iconSize.height * 0.04997500),
        rotation: 0,
        largeArc: true,
        clockwise: true);
    path_1.moveTo(iconSize.width * 0.8500000, iconSize.height * 0.5000000);
    path_1.arcToPoint(Offset(iconSize.width * 0.7500000, iconSize.height * 0.5000000),
        radius: Radius.elliptical(iconSize.width * 0.04997500, iconSize.height * 0.04997500),
        rotation: 0,
        largeArc: true,
        clockwise: true);
    path_1.arcToPoint(Offset(iconSize.width * 0.8500000, iconSize.height * 0.5000000),
        radius: Radius.elliptical(iconSize.width * 0.04997500, iconSize.height * 0.04997500),
        rotation: 0,
        largeArc: true,
        clockwise: true);

    Paint paint1Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint1Fill.color = const Color(0xffcc42cc).withOpacity(1);
    canvas.drawPath(path_1, paint1Fill);

    Path path_2 = Path();
    path_2.moveTo(iconSize.width * 0.7837000, iconSize.height * 0.5313500);
    path_2.lineTo(iconSize.width * 0.6372000, iconSize.height * 0.06747500);
    path_2.cubicTo(
        iconSize.width * 0.6338750,
        iconSize.height * 0.05712500,
        iconSize.width * 0.6242000,
        iconSize.height * 0.05000000,
        iconSize.width * 0.6133750,
        iconSize.height * 0.05000000);
    path_2.lineTo(iconSize.width * 0.5250000, iconSize.height * 0.05000000);
    path_2.lineTo(iconSize.width * 0.5250000, 0);
    path_2.lineTo(iconSize.width * 0.6133750, 0);
    path_2.arcToPoint(Offset(iconSize.width * 0.6849500, iconSize.height * 0.05255000),
        radius: Radius.elliptical(iconSize.width * 0.07462500, iconSize.height * 0.07462500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_2.lineTo(iconSize.width * 0.8315500, iconSize.height * 0.5164000);
    path_2.close();
    path_2.moveTo(iconSize.width * 0.8500000, iconSize.height * 0.2625000);
    path_2.lineTo(iconSize.width * 0.8500000, iconSize.height * 0.1375000);
    path_2.arcToPoint(Offset(iconSize.width * 0.7625000, iconSize.height * 0.1735250),
        radius: Radius.elliptical(iconSize.width * 0.1289000, iconSize.height * 0.1289000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_2.lineTo(iconSize.width * 0.7625000, iconSize.height * 0.2265000);
    path_2.arcToPoint(Offset(iconSize.width * 0.8500000, iconSize.height * 0.2625000),
        radius: Radius.elliptical(iconSize.width * 0.1289000, iconSize.height * 0.1289000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_2.moveTo(iconSize.width * 0.8750000, iconSize.height * 0.1375000);
    path_2.lineTo(iconSize.width * 0.9000000, iconSize.height * 0.1375000);
    path_2.lineTo(iconSize.width * 0.9000000, iconSize.height * 0.2625000);
    path_2.lineTo(iconSize.width * 0.8750000, iconSize.height * 0.2625000);
    path_2.close();
    path_2.moveTo(iconSize.width * 0.8750000, iconSize.height * 0.1375000);

    Paint paint2Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint2Fill.color = const Color(0xffcc42cc).withOpacity(1);
    canvas.drawPath(path_2, paint2Fill);

    Path path_3 = Path();
    path_3.moveTo(iconSize.width * 0.2447500, iconSize.height * 0.8328250);
    path_3.lineTo(iconSize.width * 0.2444250, iconSize.height * 0.8671750);
    path_3.arcToPoint(Offset(iconSize.width * 0.2379000, iconSize.height * 0.9551750),
        radius: Radius.elliptical(iconSize.width * 0.6619500, iconSize.height * 0.6619500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_3.arcToPoint(Offset(iconSize.width * 0.1942500, iconSize.height * 0.9905250),
        radius: Radius.elliptical(iconSize.width * 0.03950000, iconSize.height * 0.03950000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_3.arcToPoint(Offset(iconSize.width * 0.1526250, iconSize.height * 0.9872000),
        radius: Radius.elliptical(iconSize.width * 0.3495000, iconSize.height * 0.3495000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_3.lineTo(iconSize.width * 0.1503750, iconSize.height * 0.9511750);
    path_3.cubicTo(
        iconSize.width * 0.1617250,
        iconSize.height * 0.9534250,
        iconSize.width * 0.1732500,
        iconSize.height * 0.9546750,
        iconSize.width * 0.1848750,
        iconSize.height * 0.9549750);
    path_3.cubicTo(
        iconSize.width * 0.1994250,
        iconSize.height * 0.9549750,
        iconSize.width * 0.2010750,
        iconSize.height * 0.9509750,
        iconSize.width * 0.2033250,
        iconSize.height * 0.9408250);
    path_3.cubicTo(
        iconSize.width * 0.2060750,
        iconSize.height * 0.9200250,
        iconSize.width * 0.2078250,
        iconSize.height * 0.8990250,
        iconSize.width * 0.2085000,
        iconSize.height * 0.8780250);
    path_3.lineTo(iconSize.width * 0.2085000, iconSize.height * 0.8666000);
    path_3.lineTo(iconSize.width * 0.1588750, iconSize.height * 0.8666000);
    path_3.arcToPoint(Offset(iconSize.width * 0.07920000, iconSize.height * 0.9917000),
        radius: Radius.elliptical(iconSize.width * 0.1726250, iconSize.height * 0.1726250),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_3.lineTo(iconSize.width * 0.05362500, iconSize.height * 0.9655250);
    path_3.cubicTo(
        iconSize.width * 0.1058750,
        iconSize.height * 0.9305750,
        iconSize.width * 0.1150500,
        iconSize.height * 0.9041000,
        iconSize.width * 0.1220750,
        iconSize.height * 0.8665250);
    path_3.lineTo(iconSize.width * 0.06505000, iconSize.height * 0.8665250);
    path_3.lineTo(iconSize.width * 0.06505000, iconSize.height * 0.8328000);
    path_3.lineTo(iconSize.width * 0.1258750, iconSize.height * 0.8328000);
    path_3.cubicTo(
        iconSize.width * 0.1272500,
        iconSize.height * 0.8109500,
        iconSize.width * 0.1272500,
        iconSize.height * 0.8014750,
        iconSize.width * 0.1272500,
        iconSize.height * 0.7945500);
    path_3.lineTo(iconSize.width * 0.1657250, iconSize.height * 0.7947250);
    path_3.cubicTo(
        iconSize.width * 0.1650500,
        iconSize.height * 0.8048750,
        iconSize.width * 0.1645500,
        iconSize.height * 0.8154250,
        iconSize.width * 0.1631750,
        iconSize.height * 0.8328000);
    path_3.close();
    path_3.moveTo(iconSize.width * 0.2104500, iconSize.height * 0.8259750);
    path_3.arcToPoint(Offset(iconSize.width * 0.2021500, iconSize.height * 0.7900500),
        radius: Radius.elliptical(iconSize.width * 0.2395500, iconSize.height * 0.2395500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_3.lineTo(iconSize.width * 0.2219750, iconSize.height * 0.7871000);
    path_3.cubicTo(
        iconSize.width * 0.2260750,
        iconSize.height * 0.7986250,
        iconSize.width * 0.2292000,
        iconSize.height * 0.8104500,
        iconSize.width * 0.2314500,
        iconSize.height * 0.8224500);
    path_3.close();
    path_3.moveTo(iconSize.width * 0.2429500, iconSize.height * 0.8224750);
    path_3.arcToPoint(Offset(iconSize.width * 0.2335000, iconSize.height * 0.7881750),
        radius: Radius.elliptical(iconSize.width * 0.1980500, iconSize.height * 0.1980500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_3.lineTo(iconSize.width * 0.2535000, iconSize.height * 0.7852500);
    path_3.cubicTo(
        iconSize.width * 0.2576250,
        iconSize.height * 0.7962000,
        iconSize.width * 0.2607500,
        iconSize.height * 0.8074250,
        iconSize.width * 0.2630000,
        iconSize.height * 0.8188500);
    path_3.close();
    path_3.moveTo(iconSize.width * 0.2429500, iconSize.height * 0.8224750);

    Paint paint3Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint3Fill.color = const Color(0xffcc42cc).withOpacity(1);
    canvas.drawPath(path_3, paint3Fill);

    Path path_4 = Path();
    path_4.moveTo(iconSize.width * 0.3414000, iconSize.height * 0.8862500);
    path_4.arcToPoint(Offset(iconSize.width * 0.3002000, iconSize.height * 0.8232500),
        radius: Radius.elliptical(iconSize.width * 0.3738750, iconSize.height * 0.3738750),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_4.lineTo(iconSize.width * 0.3312500, iconSize.height * 0.8058500);
    path_4.arcToPoint(Offset(iconSize.width * 0.3754000, iconSize.height * 0.8653500),
        radius: Radius.elliptical(iconSize.width * 0.2892500, iconSize.height * 0.2892500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_4.close();
    path_4.moveTo(iconSize.width * 0.3177750, iconSize.height * 0.9578000);
    path_4.cubicTo(
        iconSize.width * 0.3666000,
        iconSize.height * 0.9453000,
        iconSize.width * 0.4287000,
        iconSize.height * 0.9252000,
        iconSize.width * 0.4496000,
        iconSize.height * 0.8013750);
    path_4.lineTo(iconSize.width * 0.4903500, iconSize.height * 0.8096750);
    path_4.cubicTo(
        iconSize.width * 0.4613500,
        iconSize.height * 0.9300750,
        iconSize.width * 0.4136750,
        iconSize.height * 0.9699250,
        iconSize.width * 0.3364250,
        iconSize.height * 0.9904250);
    path_4.close();
    path_4.moveTo(iconSize.width * 0.3177750, iconSize.height * 0.9578000);

    Paint paint4Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint4Fill.color = const Color(0xffcc42cc).withOpacity(1);
    canvas.drawPath(path_4, paint4Fill);

    Path path_5 = Path();
    path_5.moveTo(iconSize.width * 0.5837000, iconSize.height * 0.9244250);
    path_5.lineTo(iconSize.width * 0.5459000, iconSize.height * 0.9244250);
    path_5.lineTo(iconSize.width * 0.5459000, iconSize.height * 0.8007500);
    path_5.lineTo(iconSize.width * 0.5837000, iconSize.height * 0.8007500);
    path_5.close();
    path_5.moveTo(iconSize.width * 0.6923750, iconSize.height * 0.8901250);
    path_5.cubicTo(
        iconSize.width * 0.6923750,
        iconSize.height * 0.9723750,
        iconSize.width * 0.6309500,
        iconSize.height * 0.9856250,
        iconSize.width * 0.5708750,
        iconSize.height * 0.9923750);
    path_5.lineTo(iconSize.width * 0.5574250, iconSize.height * 0.9577250);
    path_5.cubicTo(
        iconSize.width * 0.6206000,
        iconSize.height * 0.9534250,
        iconSize.width * 0.6544000,
        iconSize.height * 0.9413000,
        iconSize.width * 0.6544000,
        iconSize.height * 0.8956000);
    path_5.lineTo(iconSize.width * 0.6544000, iconSize.height * 0.7970000);
    path_5.lineTo(iconSize.width * 0.6924000, iconSize.height * 0.7970000);
    path_5.close();
    path_5.moveTo(iconSize.width * 0.6923750, iconSize.height * 0.8901250);

    Paint paint5Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint5Fill.color = const Color(0xffcc42cc).withOpacity(1);
    canvas.drawPath(path_5, paint5Fill);

    Path path_6 = Path();
    path_6.moveTo(iconSize.width * 0.8204000, iconSize.height * 0.8701250);
    path_6.arcToPoint(Offset(iconSize.width * 0.7495000, iconSize.height * 0.8351500),
        radius: Radius.elliptical(iconSize.width * 0.2957500, iconSize.height * 0.2957500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_6.lineTo(iconSize.width * 0.7657250, iconSize.height * 0.8046000);
    path_6.cubicTo(
        iconSize.width * 0.7917000,
        iconSize.height * 0.8120000,
        iconSize.width * 0.8166000,
        iconSize.height * 0.8229500,
        iconSize.width * 0.8395500,
        iconSize.height * 0.8370000);
    path_6.close();
    path_6.moveTo(iconSize.width * 0.7527500, iconSize.height * 0.9505000);
    path_6.cubicTo(
        iconSize.width * 0.8402500,
        iconSize.height * 0.9435500,
        iconSize.width * 0.8863500,
        iconSize.height * 0.9102500,
        iconSize.width * 0.9120250,
        iconSize.height * 0.8195250);
    path_6.lineTo(iconSize.width * 0.9461250, iconSize.height * 0.8363250);
    path_6.cubicTo(
        iconSize.width * 0.9110500,
        iconSize.height * 0.9539000,
        iconSize.width * 0.8416250,
        iconSize.height * 0.9782250,
        iconSize.width * 0.7646750,
        iconSize.height * 0.9891500);
    path_6.close();
    path_6.moveTo(iconSize.width * 0.7527500, iconSize.height * 0.9505000);

    Paint paint6Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint6Fill.color = const Color(0xffcc42cc).withOpacity(1);
    canvas.drawPath(path_6, paint6Fill);
  }

  void _drawBicycle(Canvas canvas, bool isInside) {
    Path path_0 = Path();
    path_0.moveTo(iconSize.width * 0.8000000, iconSize.height * 0.4562500);
    path_0.cubicTo(
        iconSize.width * 0.7880000,
        iconSize.height * 0.4563500,
        iconSize.width * 0.7760000,
        iconSize.height * 0.4574250,
        iconSize.width * 0.7641500,
        iconSize.height * 0.4596750);
    path_0.lineTo(iconSize.width * 0.6738250, iconSize.height * 0.1737250);
    path_0.arcToPoint(Offset(iconSize.width * 0.6500000, iconSize.height * 0.1562500),
        radius: Radius.elliptical(iconSize.width * 0.02497500, iconSize.height * 0.02497500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.5500000, iconSize.height * 0.1562500);
    path_0.cubicTo(
        iconSize.width * 0.5362500,
        iconSize.height * 0.1562500,
        iconSize.width * 0.5250000,
        iconSize.height * 0.1675000,
        iconSize.width * 0.5250000,
        iconSize.height * 0.1812500);
    path_0.cubicTo(
        iconSize.width * 0.5250000,
        iconSize.height * 0.1950000,
        iconSize.width * 0.5362500,
        iconSize.height * 0.2062500,
        iconSize.width * 0.5500000,
        iconSize.height * 0.2062500);
    path_0.lineTo(iconSize.width * 0.6316500, iconSize.height * 0.2062500);
    path_0.lineTo(iconSize.width * 0.6830000, iconSize.height * 0.3687500);
    path_0.lineTo(iconSize.width * 0.3935500, iconSize.height * 0.3687500);
    path_0.lineTo(iconSize.width * 0.3791000, iconSize.height * 0.3371000);
    path_0.arcToPoint(Offset(iconSize.width * 0.3750000, iconSize.height * 0.2750000),
        radius: Radius.elliptical(iconSize.width * 0.03117500, iconSize.height * 0.03117500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.2750000, iconSize.height * 0.2750000);
    path_0.cubicTo(
        iconSize.width * 0.2577250,
        iconSize.height * 0.2750000,
        iconSize.width * 0.2437500,
        iconSize.height * 0.2889750,
        iconSize.width * 0.2437500,
        iconSize.height * 0.3062500);
    path_0.cubicTo(
        iconSize.width * 0.2437500,
        iconSize.height * 0.3235250,
        iconSize.width * 0.2577250,
        iconSize.height * 0.3375000,
        iconSize.width * 0.2750000,
        iconSize.height * 0.3375000);
    path_0.lineTo(iconSize.width * 0.3243250, iconSize.height * 0.3375000);
    path_0.lineTo(iconSize.width * 0.3489250, iconSize.height * 0.3912000);
    path_0.lineTo(iconSize.width * 0.2903250, iconSize.height * 0.4779500);
    path_0.arcToPoint(Offset(iconSize.width * 0.3982500, iconSize.height * 0.6812500),
        radius: Radius.elliptical(iconSize.width * 0.2000000, iconSize.height * 0.2000000),
        rotation: 0,
        largeArc: true,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.4569250, iconSize.height * 0.6812500);
    path_0.arcToPoint(Offset(iconSize.width * 0.5450250, iconSize.height * 0.6348750),
        radius: Radius.elliptical(iconSize.width * 0.04982500, iconSize.height * 0.04982500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.6881750, iconSize.height * 0.4187500);
    path_0.lineTo(iconSize.width * 0.6987250, iconSize.height * 0.4187500);
    path_0.lineTo(iconSize.width * 0.7165000, iconSize.height * 0.4748000);
    path_0.arcToPoint(Offset(iconSize.width * 0.6114250, iconSize.height * 0.7198250),
        radius: Radius.elliptical(iconSize.width * 0.1994500, iconSize.height * 0.1994500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.arcToPoint(Offset(iconSize.width * 0.8436750, iconSize.height * 0.8506750),
        radius: Radius.elliptical(iconSize.width * 0.1995000, iconSize.height * 0.1995000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.arcToPoint(Offset(iconSize.width * 0.8000000, iconSize.height * 0.4562500),
        radius: Radius.elliptical(iconSize.width * 0.1995500, iconSize.height * 0.1995500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.moveTo(iconSize.width * 0.3733500, iconSize.height * 0.4446250);
    path_0.lineTo(iconSize.width * 0.4579000, iconSize.height * 0.6296000);
    path_0.arcToPoint(Offset(iconSize.width * 0.4569250, iconSize.height * 0.6313500),
        radius: Radius.elliptical(iconSize.width * 0.01580000, iconSize.height * 0.01580000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.3982500, iconSize.height * 0.6313500);
    path_0.arcToPoint(Offset(iconSize.width * 0.3317500, iconSize.height * 0.5062500),
        radius: Radius.elliptical(iconSize.width * 0.1991500, iconSize.height * 0.1991500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.close();
    path_0.moveTo(iconSize.width * 0.3477500, iconSize.height * 0.6312500);
    path_0.lineTo(iconSize.width * 0.2470750, iconSize.height * 0.6312500);
    path_0.lineTo(iconSize.width * 0.3034250, iconSize.height * 0.5478500);
    path_0.arcToPoint(Offset(iconSize.width * 0.3477500, iconSize.height * 0.6312500),
        radius: Radius.elliptical(iconSize.width * 0.1496000, iconSize.height * 0.1496000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.moveTo(iconSize.width * 0.2000000, iconSize.height * 0.8062500);
    path_0.arcToPoint(Offset(iconSize.width * 0.06045000, iconSize.height * 0.7122000),
        radius: Radius.elliptical(iconSize.width * 0.1502000, iconSize.height * 0.1502000),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.arcToPoint(Offset(iconSize.width * 0.09610000, iconSize.height * 0.5477500),
        radius: Radius.elliptical(iconSize.width * 0.1501500, iconSize.height * 0.1501500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.arcToPoint(Offset(iconSize.width * 0.2621000, iconSize.height * 0.5198250),
        radius: Radius.elliptical(iconSize.width * 0.1501750, iconSize.height * 0.1501750),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.lineTo(iconSize.width * 0.1895500, iconSize.height * 0.6268500);
    path_0.cubicTo(
        iconSize.width * 0.1780500,
        iconSize.height * 0.6309500,
        iconSize.width * 0.1700250,
        iconSize.height * 0.6414000,
        iconSize.width * 0.1690500,
        iconSize.height * 0.6536000);
    path_0.cubicTo(
        iconSize.width * 0.1679750,
        iconSize.height * 0.6658250,
        iconSize.width * 0.1742250,
        iconSize.height * 0.6774500,
        iconSize.width * 0.1848750,
        iconSize.height * 0.6834000);
    path_0.cubicTo(
        iconSize.width * 0.1956250,
        iconSize.height * 0.6893500,
        iconSize.width * 0.2088000,
        iconSize.height * 0.6885750,
        iconSize.width * 0.2185500,
        iconSize.height * 0.6812500);
    path_0.lineTo(iconSize.width * 0.3477500, iconSize.height * 0.6812500);
    path_0.arcToPoint(Offset(iconSize.width * 0.2000000, iconSize.height * 0.8062500),
        radius: Radius.elliptical(iconSize.width * 0.1500750, iconSize.height * 0.1500750),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.moveTo(iconSize.width * 0.5038000, iconSize.height * 0.6066500);
    path_0.cubicTo(
        iconSize.width * 0.5033000,
        iconSize.height * 0.6066500,
        iconSize.width * 0.5028250,
        iconSize.height * 0.6066500,
        iconSize.width * 0.5023500,
        iconSize.height * 0.6064500);
    path_0.lineTo(iconSize.width * 0.4165000, iconSize.height * 0.4187500);
    path_0.lineTo(iconSize.width * 0.6283250, iconSize.height * 0.4187500);
    path_0.close();
    path_0.moveTo(iconSize.width * 0.8000000, iconSize.height * 0.8062500);
    path_0.arcToPoint(Offset(iconSize.width * 0.6545000, iconSize.height * 0.6914000),
        radius: Radius.elliptical(iconSize.width * 0.1499500, iconSize.height * 0.1499500),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.arcToPoint(Offset(iconSize.width * 0.7316500, iconSize.height * 0.5228500),
        radius: Radius.elliptical(iconSize.width * 0.1499750, iconSize.height * 0.1499750),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.lineTo(iconSize.width * 0.7706000, iconSize.height * 0.6461000);
    path_0.cubicTo(
        iconSize.width * 0.7694250,
        iconSize.height * 0.6493250,
        iconSize.width * 0.7687500,
        iconSize.height * 0.6528500,
        iconSize.width * 0.7687500,
        iconSize.height * 0.6562500);
    path_0.cubicTo(
        iconSize.width * 0.7686500,
        iconSize.height * 0.6710000,
        iconSize.width * 0.7790000,
        iconSize.height * 0.6838750,
        iconSize.width * 0.7934500,
        iconSize.height * 0.6869250);
    path_0.arcToPoint(Offset(iconSize.width * 0.8286250, iconSize.height * 0.6690500),
        radius: Radius.elliptical(iconSize.width * 0.03135000, iconSize.height * 0.03135000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.arcToPoint(Offset(iconSize.width * 0.8182500, iconSize.height * 0.6309500),
        radius: Radius.elliptical(iconSize.width * 0.03137500, iconSize.height * 0.03137500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.7793000, iconSize.height * 0.5078250);
    path_0.arcToPoint(Offset(iconSize.width * 0.9233500, iconSize.height * 0.5693250),
        radius: Radius.elliptical(iconSize.width * 0.1498250, iconSize.height * 0.1498250),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.arcToPoint(Offset(iconSize.width * 0.8000000, iconSize.height * 0.8062500),
        radius: Radius.elliptical(iconSize.width * 0.1500000, iconSize.height * 0.1500000),
        rotation: 0,
        largeArc: false,
        clockwise: true);

    Paint paint0Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint0Fill.color = const Color(0xff9960d2).withOpacity(1);
    canvas.drawPath(path_0, paint0Fill);
  }

  void _drawPlane(Canvas canvas, bool isInside) {
    Path path_0 = Path();
    path_0.moveTo(iconSize.width * 0.9809500, iconSize.height * 0.5673750);
    path_0.lineTo(iconSize.width * 0.7812500, iconSize.height * 0.4540000);
    path_0.lineTo(iconSize.width * 0.7812500, iconSize.height * 0.4187500);
    path_0.arcToPoint(Offset(iconSize.width * 0.7187500, iconSize.height * 0.4185500),
        radius: Radius.elliptical(iconSize.width * 0.03127500, iconSize.height * 0.03127500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.5754000, iconSize.height * 0.3373000);
    path_0.lineTo(iconSize.width * 0.5812500, iconSize.height * 0.08857500);
    path_0.lineTo(iconSize.width * 0.5812500, iconSize.height * 0.08750000);
    path_0.arcToPoint(Offset(iconSize.width * 0.5000000, 0),
        radius: Radius.elliptical(iconSize.width * 0.08482500, iconSize.height * 0.08482500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.arcToPoint(Offset(iconSize.width * 0.4187500, iconSize.height * 0.08750000),
        radius: Radius.elliptical(iconSize.width * 0.08482500, iconSize.height * 0.08482500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.4187500, iconSize.height * 0.08857500);
    path_0.lineTo(iconSize.width * 0.4245000, iconSize.height * 0.3372000);
    path_0.lineTo(iconSize.width * 0.2812500, iconSize.height * 0.4185500);
    path_0.arcToPoint(Offset(iconSize.width * 0.2499000, iconSize.height * 0.3874000),
        radius: Radius.elliptical(iconSize.width * 0.03122500, iconSize.height * 0.03122500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.cubicTo(
        iconSize.width * 0.2326250,
        iconSize.height * 0.3874000,
        iconSize.width * 0.2186500,
        iconSize.height * 0.4014750,
        iconSize.width * 0.2187500,
        iconSize.height * 0.4187500);
    path_0.lineTo(iconSize.width * 0.2187500, iconSize.height * 0.4540000);
    path_0.lineTo(iconSize.width * 0.01905000, iconSize.height * 0.5673750);
    path_0.arcToPoint(Offset(iconSize.width * 0.04180000, iconSize.height * 0.6372000),
        radius: Radius.elliptical(iconSize.width * 0.03742500, iconSize.height * 0.03742500),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.4304750, iconSize.height * 0.5931750);
    path_0.lineTo(iconSize.width * 0.4370000, iconSize.height * 0.8730500);
    path_0.lineTo(iconSize.width * 0.3166000, iconSize.height * 0.9332000);
    path_0.arcToPoint(Offset(iconSize.width * 0.3062500, iconSize.height * 0.9500000),
        radius: Radius.elliptical(iconSize.width * 0.01880000, iconSize.height * 0.01880000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.3062500, iconSize.height * 0.9812500);
    path_0.arcToPoint(Offset(iconSize.width * 0.3289000, iconSize.height * 0.9996000),
        radius: Radius.elliptical(iconSize.width * 0.01870000, iconSize.height * 0.01870000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.4634750, iconSize.height * 0.9708000);
    path_0.arcToPoint(Offset(iconSize.width * 0.5365250, iconSize.height * 0.9708000),
        radius: Radius.elliptical(iconSize.width * 0.03750000, iconSize.height * 0.03750000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.6711000, iconSize.height * 0.9996000);
    path_0.arcToPoint(Offset(iconSize.width * 0.6937500, iconSize.height * 0.9812500),
        radius: Radius.elliptical(iconSize.width * 0.01875000, iconSize.height * 0.01875000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.6937500, iconSize.height * 0.9500000);
    path_0.arcToPoint(Offset(iconSize.width * 0.6834000, iconSize.height * 0.9332000),
        radius: Radius.elliptical(iconSize.width * 0.01880000, iconSize.height * 0.01880000),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.lineTo(iconSize.width * 0.5630000, iconSize.height * 0.8730500);
    path_0.lineTo(iconSize.width * 0.5694250, iconSize.height * 0.5931750);
    path_0.lineTo(iconSize.width * 0.9582000, iconSize.height * 0.6373000);
    path_0.cubicTo(
        iconSize.width * 0.9596750,
        iconSize.height * 0.6374000,
        iconSize.width * 0.9610250,
        iconSize.height * 0.6375000,
        iconSize.width * 0.9625000,
        iconSize.height * 0.6375000);
    path_0.cubicTo(
        iconSize.width * 0.9795000,
        iconSize.height * 0.6375000,
        iconSize.width * 0.9944250,
        iconSize.height * 0.6260750,
        iconSize.width * 0.9987500,
        iconSize.height * 0.6095750);
    path_0.arcToPoint(Offset(iconSize.width * 0.9809500, iconSize.height * 0.5673750),
        radius: Radius.elliptical(iconSize.width * 0.03742500, iconSize.height * 0.03742500),
        rotation: 0,
        largeArc: false,
        clockwise: false);

    Paint paint0Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    if (!isInside) paint0Fill.color = const Color(0xfff59433).withOpacity(1);
    canvas.drawPath(path_0, paint0Fill);
  }
}

class Pie {
  final IconType iconType;
  final double percent;

  Pie(this.iconType, this.percent);
}

enum IconType { train, plane, ev, bicycle, walking, taxi, motocycle, bus, automobile }
