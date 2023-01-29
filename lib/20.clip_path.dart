import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('20. ClipPath'),
        ),
        body: Center(
          child: ClipPath(
            clipper: MyCustomClipper(),
            child: Image.network(
              'https://taimienphi.vn/tmp/cf/aut/anh-gai-xinh-1.jpg',
              width: 300,
              height: 300,
            ),
          ),
        ),
      ),
    ),
  );
}

class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    Path path = Path();
    path.moveTo(0.5 * width, height * 0.35);
    path.cubicTo(0.2 * width, height * 0.1, -0.15 * width, height * 0.6, 0.5 * width, height);
    path.moveTo(0.5 * width, height * 0.35);
    path.cubicTo(0.8 * width, height * 0.1, 1.15 * width, height * 0.6, 0.5 * width, height);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
