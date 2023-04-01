import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  final gameAreaKey = GlobalKey<_GameAreaState>();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return GameArea(
                    key: gameAreaKey,
                    maxWidth: constraints.maxWidth,
                    maxHeight: (constraints.maxHeight ~/ width) * width - width,
                  );
                },
              ),
            ),
            ControllerArea(
              onTapDown: (SnakeDirection snakeDirection, bool isVertical) =>
                  gameAreaKey.currentState?.onTapDown(snakeDirection, isVertical),
              onLongPress: (SnakeDirection snakeDirection) =>
                  gameAreaKey.currentState?.onLongPress(snakeDirection),
              onLongPressEnd: () => gameAreaKey.currentState?._runNormalSpeed(),
            )
          ],
        ),
        backgroundColor: Colors.black,
      ),
    );
  }
}

enum SnakeDirection { upward, downward, forward, back }

class ControlButton extends StatelessWidget {
  const ControlButton({
    super.key,
    required this.icon,
    required this.onTapDown,
    required this.onLongPress,
    required this.onLongPressEnd,
  });

  final IconData icon;
  final VoidCallback onTapDown;
  final VoidCallback onLongPress;
  final VoidCallback onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onLongPress: onLongPress,
      onLongPressEnd: (_) => onLongPressEnd(),
      child: Container(
        padding: const EdgeInsets.all(36),
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        child: Icon(icon),
      ),
    );
  }
}

class ControllerArea extends StatelessWidget {
  const ControllerArea({
    super.key,
    required this.onTapDown,
    required this.onLongPress,
    required this.onLongPressEnd,
  });

  final void Function(SnakeDirection snakeDirection, bool isVertical) onTapDown;
  final void Function(SnakeDirection snakeDirection) onLongPress;
  final VoidCallback onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ControlButton(
            icon: Icons.arrow_back,
            onTapDown: () {
              onTapDown(SnakeDirection.back, false);
            },
            onLongPress: () {
              onLongPress(SnakeDirection.back);
            },
            onLongPressEnd: onLongPressEnd,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ControlButton(
                icon: Icons.arrow_upward,
                onTapDown: () {
                  onTapDown(SnakeDirection.upward, true);
                },
                onLongPress: () {
                  onLongPress(SnakeDirection.upward);
                },
                onLongPressEnd: onLongPressEnd,
              ),
              const SizedBox(
                height: 40,
              ),
              ControlButton(
                icon: Icons.arrow_downward,
                onTapDown: () {
                  onTapDown(SnakeDirection.downward, true);
                },
                onLongPress: () {
                  onLongPress(SnakeDirection.downward);
                },
                onLongPressEnd: onLongPressEnd,
              ),
            ],
          ),
          ControlButton(
            icon: Icons.arrow_forward,
            onTapDown: () {
              onTapDown(SnakeDirection.forward, false);
            },
            onLongPress: () {
              onLongPress(SnakeDirection.forward);
            },
            onLongPressEnd: onLongPressEnd,
          ),
        ],
      ),
    );
  }
}

class GameArea extends StatefulWidget {
  const GameArea({Key? key, required this.maxWidth, required this.maxHeight}) : super(key: key);

  final double maxWidth;
  final double maxHeight;

  @override
  State<GameArea> createState() => _GameAreaState();
}

class _GameAreaState extends State<GameArea> {
  // ta chỉ cần lưu vị trí top-left của từng khối thịt là có thể vẽ được con rắn rồi
  List<Offset> points = [];
  SnakeDirection snakeDirection = SnakeDirection.forward;
  Timer? timer;
  late Offset box;
  int velocity = normalSpeed;
  int score = 0;
  bool isDead = false;
  List<Offset> wall = [];

