class Team {
  final String id;
  final String name;
  final List<String> playerIds;
  final int totalScore;

  Team({
    required this.id,
    required this.name,
    required this.playerIds,
    this.totalScore = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'playerIds': playerIds,
      'totalScore': totalScore,
    };
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      playerIds: List<String>.from(json['playerIds']),
      totalScore: json['totalScore'],
    );
  }
}
