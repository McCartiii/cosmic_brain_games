import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'memory_command/memory_command_game.dart';
import 'memory_command/memory_command_constants.dart' as memory_command;
import 'photon_burst/photon_burst_game.dart';
import 'photon_burst/photon_burst_constants.dart' as photon_burst;

enum GameType {
  memoryCommand,
  photonBurst,
}

enum Difficulty { easy, normal, hard }

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          'Cosmic Brain Games',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimationLimiter(
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16),
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: widget,
              ),
            ),
            children: [
              _buildGameCard(
                context,
                title: 'Memory Command',
                description: 'Test your memory and multitasking skills!',
                color: Colors.blue,
                gameType: GameType.memoryCommand,
              ),
              _buildGameCard(
                context,
                title: 'Photon Burst',
                description: 'Fast-paced target shooting challenge!',
                color: Colors.purple,
                gameType: GameType.photonBurst,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String description,
    required Color color,
    required GameType gameType,
  }) {
    return Card(
      color: color.withOpacity(0.2),
      child: InkWell(
        onTap: () => _showDifficultyDialog(context, gameType),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context, GameType gameType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            'Select Difficulty',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: Difficulty.values.map((difficulty) {
              return ListTile(
                title: Text(
                  difficulty.name.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToGame(context, gameType, difficulty);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _navigateToGame(
      BuildContext context, GameType gameType, Difficulty difficulty) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return gameType == GameType.memoryCommand
              ? MemoryCommandGame(
                  difficulty:
                      memory_command.Difficulty.values[difficulty.index])
              : PhotonBurstGame(
                  difficulty: photon_burst.Difficulty.values[difficulty.index]);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }
}
