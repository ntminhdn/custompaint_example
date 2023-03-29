import 'package:flutter/material.dart';

import 'map_utils.dart';
import 'paint_data.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('11. World Map'),
        ),
        body: const Center(
          child: WorldMapWidget(),
        ),
      ),
    ),
  );
}

class WorldMapWidget extends StatelessWidget {
  const WorldMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => CustomPaint(
        painter: MapPainter(loadMap()),
        size: constraints.biggest, // to nhất có thể
      ),
    );
  }
}

class MapPainter extends CustomPainter {
  final List<PaintData> paints;

  MapPainter(this.paints);

  @override
  void paint(Canvas canvas, Size size) {
    const ratio = worldMapWidth / worldMapHeight;
    final canvasWidth = size.width;
    final canvasHeight = size.height;

    // Tiếp theo, ta sẽ tính size phù hợp cho widget, liệu widget này phù hợp fitWidth hay fitHeight?
    // vì có 1 số case khi để portrait có thể nó fitWidth, nhưng khi để landscape nó lại fitHeight nên mình phải code cho nó flexible
    // Ban đầu, chúng ta cứ để widget này fitWidth thử xem
    // Để code 1 widget fitWidth, ta gán widgetWidth = canvasWidth (full width) và scale widthHeight theo ratio để widget của chúng ta có tỷ lệ w/h = với của svg
    var widgetWidth = canvasWidth;
    var widgetHeight = canvasWidth / ratio; // scale widgetHeight theo ratio

    print('svgSize: $worldMapWidth, $worldMapHeight, ratio = ${widgetWidth/widgetHeight}');
    print('canvasSize thực tế: $canvasWidth, $canvasHeight, ratio = ${canvasWidth/canvasHeight}');
    print('widgetSize mong muốn: $widgetWidth, $widgetHeight, ratio = ${widgetWidth/widgetHeight}');

    // Tuy nhiên, nếu sau khi scale Height mà widget Height vượt quá canvas Height thì ko ổn
    // khi đó, ta phải chuyển sang fitHeight, ko thể fitWidth được
    // tức là ta lại gán widgetHeight = canvasHeight và scale widgetWidth theo ratio
    if (widgetHeight > canvasHeight) {
      print('fitHeight');
      widgetHeight = canvasHeight;
      widgetWidth = widgetHeight * ratio; // scale widgetWidth theo ratio
    }

    canvas.save();

    // 1 công thức rất hay để dịch chuyển 1 widget vào chính giữa canvas
    canvas.translate((canvasWidth - widgetWidth) / 2, (canvasHeight - widgetHeight) / 2);

    // tương tự như bản đồ VN, mình cũng cần scale theo tỷ lệ widgetSize / svgSize
    canvas.scale(widgetWidth / worldMapWidth, widgetHeight / worldMapHeight);

    // loop qua từng Path của từng quốc gia một và vẽ thôi
    for (final element in paints) {
      canvas.drawPath(element.path, element.paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
