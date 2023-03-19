import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('5. Path - Vẽ bubble chat'),
        ),
        body: const Center(
          child: ChatScreen(),
        ),
      ),
    ),
  );
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  BubbleChat(message: _messages[index]),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    filled: true,
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      _messages.add(Message(controller.text, true));
                      _messages.add(Message(controller.text, false));
                    });
                  },
                  icon: const Icon(Icons.send))
            ],
          )
        ],
      ),
    );
  }
}

class Message {
  final String message;
  final bool isMine;

  Message(this.message, this.isMine);
}

class BubbleChat extends StatelessWidget {
  const BubbleChat({
    Key? key,
    required this.message,
  }) : super(key: key);

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMine ? Alignment.topRight : Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomPaint(
          painter: MyCustomPainter(isMine: message.isMine),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * .7,
            ),
            padding: const EdgeInsets.all(8),
            child: Text(
              message.message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  MyCustomPainter({required this.isMine})
      : bgPaint = Paint()
          ..color = isMine ? Colors.pinkAccent : Colors.black54
          ..style = PaintingStyle.fill;

  final bool isMine;
  final Paint bgPaint;
  static const arrowSize = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final rightPoint1 = Offset(width, height / 2 - (arrowSize / 2));
    final rightPoint2 = Offset(
        width + sqrt(pow(arrowSize, 2) - pow(arrowSize / 2, 2)), height / 2);
    final centerPoint = Offset(width / 2, height / 2);
    final leftPoint1 = centerPoint * 2 - rightPoint1; // đối xứng tâm
    final leftPoint2 = centerPoint * 2 - rightPoint2; // đối xứng tâm

    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTRB(0, 0, width, height), const Radius.circular(10)),
        bgPaint);
    final rightPath = Path()
      ..moveTo(rightPoint1.dx, rightPoint1.dy)
      ..relativeLineTo(0, arrowSize)
      ..lineTo(rightPoint2.dx, rightPoint2.dy)
      ..close(); // ko cần close cũng đc

    final leftPath = Path()
      ..moveTo(leftPoint1.dx, leftPoint1.dy)
      ..relativeLineTo(0, -arrowSize)
      ..lineTo(leftPoint2.dx, leftPoint2.dy);

    canvas.drawPath(isMine ? rightPath : leftPath, bgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
