enum GameType {
  colorMatch,
  memoryMatrix,
  photonBurst,
  orbitNavigator,
}

class GameScore {
  final GameType gameType;
  final int score;
  final DateTime dateTime;

  GameScore({
    required this.gameType,
    required this.score,
    DateTime? dateTime,
  }) : dateTime = dateTime ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'gameType': gameType.toString(),
      'score': score,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory GameScore.fromJson(Map<String, dynamic> json) {
    return GameScore(
      gameType: GameType.values.firstWhere(
        (e) => e.toString() == json['gameType'],
      ),
      score: json['score'] as int,
      dateTime: DateTime.parse(json['dateTime'] as String),
    );
  }
}
