class LeaderboardEntry {
  final String name;
  final int score;
  final String game;
  final String avatarUrl;
  final DateTime dateAchieved;
  final Map<String, dynamic> achievements;

  const LeaderboardEntry({
    required this.name,
    required this.score,
    required this.game,
    this.avatarUrl = '',
    required this.dateAchieved,
    this.achievements = const {},
  });

  // Add a factory constructor for demo data
  static List<LeaderboardEntry> getDemoEntries(String gameType) {
    return [
      LeaderboardEntry(
        name: "Alice",
        score: 1000,
        game: gameType,
        dateAchieved: DateTime.now().subtract(const Duration(days: 1)),
      ),
      LeaderboardEntry(
        name: "Bob",
        score: 850,
        game: gameType,
        dateAchieved: DateTime.now().subtract(const Duration(days: 2)),
      ),
      LeaderboardEntry(
        name: "Charlie",
        score: 750,
        game: gameType,
        dateAchieved: DateTime.now().subtract(const Duration(days: 3)),
      ),
      LeaderboardEntry(
        name: "David",
        score: 700,
        game: gameType,
        dateAchieved: DateTime.now().subtract(const Duration(days: 4)),
      ),
      LeaderboardEntry(
        name: "Eve",
        score: 650,
        game: gameType,
        dateAchieved: DateTime.now().subtract(const Duration(days: 5)),
      ),
      // Add more demo entries as needed
    ];
  }
}
