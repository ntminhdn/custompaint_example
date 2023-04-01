import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('20. ClipPath'),
        ),
        body: const Center(
          child: HeartImage(),
        ),
      ),
    ),
  );
}

class HeartImage extends StatefulWidget {
  const HeartImage({
    super.key,
  });

  @override
  State<HeartImage> createState() => _HeartImageState();
}

class _HeartImageState extends State<HeartImage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _heartSize;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 200000,
      ),
    )..addListener(() {
      setState(() {});
    });

    _heartSize = Tween(begin: 0.0, end: pi * 200).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    // Since a heartbeat, so repeats infinitely.
    _controller.repeat();
  }

  @override
  void didUpdateWidget(HeartImage oldWidget) {
    _controller.reset();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.rotationY(_heartSize.value),
      alignment: FractionalOffset.center,
      child: ClipPath(
        clipper: MyCustomClipper(),
        child: Image.network(
          'https://taimienphi.vn/tmp/cf/aut/anh-gai-xinh-1.jpg',
          width: 300,
          height: 300,
        ),
      ),
    );
  }
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
