import 'package:flutter/material.dart';

class PhotonBurstConstants {
  static const int gameDuration = 30;
  static const double photonSize = 60.0;
  static const Duration photonLifespan = Duration(milliseconds: 2000);
  static const Duration popAnimationDuration = Duration(milliseconds: 200);

  static const Map<String, PhotonType> photonTypes = {
    'ArrowUp': PhotonType(
      color: 0xFF4287F5, // Blue
      points: 10,
    ),
    'ArrowRight': PhotonType(
      color: 0xFFF54242, // Red
      points: 20,
    ),
    'ArrowDown': PhotonType(
      color: 0xFF42F54B, // Green
      points: 15,
    ),
    'ArrowLeft': PhotonType(
      color: 0xFFF5D442, // Yellow
      points: 25,
    ),
  };
}

class PhotonType {
  final int color;
  final int points;

  const PhotonType({
    required this.color,
    required this.points,
  });
}
