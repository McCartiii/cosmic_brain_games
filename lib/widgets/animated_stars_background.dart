import 'package:flutter/material.dart';
import 'dart:math';

class Star {
  double x;
  double y;
  double size;
  double brightness;
  double speed;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.brightness,
    required this.speed,
  });
}

class AnimatedStarsBackground extends StatefulWidget {
  final Widget child;

  const AnimatedStarsBackground({
    required this.child,
    super.key,
  });

  @override
  State<AnimatedStarsBackground> createState() =>
      _AnimatedStarsBackgroundState();
}

class _AnimatedStarsBackgroundState extends State<AnimatedStarsBackground>
    with TickerProviderStateMixin {
  final List<Star> stars = [];
  final Random random = Random();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _initializeStars();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _controller.addListener(_updateStars);
  }

  void _initializeStars() {
    for (int i = 0; i < 100; i++) {
      stars.add(Star(
        x: random.nextDouble() * 1000,
        y: random.nextDouble() * 1000,
        size: random.nextDouble() * 2 + 1,
        brightness: random.nextDouble(),
        speed: random.nextDouble() * 0.5 + 0.1,
      ));
    }
  }

  void _updateStars() {
    setState(() {
      for (var star in stars) {
        star.brightness =
            (sin(_controller.value * 2 * pi * star.speed) + 1) / 2;
        star.y += star.speed;
        if (star.y > MediaQuery.of(context).size.height) {
          star.y = 0;
          star.x = random.nextDouble() * MediaQuery.of(context).size.width;
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: StarsPainter(stars),
        ),
        widget.child,
      ],
    );
  }
}

class StarsPainter extends CustomPainter {
  final List<Star> stars;

  StarsPainter(this.stars);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (var star in stars) {
      paint.color = Colors.white.withOpacity(star.brightness);
      canvas.drawCircle(
        Offset(star.x, star.y),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(StarsPainter oldDelegate) => true;
}
