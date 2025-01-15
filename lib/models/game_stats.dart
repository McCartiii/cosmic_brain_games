class GameStats {
  final int totalPlayers;
  final int averageScore;
  final int highScore;

  const GameStats({
    required this.totalPlayers,
    required this.averageScore,
    required this.highScore,
  });

  // Add a factory constructor for demo data
  factory GameStats.demo() {
    return const GameStats(
      totalPlayers: 156,
      averageScore: 750,
      highScore: 1200,
    );
  }
}
