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
  void flipHorizontally(Size canvasSize) {
    scale(-1, 1);
    translate(-canvasSize.width, 0);
  }

  void flipVertically(Size canvasSize) {
    scale(1, -1);
    translate(0, -canvasSize.height);
  }

  void drawText({
    required String text,
    required TextStyle textStyle,
    required double x,
    required double y,
    required TextAlignment alignment,
  }) {
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
  return Color.fromRGBO(
      random.nextInt(255), random.nextInt(255), random.nextInt(255), 1);
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
Offset getOffsetOfCubicAt({
  required double t,
  required Offset start,
  required Offset control1,
  required Offset control2,
  required Offset end,
}) {
  return start * pow(1 - t, 3).toDouble() +
      control1 * 3 * pow(1 - t, 2).toDouble() * t +
      control2 * 3 * (1 - t) * pow(t, 2).toDouble() +
      end * pow(t, 3).toDouble();
}

// Hàm xác định một điểm thuộc đường cong bậc 3 tại vị trí `t` nào đó
Offset getOffsetOfQuadraticAt({
  required double t,
  required Offset start,
  required Offset control,
  required Offset end,
}) {
  return start * pow((1 - t), 2).toDouble() +
      control * 2 * t * (1 - t) +
      end * pow(t, 2).toDouble();
}

// hàm xác định điểm control của đường cong bậc 2
Offset getControlPointOfQuadratic({
  required double t,
  required Offset pointAtT,
  required Offset startPoint,
  required Offset endPoint,
}) {
  return (pointAtT -
          startPoint * pow((1 - t), 2).toDouble() -
          endPoint * pow(t, 2).toDouble()) /
      (2 * t * (1 - t));
}

// hàm xác định điểm control của đường cong bậc 3
List<Offset> getControlPointsOfCubic({
  required double t1,
  required Offset pointAtT1,
  required double t2,
  required Offset pointAtT2,
  required Offset startPoint,
  required Offset endPoint,
}) {
  final a1 = 3 * t1 * pow(1 - t1, 2);
  final a2 = 3 * t2 * pow(1 - t2, 2);
  final b1 = 3 * pow(t1, 2) * (1 - t1);
  final b2 = 3 * pow(t2, 2) * (1 - t2);
  final c1 = pointAtT1 -
      startPoint * pow(1 - t1, 3).toDouble() -
      endPoint * pow(t1, 3).toDouble();
  final c2 = pointAtT2 -
      startPoint * pow(1 - t2, 3).toDouble() -
      endPoint * pow(t2, 3).toDouble();

  final d = (a1 * b2) - (a2 * b1);
  final dx = (c1 * b2) - (c2 * b1);
  final dy = (c2 * a1) - (c1 * a2);

  return [dx / d, dy / d];
}

// trả về offset tương ứng với kích thước của canvas
Offset interpolate({
  required Offset imageOffset,
  required double canvasWidth,
  required double canvasHeight,
  required double imageWidth,
  required double imageHeight,
}) {
  final scaleRatio = getScaleRatio(
    canvasWidth: canvasWidth,
    canvasHeight: canvasHeight,
    imageWidth: imageWidth,
    imageHeight: imageHeight,
  );

  return imageOffset * scaleRatio;
}

// get tỷ lệ chênh lệch giữa size của ảnh gốc và size của canvas
double getScaleRatio({
  required double canvasWidth,
  required double canvasHeight,
  required double imageWidth,
  required double imageHeight,
}) {
  final ratio = imageWidth / imageHeight;
  // fitWidth
  var imgWidth = canvasWidth;
  var imgHeight = canvasWidth / ratio; // scale widgetHeight theo ratio

  if (imgHeight > canvasHeight) {
    // fitHeight
    imgHeight = canvasHeight;
    imgWidth = imgHeight * ratio; // scale widgetWidth theo ratio
  }

  return imgWidth / imageWidth;
}
