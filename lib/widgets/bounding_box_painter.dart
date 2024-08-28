import 'package:flutter/material.dart';
import '../models/bounding_box.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<BoundingBox> boxes;
  final double imageWidth;
  final double imageHeight;

  BoundingBoxPainter(this.boxes, this.imageWidth, this.imageHeight);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final textStyle = TextStyle(
      color: Colors.red,
      fontSize: 14,
    );

    for (final box in boxes) {
      // Scale the bounding box coordinates to fit the displayed image
      final scaledX = box.x * size.width / imageWidth;
      final scaledY = box.y * size.height / imageHeight;
      final scaledWidth = box.width * size.width / imageWidth;
      final scaledHeight = box.height * size.height / imageHeight;

      final rect = Rect.fromLTWH(scaledX, scaledY, scaledWidth, scaledHeight);
      canvas.drawRect(rect, paint);

      final textSpan = TextSpan(
        text: '${box.className} (${(box.confidence * 100).toStringAsFixed(2)}%)',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(scaledX, scaledY - textPainter.height));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
