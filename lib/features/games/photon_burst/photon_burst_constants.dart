import 'package:flutter/material.dart';

enum Difficulty { easy, normal, hard }

class PhotonBurstConstants {
  // Game Settings
  static const int gameDuration = 60;
  static const double baseTargetSize = 60.0;
  static const double minTargetSize = 30.0;
  static const double baseVelocity = 2.0;
  static const double velocityIncreasePerLevel = 0.5;
  static const int pointsPerHit = 100;
  static const int bonusPoints = 250;
  static const int penaltyPoints = -50;
  static const double powerUpChance = 0.1;
  static const double powerUpDuration = 5.0;

  // Visual Effects
  static const double explosionDuration = 0.5;
  static const int particleCount = 12;
  static const double particleSpeed = 100.0;
  static const double particleFadeTime = 0.3;

  // Difficulty Settings
  static const Map<Difficulty, int> maxTargets = {
    Difficulty.easy: 3,
    Difficulty.normal: 5,
    Difficulty.hard: 7,
  };

  static const Map<Difficulty, double> speedMultiplier = {
    Difficulty.easy: 0.8,
    Difficulty.normal: 1.0,
    Difficulty.hard: 1.3,
  };

  // Colors
  static const Color standardTargetColor = Color(0xFF2196F3);
  static const Color bonusTargetColor = Color(0xFF4CAF50);
  static const Color trapTargetColor = Color(0xFFF44336);
  static const Color powerUpColor = Color(0xFFFFEB3B);
  static const Color particleColor = Color(0xFFFFFFFF);
  static const Color backgroundColor = Color(0xFF000000);

  // Text Styles
  static const TextStyle scoreStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(
        blurRadius: 10,
        color: Colors.blue,
        offset: Offset(0, 0),
      ),
    ],
  );

  static const TextStyle timerStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    shadows: [
      Shadow(
        blurRadius: 8,
        color: Colors.red,
        offset: Offset(0, 0),
      ),
    ],
  );

  static const TextStyle comboStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    shadows: [
      Shadow(
        blurRadius: 8,
        color: Colors.purple,
        offset: Offset(0, 0),
      ),
    ],
  );
}
