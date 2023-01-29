import 'package:flutter/material.dart';

import 'gravitaional_object.dart';

class FruitPart extends GravitationalObject {
  FruitPart({
    required this.isLeft,
    position,
    gravitySpeed = 0.0,
    additionalForce = const Offset(0, 0),
  }) : super(position: position, gravitySpeed: gravitySpeed, additionalForce: additionalForce);

  bool isLeft;
}
