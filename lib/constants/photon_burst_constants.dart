import 'package:flutter/material.dart';

class PhotonBurstConstants {
  static const int gameDuration = 60;
  static const double photonSize = 60.0;
  static const Duration photonLifespan = Duration(seconds: 2);

  static const Map<String, PhotonType> photonTypes = {
    'ArrowUp': PhotonType(
      color: 0xFF00FF00, // Green
      points: 10,
    ),
    'ArrowRight': PhotonType(
      color: 0xFF0000FF, // Blue
      points: 15,
    ),
    'ArrowDown': PhotonType(
      color: 0xFFFF0000, // Red
      points: 20,
    ),
    'ArrowLeft': PhotonType(
      color: 0xFFFFFF00, // Yellow
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
