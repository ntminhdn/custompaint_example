import 'package:flutter/material.dart';

abstract class GravitationalObject {
  GravitationalObject({
    required this.position,
    this.gravitySpeed = 0.0,
    this.additionalForce = const Offset(0, 0),
  });

  Offset position;
  double gravitySpeed;
  final double _gravity = 1.0;

  // offset bổ sung để fruit rơi chéo, trông giống thật hơn là rơi thẳng
  Offset additionalForce;

  void applyGravity() {
    // mỗi lần gọi hàm này thì nó sẽ rơi xuống 1px + additionalForce px
    gravitySpeed += _gravity;
    position =
        Offset(position.dx + additionalForce.dx, position.dy + gravitySpeed + additionalForce.dy);
  }
}
