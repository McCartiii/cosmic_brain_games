import 'package:flutter/material.dart';

enum Difficulty { easy, normal, hard }

class StationTimers {
  final Duration energyGenerator;
  final Duration dataUplink;
  final Duration storageDepot;

  const StationTimers({
    required this.energyGenerator,
    required this.dataUplink,
    required this.storageDepot,
  });
}

class MemoryCommandConstants {
  // Game durations for different difficulty levels
  static const Map<Difficulty, StationTimers> stationTimers = {
    Difficulty.easy: StationTimers(
      energyGenerator: Duration(seconds: 15),
      dataUplink: Duration(seconds: 20),
      storageDepot: Duration(seconds: 25),
    ),
    Difficulty.normal: StationTimers(
      energyGenerator: Duration(seconds: 10),
      dataUplink: Duration(seconds: 12),
      storageDepot: Duration(seconds: 15),
    ),
    Difficulty.hard: StationTimers(
      energyGenerator: Duration(seconds: 8),
      dataUplink: Duration(seconds: 10),
      storageDepot: Duration(seconds: 12),
    ),
  };

  // Scoring constants
  static const int basePoints = 10;
  static const int streakBonus = 5;
  static const int earlyPenalty = -5;
  static const int latePenalty = -5;
  static const int perfectTaskBonus = 15;
  static const int maxStreak = 5;

  // Game settings
  static const int gameDuration = 60; // seconds
  static const double lateThreshold = 1.2; // 20% over time is considered late

  // UI Colors
  static const Color backgroundColor = Color(0xFF1A1A1A);
  static const Color stationBackgroundColor = Color(0xFF2A2A2A);
  static const Color activeStationBorder = Color(0xFF4A90E2);
  static const Color inactiveStationBorder = Color(0xFF404040);

  static const Map<Difficulty, Color> difficultyColors = {
    Difficulty.easy: Color(0xFF4CAF50), // Green
    Difficulty.normal: Color(0xFF2196F3), // Blue
    Difficulty.hard: Color(0xFFF44336), // Red
  };

  // Text Styles
  static const TextStyle scoreStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle timerStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle stationNameStyle = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle buttonStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle feedbackStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(
        color: Colors.black54,
        offset: Offset(2, 2),
        blurRadius: 4,
      ),
    ],
  );

  // Animation Durations
  static const Duration switchStationDuration = Duration(milliseconds: 300);
  static const Duration feedbackDuration = Duration(milliseconds: 200);
  static const Duration progressBarUpdateInterval = Duration(milliseconds: 16);

  // Tutorial Messages
  static const Map<String, String> tutorialMessages = {
    'welcome': 'Welcome to Memory Command!',
    'objective': 'Manage 3 stations by tracking their task timers',
    'stations': 'Each station has different task durations',
    'timing': 'Return to collect output at the right time',
    'scoring': 'Perfect timing earns bonus points',
    'streak': 'Build streaks for higher scores',
  };

  // Feedback Messages
  static const String perfectTiming = 'Perfect Timing!';
  static const String tooEarly = 'Too Early!';
  static const String tooLate = 'Too Late!';
  static const String newStreak = 'Streak × ';
  static const String stationReady = 'Ready!';

  // Station Names
  static const Map<String, String> stationDescriptions = {
    'Energy Generator': 'Powers the station',
    'Data Uplink': 'Transmits information',
    'Storage Depot': 'Manages resources',
  };

  // Button Text
  static const String startGameText = 'Start Mission';
  static const String startTaskText = 'Start Task';
  static const String collectOutputText = 'Collect Output';
  static const String restartText = 'Try Again';
  static const String exitText = 'Exit Mission';

  // Achievement Thresholds
  static const Map<String, int> achievements = {
    'Rookie': 100,
    'Operator': 250,
    'Expert': 500,
    'Commander': 1000,
    'Master': 2000,
  };

  // Efficiency Ratings
  static const Map<String, double> efficiencyThresholds = {
    'Master Commander': 0.8,
    'Expert Operator': 0.6,
    'Skilled Technician': 0.4,
    'Trainee Officer': 0.2,
    'Needs Practice': 0.0,
  };

  // Sound Effect Keys
  static const String soundTaskStart = 'task_start';
  static const String soundTaskComplete = 'task_complete';
  static const String soundTaskFail = 'task_fail';
  static const String soundSwitch = 'station_switch';
  static const String soundStreak = 'streak';
}
