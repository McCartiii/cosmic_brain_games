import 'package:flutter/material.dart';
import 'dart:math';

enum TargetType { standard, bonus, trap, powerUp }

class PhotonTarget {
  final double size;
  final Color color;
  final TargetType type;
  double x;
  double y;
  double velocity;
  double angle;
  bool isActive;
  double opacity;
  double scale;
  double rotationAngle;

  PhotonTarget({
    required this.size,
    required this.color,
    required this.x,
    required this.y,
    this.type = TargetType.standard,
    this.velocity = 2.0,
    this.angle = 0.0,
    this.isActive = true,
    this.opacity = 1.0,
    this.scale = 1.0,
    this.rotationAngle = 0.0,
  });

  void update(Size screenSize) {
    if (!isActive) return;

    x += velocity * cos(angle);
    y += velocity * sin(angle);
    rotationAngle += 0.02;

    // Bounce off walls with slight randomization
    if (x <= 0 || x >= screenSize.width - size) {
      angle = pi - angle + (Random().nextDouble() - 0.5) * 0.2;
      velocity *= 1.05; // Slight speed increase on bounce
    }
    if (y <= 0 || y >= screenSize.height - size) {
      angle = -angle + (Random().nextDouble() - 0.5) * 0.2;
      velocity *= 1.05;
    }

    // Keep within bounds
    x = x.clamp(0.0, screenSize.width - size);
    y = y.clamp(0.0, screenSize.height - size);

    // Animate based on type
    switch (type) {
      case TargetType.powerUp:
        scale = 1.0 + sin(DateTime.now().millisecondsSinceEpoch * 0.005) * 0.1;
        break;
      case TargetType.bonus:
        opacity =
            0.7 + sin(DateTime.now().millisecondsSinceEpoch * 0.003) * 0.3;
        break;
      default:
        break;
    }
  }

  bool containsPoint(Offset point) {
    final center = Offset(x + size / 2, y + size / 2);
    return (point - center).distance <= size / 2;
  }

  void hit() {
    isActive = false;
  }
}
