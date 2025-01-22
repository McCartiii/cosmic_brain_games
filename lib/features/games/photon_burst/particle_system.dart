import 'package:flutter/material.dart';
import 'dart:math';
import 'photon_burst_constants.dart';

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  Color color;
  double size;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.color,
    required this.size,
  });

  bool update(double dt) {
    x += vx * dt;
    y += vy * dt;
    life -= dt;
    size *= 0.95;
    return life > 0;
  }
}

class ExplosionEffect {
  final List<Particle> particles = [];
  final Random random = Random();

  void createExplosion(Offset position, Color color) {
    for (int i = 0; i < PhotonBurstConstants.particleCount; i++) {
      final angle = 2 * pi * i / PhotonBurstConstants.particleCount;
      final speed =
          PhotonBurstConstants.particleSpeed * (0.5 + random.nextDouble());

      particles.add(Particle(
        x: position.dx,
        y: position.dy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        life: PhotonBurstConstants.explosionDuration *
            (0.5 + random.nextDouble()),
        color: color,
        size: 8 + random.nextDouble() * 4,
      ));
    }
  }

  void update(double dt) {
    particles.removeWhere((particle) => !particle.update(dt));
  }

  void draw(Canvas canvas) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(
            (particle.life / PhotonBurstConstants.explosionDuration)
                .clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }
}
