import 'package:flutter/material.dart';

import 'gravitaional_object.dart';

class Fruit extends GravitationalObject {
  Fruit({
    position,
    gravitySpeed = 0.0,
    additionalForce = const Offset(0, 0),
  }) : super(position: position, gravitySpeed: gravitySpeed, additionalForce: additionalForce);

  // dùng để vẽ hình chữ nhật bao quanh trái dưa hấu
  // Dùng hình chữ nhật đó để check kiếm chém trúng chưa
  // chém trúng khi hình chữ nhật này contains bất kỳ point nào thuộc kiếm
  final double width = 80;
  final double height = 80;

  bool isPointInside(Offset point) {
    return Rect.fromLTWH(position.dx, position.dy, width, height).contains(point);
  }

  @override
  String toString() {
    return '$position $width $height $additionalForce $gravitySpeed';
  }
}
