import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  double opacity;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    this.opacity = 1.0,
  });

  void update(double gravity) {
    velocity = Offset(velocity.dx, velocity.dy + gravity);
    position = position + velocity;
    opacity *= 0.97;
  }
}

class Firework extends StatelessWidget {
  final Color color;
  final double size;
  final double explosionProgress;
  final List<Particle> particles;

  const Firework({
    super.key,
    required this.color,
    this.size = 10,
    required this.explosionProgress,
    required this.particles,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size * 2, size * 2),
      painter: FireworkPainter(
        color: color,
        explosionProgress: explosionProgress,
        particles: particles,
      ),
    );
  }
}

class FireworkPainter extends CustomPainter {
  final Color color;
  final double explosionProgress;
  final List<Particle> particles;

  FireworkPainter({
    required this.color,
    required this.explosionProgress,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    // Draw particles
    for (final particle in particles) {
      paint.color = particle.color.withOpacity(particle.opacity);
      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(FireworkPainter oldDelegate) {
    return explosionProgress != oldDelegate.explosionProgress;
  }
}

class FireworkDisplay extends StatefulWidget {
  final Offset position;
  final Color color;
  final double size;

  const FireworkDisplay({
    super.key,
    required this.position,
    required this.color,
    this.size = 10,
  });

  @override
  State<FireworkDisplay> createState() => _FireworkDisplayState();
}

class _FireworkDisplayState extends State<FireworkDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _explosionProgress;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _explosionProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.addListener(_updateParticles);
    _initializeParticles();
    _controller.forward();
  }

  void _initializeParticles() {
    const particleCount = 30; // Reduced from 50
    const maxVelocity = 3.0;

    for (int i = 0; i < particleCount; i++) {
      final angle = 2 * pi * i / particleCount;
      final velocity = maxVelocity * (_random.nextDouble() * 0.5 + 0.5);
      _particles.add(
        Particle(
          position: widget.position,
          velocity: Offset(
            velocity * cos(angle),
            velocity * sin(angle),
          ),
          size: _random.nextDouble() * 2 + 1, // Smaller particles
          color: Color.lerp(
            widget.color,
            Colors.white,
            _random.nextDouble() * 0.3,
          )!,
        ),
      );
    }
  }

  void _updateParticles() {
    if (_controller.value > 0.2) {
      for (final particle in _particles) {
        particle.update(0.2); // Reduced gravity
      }
      _particles.removeWhere((particle) => particle.opacity < 0.1);
    }
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
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              left: widget.position.dx - widget.size,
              top: widget.position.dy - widget.size,
              child: Firework(
                color: widget.color,
                size: widget.size,
                explosionProgress: _explosionProgress.value,
                particles: _particles,
              ),
            );
          },
        ),
      ],
    );
  }
}

class FireworksController {
  final List<FireworkDisplay> _fireworks = [];
  final Random _random = Random();

  void addFirework({
    required Offset position,
    Color? color,
    double size = 10,
  }) {
    color ??= _getRandomColor();
    _fireworks.add(
      FireworkDisplay(
        position: position,
        color: color,
        size: size,
      ),
    );
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  List<FireworkDisplay> get fireworks => _fireworks;

  void clear() {
    _fireworks.clear();
  }
}
