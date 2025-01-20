class PhotonBurstConstants {
  static const int gameDuration = 60; // Game duration in seconds
  static const double photonSize = 60.0;
  static const Duration photonLifespan = Duration(seconds: 3);

  static const Map<String, PhotonType> photonTypes = {
    'red': PhotonType(
      color: 0xFFFF5252,
      points: 10,
      direction: SwipeDirection.left,
    ),
    'blue': PhotonType(
      color: 0xFF448AFF,
      points: 15,
      direction: SwipeDirection.right,
    ),
    'green': PhotonType(
      color: 0xFF4CAF50,
      points: 20,
      direction: SwipeDirection.up,
    ),
    'purple': PhotonType(
      color: 0xFF9C27B0,
      points: 25,
      direction: SwipeDirection.down,
    ),
  };
}

class PhotonType {
  final int color;
  final int points;
  final SwipeDirection direction;

  const PhotonType({
    required this.color,
    required this.points,
    required this.direction,
  });
}

enum SwipeDirection {
  up,
  down,
  left,
  right,
}
