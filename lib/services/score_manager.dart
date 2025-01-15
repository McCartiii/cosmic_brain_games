import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' show max;
import '../models/game_score.dart';

class ScoreManager extends ChangeNotifier {
  static const String _scoresKey = 'game_scores';
  final List<GameScore> _scores = [];

  ScoreManager() {
    _loadScores();
  }

  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    final scoresJson = prefs.getStringList(_scoresKey) ?? [];

    _scores.clear();
    for (final scoreJson in scoresJson) {
      try {
        final scoreMap = json.decode(scoreJson) as Map<String, dynamic>;
        _scores.add(GameScore.fromJson(scoreMap));
      } catch (e) {
        debugPrint('Error loading score: $e');
      }
    }
    notifyListeners();
  }

  Future<void> _saveScores() async {
    final prefs = await SharedPreferences.getInstance();
    final scoresJson =
        _scores.map((score) => json.encode(score.toJson())).toList();
    await prefs.setStringList(_scoresKey, scoresJson);
  }

  void addScore(GameScore score) {
    _scores.add(score);
    _saveScores();
    notifyListeners();
  }

  int getHighScore(GameType gameType) {
    final gameScores = _scores.where((score) => score.gameType == gameType);
    if (gameScores.isEmpty) return 0;
    return gameScores.map((score) => score.score).reduce(max);
  }

  List<GameScore> getScores(GameType gameType) {
    return _scores.where((score) => score.gameType == gameType).toList()
      ..sort((a, b) => b.score.compareTo(a.score));
  }
}