  @override
  void initState() {
    _setup();
    _tick();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        width: widget.maxWidth,
        height: widget.maxHeight + width,
        color: Colors.green,
        child: Stack(
          children: [
            _getScore(),
            _getWall(),
            _getSnack(),
            _getBox(),
            if (isDead) _getGameOverScreen()
          ],
        ),
      ),
    );
  }

  Widget _getScore() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.topRight,
        child: Text(
          '$score',
          style: const TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
    );
  }

  Widget _getWall() {
    return CustomPaint(
      painter: WallPainter(wall: wall),
    );
  }

  Widget _getSnack() {
    return CustomPaint(
      painter: SnakePainter(points: points),
      size: Size.infinite,
    );
  }

  Widget _getBox() {
    return Positioned(
      left: box.dx,
      top: box.dy,
      child: Container(
        color: Colors.blue,
        width: width,
        height: width,
      ),
    );
  }

  Widget _getGameOverScreen() {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'NGU',
              style: TextStyle(color: Colors.white),
            ),
            ElevatedButton(
                onPressed: _restartGame,
                child: const Text(
                  'Play again',
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
      ),
    );
  }

  void _die() {
    setState(() {
      isDead = true;
    });
    _pause();
  }

  void _restartGame() {
    setState(() {
      isDead = false;
    });
    _setup();
    _tick();
  }

  void _runHighSpeed() {
    velocity = highSpeed;
    _tick();
  }

  void _runNormalSpeed() {
    velocity = normalSpeed;
    _tick();
  }

  void onLongPress(SnakeDirection snakeDirection) {
    if (this.snakeDirection != snakeDirection) return;
    _runHighSpeed();
  }

  void onTapDown(SnakeDirection snakeDirection, bool isVertical) {
    if (((this.snakeDirection == SnakeDirection.upward ||
                this.snakeDirection == SnakeDirection.downward) &&
            isVertical) ||
        ((this.snakeDirection == SnakeDirection.forward ||
                this.snakeDirection == SnakeDirection.back) &&
            !isVertical)) return;
    this.snakeDirection = snakeDirection;
    _move();
  }

  void _generateRandomBox() {
    box = Offset(
      width * Random().nextInt(widget.maxWidth ~/ width),
      width * Random().nextInt(widget.maxHeight ~/ width),
    );
    while (wall.contains(box)) {
      box = Offset(
        width * Random().nextInt(widget.maxWidth ~/ width),
        width * Random().nextInt(widget.maxHeight ~/ width),
      );
    }
  }

  void _setup() {
    points = List.generate(numberCell, (index) => Offset(100 + index * width, 100));
    snakeDirection = SnakeDirection.forward;
    score = 0;
    wall = buildWall(const Offset(20, 200), minh);

    _generateRandomBox();
  }

  @override
  void dispose() {
    _pause();
    super.dispose();
  }

  void _move() {
    setState(() {
      switch (snakeDirection) {
        case SnakeDirection.forward:
          _forward();
          break;
        case SnakeDirection.upward:
          _upward();
          break;
        case SnakeDirection.downward:
          _downward();
          break;
        default:
          _back();
          break;
      }

      // points.last là cái đầu con rắn
      // nếu bức tường wall contains cái đầu con rắn là die
      // hoặc nếu cái đuôi "points.sublist(0, points.length - 2)" của con rắn contains cái đầu con rắn thì cũng die
      if (points.sublist(0, points.length - 2).contains(points.last) ||
          wall.contains(points.last)) {
        _die();
      }
    });
  }

  void _tick() {
    _pause();
    timer = Timer.periodic(Duration(milliseconds: timerDuration ~/ velocity), (_) => _move());
  }

  void _upward() {
    for (int i = 0; i < points.length; i++) {
      if (i == points.length - 1) {
        points[i] = points[i] - const Offset(0, width);
        if (points[i].dy < 0) {
          points[i] = Offset(points[i].dx, (widget.maxHeight ~/ width) * width);
        }

        if (points[i] == box) {
          _eat();
          break;
        }
      } else {
        points[i] = points[i + 1];
      }
    }
  }

  void _downward() {
    for (int i = 0; i < points.length; i++) {
      if (i == points.length - 1) {
        points[i] = points[i] + const Offset(0, width);
        if (points[i].dy > widget.maxHeight) {
          points[i] = Offset(points[i].dx, 0);
        }

        if (points[i] == box) {
          _eat();
          break;
        }
      } else {
        points[i] = points[i + 1];
      }
    }
  }

  void _forward() {
    // loop qua từng khối thịt của con rắn
    for (int i = 0; i < points.length; i++) {
      if (i == points.length - 1) {
        // cái đầu con rắn sẽ tịnh tiến thêm 1 đoạn (width, 0)
        points[i] = points[i] + const Offset(width, 0);

        // nếu sau khi tịnh tiến mà quá maxWidth (góc phải màn hình) thì cho nó xuất hiện lại vị trí góc trái màn hình
        if (points[i].dx > widget.maxWidth) {
          points[i] = Offset(0, points[i].dy);
        }

        // nếu cái đầu của nó chạm vào cục thịt thì cho nó ăn thịt
        if (points[i] == box) {
          _eat();
          break;
        }
      } else {
        // khối thịt sau = khối thịt liền trước nó
        points[i] = points[i + 1];
      }
    }
  }

  void _back() {
    for (int i = 0; i < points.length; i++) {
      if (i == points.length - 1) {
        points[i] = points[i] - const Offset(width, 0);
        if (points[i].dx < 0) {
          points[i] = Offset((widget.maxWidth ~/ width) * width, points[i].dy);
        }

        if (points[i] == box) {
          _eat();
          break;
        }
      } else {
        points[i] = points[i + 1];
      }
    }
  }

  void _eat() {
    // cập nhật lại điểm số
    score += 10;

    // khi ăn, đơn giản là ta insert 1 khối thịt (Offset) cho nó tại vị trí 0 (vị trí đuôi)
    switch (snakeDirection) {
      case SnakeDirection.forward:
        // toạ độ vị trí đuôi là points.first.dx, trừ bớt width để tạo ra khối thịt mới ở sau vị trí đuôi
        points.insert(0, Offset(points.first.dx - width, points.first.dy));
        break;
      case SnakeDirection.upward:
        points.insert(0, Offset(points.first.dx, points.first.dy - width));
        break;
      case SnakeDirection.downward:
        points.insert(0, Offset(points.first.dx, points.first.dy + width));
        break;
      default:
        points.insert(0, Offset(points.first.dx + width, points.first.dy));
        break;
    }

    // ăn xong thì tạo cục khác
    _generateRandomBox();
  }

  void _pause() {
    timer?.cancel();
  }
}

