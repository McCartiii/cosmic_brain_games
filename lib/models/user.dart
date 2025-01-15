import '../constants/memory_matrix_constants.dart';

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
