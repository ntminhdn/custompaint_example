import 'package:flutter/material.dart';

import 'paint_controller.dart';

class PaintView extends StatefulWidget {
  const PaintView({
    super.key,
    required this.paintController,
  });
  final PaintController paintController;

  @override
  State<PaintView> createState() => _PaintViewState();
}

class _PaintViewState extends State<PaintView> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _onPaintStart,
      onScaleUpdate: _onPaintUpdate,
      onScaleEnd: _onPaintEnd,
      child: CustomPaint(
        painter: _CustomPainter(
          paintController: widget.paintController,
          repaint: widget.paintController,
        ),
      ),
    );
  }

  void _onPaintStart(ScaleStartDetails start) {
    widget.paintController.startPainting(start.localFocalPoint);
  }

  void _onPaintUpdate(ScaleUpdateDetails update) {
    widget.paintController.updatePainting(update.localFocalPoint);
  }

  void _onPaintEnd(ScaleEndDetails end) {
    widget.paintController.endPainting();
  }
}

class _CustomPainter extends CustomPainter {
  _CustomPainter({required this.paintController, required Listenable? repaint})
      : super(repaint: repaint);
  final PaintController paintController;

  @override
  void paint(Canvas canvas, Size size) {
    paintController.draw(canvas, size);
  }

  @override
  bool shouldRepaint(_CustomPainter oldDelegate) => true;
}
