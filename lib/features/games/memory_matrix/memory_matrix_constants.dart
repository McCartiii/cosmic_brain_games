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

class User {
  String name;
  List<int> scores;
  int currentLevel;

  User({required this.name, required this.scores, required this.currentLevel});

  double calculateAverageScore() {
    if (scores.isEmpty) return 0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  void evaluateDifficultyLevel() {
    double averageScore = calculateAverageScore();

    if (averageScore >= 90) {
      currentLevel = 7; // Expert
    } else if (averageScore >= 75) {
      currentLevel = 5; // Medium
    } else if (averageScore >= 60) {
      currentLevel = 3; // Beginner
    } else {
      currentLevel = MemoryMatrixConstants.initialGridSize;
    }
  }

  void updateScores(int newScore) {
    scores.add(newScore);

    // Keep only the last 5 scores
    if (scores.length > 5) {
      scores.removeAt(0);
    }

    evaluateDifficultyLevel();
    print(
        'New difficulty level: ${MemoryMatrixConstants.levelNames[currentLevel] ?? 'Unknown'}');
  }
}
