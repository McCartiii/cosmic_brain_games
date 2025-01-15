import 'package:flutter/material.dart';

class ColorMatchConstants {
  static const List<Color> gameColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  static const int gameDurationSeconds = 60;
  static const int pointsPerCorrectMatch = 10;
  static const int pointsPerWrongMatch = -20;
}
