import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';

import 'paint_data.dart';

class PaintController extends ChangeNotifier {
  PaintController() : super();

  late Paint _currentPaint;

  // khi sử dụng BlendMode thì có 2 khái niệm cần phân biệt là source và destinations
  // khi vẽ bằng paint này thì nó là source, các paint còn lại là destinations
  // Một vài blendMode phổ biến như:
  // 1. BlendMode.clear: xoá cả source và destinations
  // 2. BlendMode.srcOver (default): vẽ đè source lên destinations (ko xoá destination)
  // 3. BlendMode.src: vẽ source và xoá tất cả destinations
  // 4. BlendMode.dstOver: vẽ source nằm dưới cùng, để các destinations đè lên
  // 5. BlendMode.dst: xoá source và giữ lại tất cả destinations
  // Xem tất cả BlendMode kèm ví dụ minh hoạ tại đây: https://api.flutter.dev/flutter/dart-ui/BlendMode.html#clear
  final Paint _eraserPaint = Paint()
    ..strokeWidth = 20
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..blendMode = BlendMode.clear;

  Color _currentColor = Colors.red;
  double _currentStrokeWidth = 5;

  final List<List<PaintData>> _brushPaths = [[]];
  final List<List<Path>> _eraserPaths = [[]];

  bool _inDrag = false;
  bool _isEraserMode = false;

  void initPaint(Color brushColor, double brushStrokeWidth) {
    _currentColor = brushColor;
    _currentStrokeWidth = brushStrokeWidth;
    _currentPaint = _createPaint(brushColor, brushStrokeWidth);
  }

  set paintColor(Color color) {
    _currentColor = color;
    _currentPaint = _createPaint(color, _currentStrokeWidth);
  }

  set paintStrokeWidth(double strokeWidth) {
    _currentStrokeWidth = strokeWidth;
    _currentPaint = _createPaint(_currentColor, strokeWidth);
  }

  set eraserMode(bool value) {
    if (_isEraserMode && !value) {
      _brushPaths.add([]);
      _eraserPaths.add([]);
    }

    _isEraserMode = value;
  }

  void clear() {
    if (!_inDrag) {
      _brushPaths
        ..clear()
        ..add([]);
      _eraserPaths
        ..clear()
        ..add([]);
      notifyListeners();
    }
  }

  void startPainting(Offset startPoint) {
    if (!_inDrag) {
      _inDrag = true;
      final path = Path()..moveTo(startPoint.dx, startPoint.dy);
      if (_isEraserMode) {
        _eraserPaths.last.add(path);
      } else {
        _brushPaths.last.add(PaintData(path, _currentPaint));
      }
      notifyListeners();
    }
  }

  void updatePainting(Offset nextPoint) {
    if (_inDrag) {
      if (_isEraserMode) {
        _eraserPaths.last.last.lineTo(nextPoint.dx, nextPoint.dy);
      } else {
        _brushPaths.last.last.path.lineTo(nextPoint.dx, nextPoint.dy);
      }
      notifyListeners();
    }
  }

  void endPainting() {
    _inDrag = false;
  }

  void draw(Canvas canvas, Size size) {
    // Để sử dụng hiệu ứng BlendMode, tức là compose nhiều nét vẽ lên nhau
    // ta cần gọi hàm saveLayer sau đó gọi làm restore
    // Hàm saveLayer cần truyền vào Rect tức là kích thước của layer mới
    // Trường hợp này mình muốn layer mới có size = size của canvas nên truyền Rect như dưới đây
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    for (var i = 0; i < _brushPaths.length; i++) {
      // vẽ nét màu
      for (final data in _brushPaths[i]) {
        canvas.drawPath(data.path, data.paint);
      }

      // vẽ nét trong suốt đè lên (tức là xoá nét màu ở trên)
      for (final data in _eraserPaths[i]) {
        canvas.drawPath(data, _eraserPaint);
      }
    }

    // hỏi ngu: tại sao ko dùng 1 List<Path> để lưu path như code dưới đây mà phải dùng nested List
    // final brs = _brushPaths.flatten();
    // final ers = _eraserPaths.flatten();
    // for (final data in brs) {
    //   canvas.drawPath(data.path, data.paint);
    // }
    // for (final data in ers) {
    //   canvas.drawPath(data, _eraserPaint);
    // }

    // khi gọi hàm restore thì 2 layer sẽ nhập thành 1 và hiệu ứng BlendMode sẽ được apply
    canvas.restore();
  }

  Paint _createPaint(Color color, double strokeWidth) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..color = color;
}
