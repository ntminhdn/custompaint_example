import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'fruit.dart';
import 'fruit_part.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: CanvasArea(),
      ),
    ),
  );
}

const swordLength = 16;

class SlicePainter extends CustomPainter {
  SlicePainter({required this.pointsList});

  List<Offset> pointsList;
  final Paint paintObject = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    _drawPath(canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  void _drawPath(Canvas canvas) {
    Path path = Path();
    paintObject.color = Colors.white;
    paintObject.strokeWidth = 3;
    paintObject.style = PaintingStyle.fill;

    if (pointsList.length < 2) {
      return;
    }

    paintObject.style = PaintingStyle.stroke;

    path.moveTo(pointsList[0].dx, pointsList[0].dy);

    for (int i = 1; i < pointsList.length - 1; i++) {
      path.lineTo(pointsList[i].dx, pointsList[i].dy);
    }

    canvas.drawPath(path, paintObject);
  }
}

class CanvasArea extends StatefulWidget {
  const CanvasArea({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CanvasAreaState();
  }
}

class _CanvasAreaState extends State<CanvasArea> {
  List<Offset> sword = [];
  List<Fruit> fruits = [];
  List<FruitPart> fruitParts = [];

  @override
  void initState() {
    Timer.periodic(const Duration(milliseconds: 30), (t) => _tick());
    super.initState();
  }

  void _addRandomFruit() {
    fruits.add(
      Fruit(
        position: const Offset(0, 200),
        additionalForce: Offset(5 + Random().nextDouble() * 5, Random().nextDouble() * -10),
      ),
    );
  }

  void _tick() {
    setState(() {
      // cho fruit và fruit part rơi xuống
      for (Fruit fruit in fruits) {
        fruit.applyGravity();
      }
      for (FruitPart fruitPart in fruitParts) {
        fruitPart.applyGravity();
      }

      // random đẻ ra 1 fruit mới
      if (Random().nextDouble() > 0.97) {
        _addRandomFruit();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _getStack(),
    );
  }

  List<Widget> _getStack() {
    List<Widget> widgetOnStack = [];
    widgetOnStack.add(_getSlice());
    widgetOnStack.add(_getGestureDetector());
    widgetOnStack.addAll(_getFruitParts());
    widgetOnStack.addAll(_getFruits());

    return widgetOnStack;
  }

  List<Widget> _getFruitParts() {
    List<Widget> list = [];
    for (FruitPart fruitPart in fruitParts) {
      list.add(Positioned(
          top: fruitPart.position.dy,
          left: fruitPart.position.dx,
          child: Image.asset(
              fruitPart.isLeft ? 'assets/melon_cut.png' : 'assets/melon_cut_right.png',
              height: 80,
              fit: BoxFit.fitHeight)));
    }
    return list;
  }

  List<Widget> _getFruits() {
    List<Widget> list = [];
    for (Fruit fruit in fruits) {
      list.add(
        Positioned(
          top: fruit.position.dy,
          left: fruit.position.dx,
          child: Image.asset('assets/melon_uncut.png', height: 80, fit: BoxFit.fitHeight),
        ),
      );
    }

    return list;
  }

  Widget _getSlice() {
    return CustomPaint(
        size: Size.infinite,
        painter: SlicePainter(
          pointsList: sword,
        ));
  }

  // dùng GestureDetector để vẽ kiếm
  // khi add thêm điểm mới thì xoá bớt mấy điểm đầu để giới hạn chiều dài của kiếm
  GestureDetector _getGestureDetector() {
    return GestureDetector(onScaleStart: (details) {
      setState(() {
        // move đến điểm đầu tiên touch
        _setNewSlice(details);
      });
    }, onScaleUpdate: (details) {
      setState(() {
        // xoá bớt mấy điểm đầu của list để đảm bảo kiếm chỉ dài 16 points
        _addPointToSlice(details);
        _checkCollision();
      });
    }, onScaleEnd: (details) {
      setState(() {
        // xoá points - ẩn kiếm đi
        _resetSlice();
      });
    });
  }

  void _setNewSlice(details) {
    sword = [details.localFocalPoint];
  }

  void _addPointToSlice(ScaleUpdateDetails details) {
    if (sword.length > swordLength) {
      sword.removeAt(0);
    }

    sword.add(details.localFocalPoint);
  }

  void _resetSlice() {
    sword.clear();
  }

  void _checkCollision() {
    if (sword.isEmpty) {
      return;
    }

    // loop qua hết fruit, xem có point nào thuộc sword inside fruit ko
    for (Fruit fruit in List.of(fruits)) {
      for (Offset point in sword) {
        // nếu ko va chạm, continue
        if (!fruit.isPointInside(point)) {
          continue;
        }

        // nếu có va chạm, thì chém nó ra làm đôi
        _turnFruitIntoParts(fruit);
        break;
      }
    }
  }

  void _turnFruitIntoParts(Fruit fruit) {
    FruitPart leftFruitPart = FruitPart(
      position: Offset(fruit.position.dx, fruit.position.dy), // nửa quả đầu ở vị trí fruit
      isLeft: true,
      gravitySpeed: fruit.gravitySpeed, // tung độ = fruit lúc chưa bị cắt
      additionalForce:
          Offset(fruit.additionalForce.dx - 1, fruit.additionalForce.dy), // rơi sang trái 1 tí
    );

    FruitPart rightFruitPart = FruitPart(
      position: Offset(
          fruit.position.dx + fruit.width / 2, fruit.position.dy), // nửa quả sau ở vị trí w/2
      isLeft: false,
      gravitySpeed: fruit.gravitySpeed, // tung độ = fruit lúc chưa bị cắt
      additionalForce:
          Offset(fruit.additionalForce.dx + 1, fruit.additionalForce.dy), // rơi sang phải 1 tí
    );

    // tạo ra 2 fruit part và xoá đi fruit đó
    setState(() {
      fruitParts.add(leftFruitPart);
      fruitParts.add(rightFruitPart);
      fruits.remove(fruit);
    });
  }
}
