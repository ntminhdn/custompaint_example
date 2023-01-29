import 'dart:math';

import 'package:flutter/material.dart';
import 'package:svg_path_parser/svg_path_parser.dart';

extension NumExt on num {
  double toRadian() {
    return this * pi / 180;
  }
}

extension ListExt<T> on List<T> {
  T? elementAtOrNull(int index) {
    if (index < 0) return null;
    if (index >= length) return null;
    return this[index];
  }

  List<T> sorted(int Function(T a, T b)? compare) {
    return List.of(this)..sort(compare);
  }
}

extension CanvasExt on Canvas {
  void drawText(String text, TextStyle textStyle, double x, double y, TextAlignment alignment) {
    final span = TextSpan(
      style: textStyle,
      text: text,
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    double textX = 0;
    double textY = 0;
    switch (alignment) {
      case TextAlignment.topLeft:
        textX = 0;
        textY = 0;
        break;
      case TextAlignment.topRight:
        textX = tp.width;
        textY = 0;
        break;
      case TextAlignment.topCenter:
        textX = tp.width / 2;
        textY = 0;
        break;
      case TextAlignment.bottomLeft:
        textX = 0;
        textY = tp.height;
        break;
      case TextAlignment.bottomRight:
        textX = tp.width;
        textY = tp.height;
        break;
      case TextAlignment.bottomCenter:
        textX = tp.width / 2;
        textY = tp.height;
        break;
      case TextAlignment.centerLeft:
        textX = 0;
        textY = tp.height / 2;
        break;
      case TextAlignment.centerRight:
        textX = tp.width;
        textY = tp.height / 2;
        break;
      case TextAlignment.center:
        textX = tp.width / 2;
        textY = tp.height / 2;
        break;
    }
    tp.paint(this, Offset(x - textX, y - textY));
  }
}

Color generateRandomColor() {
  final Random random = Random();
  return Color.fromRGBO(random.nextInt(255), random.nextInt(255), random.nextInt(255), 1);
}

Path parsePathDataToPath(String pathData) {
  return parseSvgPath(pathData);
}

enum TextAlignment {
  topLeft,
  topRight,
  centerLeft,
  centerRight,
  bottomLeft,
  bottomRight,
  center,
  topCenter,
  bottomCenter,
}

// Hàm xác định một điểm thuộc đường cong bậc 2 tại vị trí `t` nào đó
Offset getOffsetOfCubicAt(double t, Offset start, Offset control1, Offset control2, Offset end) {
  return start * pow(1 - t, 3).toDouble() +
      control1 * 3 * pow(1 - t, 2).toDouble() * t +
      control2 * 3 * (1 - t) * pow(t, 2).toDouble() +
      end * pow(t, 3).toDouble();
}

// Hàm xác định một điểm thuộc đường cong bậc 3 tại vị trí `t` nào đó
Offset getOffsetOfQuadraticAt(double t, Offset start, Offset control, Offset end) {
  return start * pow((1 - t), 2).toDouble() +
      control * 2 * t * (1 - t) +
      end * pow(t, 2).toDouble();
}

// hàm xác định điểm control của đường cong bậc 2
Offset getControlPointOfQuadratic(double t, Offset pointAtT, Offset start, Offset end) {
  return (pointAtT - start * pow((1 - t), 2).toDouble() - end * pow(t, 2).toDouble()) /
      (2 * t * (1 - t));
}

// hàm xác định điểm control của đường cong bậc 3
List<Offset> getControlPointsOfCubic(
    double t1, Offset pointAtT1, double t2, Offset pointAtT2, Offset start, Offset end) {
  final a1 = 3 * t1 * pow(1 - t1, 2);
  final a2 = 3 * t2 * pow(1 - t2, 2);
  final b1 = 3 * pow(t1, 2) * (1 - t1);
  final b2 = 3 * pow(t2, 2) * (1 - t2);
  final c1 = pointAtT1 - start * pow(1 - t1, 3).toDouble() - end * pow(t1, 3).toDouble();
  final c2 = pointAtT2 - start * pow(1 - t2, 3).toDouble() - end * pow(t2, 3).toDouble();

  final d = (a1 * b2) - (a2 * b1);
  final dx = (c1 * b2) - (c2 * b1);
  final dy = (c2 * a1) - (c1 * a2);

  return [dx / d, dy / d];
}

Offset interpolate(
  Offset offset,
  double widgetWidth,
  double widgetHeight,
  double imageWidth,
  double imageHeight,
) {
  return Offset(offset.dx * widgetWidth / imageWidth, offset.dy * widgetHeight / imageHeight);
}
