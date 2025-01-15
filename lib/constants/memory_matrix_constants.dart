import 'package:flutter/material.dart';

class MemoryMatrixConstants {
  // Game settings
  static const int initialGridSize = 3;
  static const int maxGridSize = 7;
  static const double displayDuration = 1.0;
  static const int pointsPerCorrectPattern = 10;
  static const int livesPerGame = 3;

  // Animation durations
  static const Duration patternShowDuration = Duration(milliseconds: 1000);
  static const Duration patternFadeDuration = Duration(milliseconds: 500);
  static const Duration successMessageDuration = Duration(seconds: 1);
  static const Duration cellTapDuration = Duration(milliseconds: 200);

  // Level names mapping
  static const Map<int, String> levelNames = {
    3: 'Beginner',
    4: 'Easy',
    5: 'Medium',
    6: 'Hard',
    7: 'Expert',
  };
}
