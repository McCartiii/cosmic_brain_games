import 'package:flutter/material.dart';

enum PowerUpType {
  timeFreeze,
  doublePoints,
  rapidFire,
  shield,
}

class PowerUp {
  final PowerUpType type;
  final Duration duration;
  final DateTime startTime;
  bool isActive;

  PowerUp({
    required this.type,
    required this.duration,
  })  : startTime = DateTime.now(),
        isActive = true;

  double get remainingTime {
    final elapsed = DateTime.now().difference(startTime);
    return (duration - elapsed).inMilliseconds / 1000;
  }

  bool get isExpired => remainingTime <= 0;

  Color get color {
    return switch (type) {
      PowerUpType.timeFreeze => Colors.lightBlue,
      PowerUpType.doublePoints => Colors.green,
      PowerUpType.rapidFire => Colors.orange,
      PowerUpType.shield => Colors.purple,
    };
  }

  IconData get icon {
    return switch (type) {
      PowerUpType.timeFreeze => Icons.ac_unit,
      PowerUpType.doublePoints => Icons.stars,
      PowerUpType.rapidFire => Icons.flash_on,
      PowerUpType.shield => Icons.shield,
    };
  }

  String get name {
    return switch (type) {
      PowerUpType.timeFreeze => 'Time Freeze',
      PowerUpType.doublePoints => 'Double Points',
      PowerUpType.rapidFire => 'Rapid Fire',
      PowerUpType.shield => 'Shield',
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'duration': duration.inMilliseconds,
      'startTime': startTime.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  factory PowerUp.fromJson(Map<String, dynamic> json) {
    return PowerUp(
      type: PowerUpType.values[json['type'] as int],
      duration: Duration(milliseconds: json['duration'] as int),
    )..isActive = json['isActive'] as bool;
  }
}
