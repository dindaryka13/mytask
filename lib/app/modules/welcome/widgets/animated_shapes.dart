import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedShapes extends StatefulWidget {
  const AnimatedShapes({Key? key}) : super(key: key);

  @override
  State<AnimatedShapes> createState() => _AnimatedShapesState();
}

class _AnimatedShapesState extends State<AnimatedShapes>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  
  final List<ShapeData> _shapes = [
    ShapeData(ShapeType.circle, 0.1, 0.05, 15, 0.3),
    ShapeData(ShapeType.square, 0.2, 0.15, 12, 0.25),
    ShapeData(ShapeType.triangle, 0.85, 0.08, 18, 0.35),
    ShapeData(ShapeType.circle, 0.9, 0.12, 10, 0.2),
    ShapeData(ShapeType.square, 0.15, 0.25, 8, 0.15),
    ShapeData(ShapeType.circle, 0.7, 0.18, 14, 0.28),
    ShapeData(ShapeType.triangle, 0.3, 0.22, 16, 0.32),
    ShapeData(ShapeType.square, 0.75, 0.28, 11, 0.22),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _shapes.length,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(seconds: 3 + index % 3),
      )..repeat(reverse: true),
    );
    
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: ShapesPainter(_animations, _shapes),
      ),
    );
  }
}

enum ShapeType { circle, square, triangle }

class ShapeData {
  final ShapeType type;
  final double x;
  final double y;
  final double size;
  final double opacity;

  ShapeData(this.type, this.x, this.y, this.size, this.opacity);
}

class ShapesPainter extends CustomPainter {
  final List<Animation<double>> animations;
  final List<ShapeData> shapes;

  ShapesPainter(this.animations, this.shapes) : super(repaint: Listenable.merge(animations));

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < shapes.length; i++) {
      final shape = shapes[i];
      final animation = animations[i].value;
      
      final paint = Paint()
        ..color = const Color(0xFF7AB5BD).withOpacity(shape.opacity * (0.5 + animation * 0.5))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final center = Offset(
        size.width * shape.x + math.sin(animation * math.pi * 2) * 10,
        size.height * shape.y + math.cos(animation * math.pi * 2) * 10,
      );

      switch (shape.type) {
        case ShapeType.circle:
          canvas.drawCircle(center, shape.size, paint);
          break;
        case ShapeType.square:
          canvas.drawRect(
            Rect.fromCenter(center: center, width: shape.size * 2, height: shape.size * 2),
            paint,
          );
          break;
        case ShapeType.triangle:
          final path = Path();
          path.moveTo(center.dx, center.dy - shape.size);
          path.lineTo(center.dx - shape.size, center.dy + shape.size);
          path.lineTo(center.dx + shape.size, center.dy + shape.size);
          path.close();
          canvas.drawPath(path, paint);
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}