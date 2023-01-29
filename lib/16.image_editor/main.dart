import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'paint_controller.dart';
import 'paint_view.dart';

void main() {
  runApp(const MaterialApp(home: MyWidget()));
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  double _paintStrokeWidth = 5;
  ItemSelection _selection = ItemSelection.red;

  final PaintController _paintController = PaintController();
  final GlobalKey _captureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _paintController.initPaint(Colors.red, _paintStrokeWidth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adobe Photoshop'),
        actions: [
          IconButton(
              onPressed: () async {
                final bytes = await _convertWidgetToImage(_captureKey);
                if (bytes != null) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Image.memory(bytes),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.save))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _captureKey,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://taimienphi.vn/tmp/cf/aut/anh-gai-xinh-1.jpg',
                    fit: BoxFit.fill,
                  ),
                  PaintView(paintController: _paintController),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _selection == ItemSelection.red ? Colors.blue[50] : Colors.transparent),
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          _selection = ItemSelection.red;
                        });
                        _changeBrushColor(Colors.red);
                      },
                      icon: const Icon(
                        Icons.circle,
                        color: Colors.red,
                      )),
                ),
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selection == ItemSelection.yellow
                          ? Colors.blue[50]
                          : Colors.transparent),
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          _selection = ItemSelection.yellow;
                        });
                        _changeBrushColor(Colors.yellow);
                      },
                      icon: const Icon(
                        Icons.circle,
                        color: Colors.yellow,
                      )),
                ),
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _selection == ItemSelection.green ? Colors.blue[50] : Colors.transparent),
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          _selection = ItemSelection.green;
                        });
                        _changeBrushColor(Colors.green);
                      },
                      icon: const Icon(
                        Icons.circle,
                        color: Colors.green,
                      )),
                ),
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selection == ItemSelection.eraser
                          ? Colors.blue[50]
                          : Colors.transparent),
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          _selection = ItemSelection.eraser;
                        });
                        _paintController.eraserMode = true;
                      },
                      icon: const Icon(
                        Icons.cleaning_services,
                      )),
                ),
                IconButton(
                    onPressed: () {
                      _paintController.clear();
                    },
                    icon: const Icon(
                      Icons.clear,
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Row(
                children: [
                  const Icon(Icons.brush),
                  Expanded(
                    child: Slider.adaptive(
                      value: _paintStrokeWidth,
                      min: 3,
                      max: 20,
                      onChanged: (value) {
                        _paintController.paintStrokeWidth = value;
                        setState(() {
                          _paintStrokeWidth = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changeBrushColor(Color color) {
    _paintController.eraserMode = false;
    _paintController.paintColor = color;
  }

  Future<Uint8List?> _convertWidgetToImage(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } on Exception catch (error) {
      print(error);
    }

    return null;
  }
}

enum ItemSelection { red, yellow, green, eraser }
