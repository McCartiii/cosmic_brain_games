import 'package:flutter/material.dart';
import 'dart:math';

enum Difficulty { easy, medium, hard }

enum MemoryShape {
  circle,
  triangle,
  square,
  star,
  diamond,
  hexagon,
  cross,
  heart,
}

enum GamePhase {
  watching,
  input,
  complete,
}

class MemoryTrailConstants {
  static const Duration feedbackDuration = Duration(milliseconds: 300);
  static const Duration pauseBetweenShapes = Duration(milliseconds: 300);

  static const Map<Difficulty, int> sequenceLengths = {
    Difficulty.easy: 4,
    Difficulty.medium: 6,
    Difficulty.hard: 8,
  };

  static const Map<Difficulty, Duration> shapeDurations = {
    Difficulty.easy: Duration(milliseconds: 1200),
    Difficulty.medium: Duration(milliseconds: 800),
    Difficulty.hard: Duration(milliseconds: 500),
  };

  static const Map<Difficulty, List<MemoryShape>> availableShapes = {
    Difficulty.easy: [
      MemoryShape.circle,
      MemoryShape.triangle,
      MemoryShape.square,
    ],
    Difficulty.medium: [
      MemoryShape.circle,
      MemoryShape.triangle,
      MemoryShape.square,
      MemoryShape.star,
      MemoryShape.diamond,
    ],
    Difficulty.hard: [
      MemoryShape.circle,
      MemoryShape.triangle,
      MemoryShape.square,
      MemoryShape.star,
      MemoryShape.diamond,
      MemoryShape.hexagon,
      MemoryShape.cross,
      MemoryShape.heart,
    ],
  };

  static const Map<MemoryShape, Color> shapeColors = {
    MemoryShape.circle: Colors.blue,
    MemoryShape.triangle: Colors.green,
    MemoryShape.square: Colors.red,
    MemoryShape.star: Colors.yellow,
    MemoryShape.diamond: Colors.purple,
    MemoryShape.hexagon: Colors.orange,
    MemoryShape.cross: Colors.cyan,
    MemoryShape.heart: Colors.pink,
  };

  // Points system
  static const int pointsPerCorrect = 100;
  static const int pointsPerIncorrect = -50;
  static const Map<Difficulty, int> perfectSequenceBonus = {
    Difficulty.easy: 200,
    Difficulty.medium: 400,
    Difficulty.hard: 800,
  };

  // Speed increases per level
  static const Map<Difficulty, double> speedMultiplier = {
    Difficulty.easy: 0.9,
    Difficulty.medium: 0.85,
    Difficulty.hard: 0.8,
  };

  // UI Constants
  static const Color backgroundColor = Color(0xFF1A1A1A);
  static const Color laneColor = Color(0xFF2A2A2A);
  static const Color correctColor = Colors.green;
  static const Color incorrectColor = Colors.red;

  static const double gridPadding = 16.0;
  static const double laneSpacing = 8.0;
  static const double shapeSize = 60.0;
  static const double bottomShapeSize = 50.0;
  static const double bottomPadding = 24.0;

  static const TextStyle scoreStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle instructionStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );
}