class SnakePainter extends CustomPainter {
  SnakePainter({required this.points});

  List<Offset> points;
  final Paint paintObject = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    paintObject.color = Colors.white;
    paintObject.style = PaintingStyle.fill;

    if (points.length <= 1) {
      return;
    }

    // move đến vị trí đuôi con rắn và nối từng khúc thịt của nó bằng hàm addRRect
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      path.addRRect(_getSnakeCell(points[i]));
    }

    canvas.drawPath(path, paintObject);

    // cái đầu của nó thì vẽ màu đỏ
    canvas.drawRRect(_getSnakeCell(points.last), paintObject..color = Colors.red);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  RRect _getSnakeCell(Offset point) {
    return RRect.fromLTRBR(
        point.dx, point.dy, point.dx + width, point.dy + width, const Radius.circular(width / 2.5));
  }
}

class WallPainter extends CustomPainter {
  WallPainter({required this.wall});

  final List<Offset> wall;

  @override
  void paint(Canvas canvas, Size size) {
    for (final point in wall) {
      canvas.drawRect(
          Rect.fromLTRB(point.dx, point.dy, point.dx + width, point.dy + width),
          Paint()
            ..color = Colors.black
            ..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// cách vẽ 1 vật phức tạp từ những khối nhỏ đơn giản là mình sẽ giả sử mỗi khối nhỏ là 1 dấu *
// sau đó mình loop qua list này, ứng với dấu * sẽ vẽ 1 hình đơn giản
// bằng cách này mình sẽ vẽ được chữ "Minh" bằng cách khối vuông
// Khi làm game xếp hình cũng có thể dùng cách này để vẽ các khối hình
const minh = [
  ['*', '', '', '', '*', '', '*', '', '*', '', '', '*', '', '*', '', '', '*'],
  ['*', '*', '', '*', '*', '', '*', '', '*', '*', '', '*', '', '*', '*', '*', '*'],
  ['*', '', '*', '', '*', '', '*', '', '*', '', '*', '*', '', '*', '', '', '*'],
  ['*', '', '', '', '*', '', '*', '', '*', '', '', '*', '', '*', '', '', '*'],
];

List<Offset> buildWall(Offset start, List<List<String>> wallText) {
  final wall = <Offset>[];
  for (int i = 0; i < wallText.length; i++) {
    for (int j = 0; j < wallText[i].length; j++) {
      if (wallText[i][j].isNotEmpty) {
        final point = Offset((j + 1) * width, (i) * width) + start;
        wall.add(point);
      }
    }
  }

  return wall;
}

const width = 20.0;
const timerDuration = 100;
const normalSpeed = 1;
const highSpeed = 10;
const numberCell = 5;
