import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedStarsBackground extends StatefulWidget {
  const AnimatedStarsBackground({super.key});

  @override
  State<AnimatedStarsBackground> createState() =>
      _AnimatedStarsBackgroundState();
}

class _AnimatedStarsBackgroundState extends State<AnimatedStarsBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Star> _stars = List.generate(100, (_) => Star());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: StarfieldPainter(_stars, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class Star {
  final double x = math.Random().nextDouble();
  final double y = math.Random().nextDouble();
  final double brightness = math.Random().nextDouble();
  final double speed = math.Random().nextDouble() * 0.2 + 0.1;
}

class StarfieldPainter extends CustomPainter {
  final List<Star> stars;
  final double animation;

  StarfieldPainter(this.stars, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (var star in stars) {
      final position = Offset(
        star.x * size.width,
        (star.y + (animation * star.speed)) % 1.0 * size.height,
      );

      paint.color = Colors.white.withOpacity(star.brightness * 0.7);
      canvas.drawCircle(position, 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(StarfieldPainter oldDelegate) => true;
}
