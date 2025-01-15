class Player {
  final String id;
  final String name;
  final String teamId;
  final int totalScore;

  Player({
    required this.id,
    required this.name,
    required this.teamId,
    this.totalScore = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'teamId': teamId,
      'totalScore': totalScore,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      teamId: json['teamId'],
      totalScore: json['totalScore'],
    );
  }
}
