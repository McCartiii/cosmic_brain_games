import 'package:flutter/material.dart';
import 'color_match/color_match_game.dart';
import 'memory_matrix/memory_matrix_game.dart';
import 'photon_burst/photon_burst_game.dart';

class Game {
  final String name;
  final String description;
  final IconData icon;
  final Widget Function() game;
  final Color color;

  Game({
    required this.name,
    required this.description,
    required this.icon,
    required this.game,
    required this.color,
  });
}

final List<Game> games = [
  Game(
    name: 'Color Match',
    description: 'Test your reflexes by matching colors!',
    icon: Icons.palette,
    game: () => const ColorMatchGame(),
    color: Colors.blue,
  ),
  Game(
    name: 'Memory Matrix',
    description: 'Remember and recreate patterns!',
    icon: Icons.grid_4x4,
    game: () => const MemoryMatrixGame(),
    color: Colors.purple,
  ),
  Game(
    name: 'Photon Burst',
    description: 'Catch photons with arrow keys in this cosmic challenge!',
    icon: Icons.flash_on,
    game: () => const PhotonBurstGame(),
    color: Colors.deepPurple,
  ),
];
