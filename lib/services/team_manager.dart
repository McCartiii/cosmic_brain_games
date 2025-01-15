import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/team.dart';
import '../models/player.dart';

class TeamManager extends ChangeNotifier {
  List<Team> _teams = [];
  List<Player> _players = [];

  List<Team> get teams => _teams;
  List<Player> get players => _players;

  Future<void> loadTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final teamsJson = prefs.getStringList('teams') ?? [];
    final playersJson = prefs.getStringList('players') ?? [];

    _teams = teamsJson
        .map((json) => Team.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();

    _players = playersJson
        .map((json) => Player.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();

    notifyListeners();
  }

  Future<void> addTeam(Team team) async {
    _teams.add(team);
    await _saveTeams();
    notifyListeners();
  }

  Future<void> addPlayer(Player player) async {
    _players.add(player);
    await _savePlayers();
    notifyListeners();
  }

  Future<void> _saveTeams() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'teams',
      _teams.map((team) => team.toJson().toString()).toList(),
    );
  }

  Future<void> _savePlayers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'players',
      _players.map((player) => player.toJson().toString()).toList(),
    );
  }
}
