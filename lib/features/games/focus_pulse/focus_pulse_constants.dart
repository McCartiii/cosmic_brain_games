import 'package:flutter/material.dart';

enum ShapeType { circle, triangle, square }

enum TargetColor { red, blue, yellow }

enum GameState { menu, playing, paused, warning, gameOver }

enum RoundPhase { instruction, action, pause }

class FocusPulseConstants {
  // Timing
  static const Duration instructionPhaseDuration = Duration(seconds: 3);
  static const Duration actionPhaseDuration = Duration(seconds: 20);
  static const Duration pausePhaseDuration = Duration(seconds: 2);
  static const Duration baseTargetDuration = Duration(milliseconds: 3000);
  static const Duration warningDuration = Duration(milliseconds: 800);
  static const Duration feedbackDuration = Duration(milliseconds: 300);

  // Grid Settings
  static const int initialGridSize = 3;
  static const int maxGridSize = 4;
  static const double gridSpacing = 8.0;
  static const double gridPadding = 24.0;
  static const double maxTargetSize = 60.0;
  static const double minTargetSize = 40.0;

  // Game Rules
  static const int maxConsecutiveErrors = 3;
  static const int roundsPerLevel = 2;
  static const double speedIncreasePerLevel = 0.2;
  static const int targetCountIncreasePerLevel = 1;

  // Scoring
  static const int pointsForCorrectTap = 10;
  static const int pointsForIncorrectTap = -5;
  static const int pointsForMissedTarget = -2;
  static const int streakBonusThreshold = 3;
  static const int streakBonusPoints = 5;
  static const double initialScoreMultiplier = 1.0;
  static const double speedBonusMultiplier = 0.5;

  // Colors
  static const Map<TargetColor, Color> targetColors = {
    TargetColor.red: Color(0xFFFF4D4D),
    TargetColor.blue: Color(0xFF4D79FF),
    TargetColor.yellow: Color(0xFFFFD700),
  };

  static const Color correctFeedbackColor = Color(0xFF4CAF50);
  static const Color incorrectFeedbackColor = Color(0xFFFF5252);
  static const Color warningColor = Color(0xFFFF3D00);
  static const Color backgroundColor = Colors.black;

  // Text Styles
  static const TextStyle instructionStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle warningStyle = TextStyle(
    color: Colors.white,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle scoreStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle streakStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle levelStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle gameOverStyle = TextStyle(
    color: Colors.white,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle buttonStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.w500,
  );

  // Game Rules
  static List<GameRule> get basicRules => [
        GameRule(
          instruction: 'Tap all blue shapes',
          isValidTarget: (target) => target.color == TargetColor.blue,
        ),
        GameRule(
          instruction: 'Tap all triangles',
          isValidTarget: (target) => target.shape == ShapeType.triangle,
        ),
        GameRule(
          instruction: 'Tap all shapes except red',
          isValidTarget: (target) => target.color != TargetColor.red,
        ),
        GameRule(
          instruction: 'Tap all blue triangles',
          isValidTarget: (target) =>
              target.color == TargetColor.blue &&
              target.shape == ShapeType.triangle,
        ),
      ];
}

class GameRule {
  final String instruction;
  final bool Function(Target) isValidTarget;

  const GameRule({
    required this.instruction,
    required this.isValidTarget,
  });
}

class Target {
  final ShapeType shape;
  final TargetColor color;
  final int gridPosition;
  final bool isActive;
  final bool isDistractor;
  final bool isBait;

  const Target({
    required this.shape,
    required this.color,
    required this.gridPosition,
    this.isActive = true,
    this.isDistractor = false,
    this.isBait = false,
  });
}
