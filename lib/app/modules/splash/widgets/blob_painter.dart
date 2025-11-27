import 'package:flutter/material.dart';

class BlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF7DB2BF)
      ..style = PaintingStyle.fill;

    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    // Simple organic blob using cubic beziers
    path.moveTo(0.5 * w, 0);
    path.cubicTo(0.85 * w, 0.05 * h, 1.0 * w, 0.35 * h, 0.95 * w, 0.6 * h);
    path.cubicTo(0.9 * w, 0.9 * h, 0.6 * w, 1.05 * h, 0.35 * w, 0.9 * h);
    path.cubicTo(0.1 * w, 0.75 * h, -0.05 * w, 0.45 * h, 0.15 * w, 0.25 * h);
    path.cubicTo(0.3 * w, 0.1 * h, 0.45 * w, 0.02 * h, 0.5 * w, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
