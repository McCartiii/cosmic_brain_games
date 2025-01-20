import 'package:flutter/material.dart';
import 'memory_command/memory_command_game.dart';
import 'memory_command/memory_command_constants.dart';
import 'photon_burst/photon_burst_game.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

enum GameType {
  memoryCommand,
  photonBurst,
  colormatch,
  focuspulse,
  memorymatrix,
  memorytrail,
  orbitnavigator,
}

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
                description:
                    'Manage multiple stations and track hidden timers!',
                color: const Color(0xFF2196F3),
                icon: Icons.memory,
                difficulty: 'Strategic',
                game: GameType.memoryCommand,
              ),
              _buildGameCard(
                context,
                title: 'Photon Burst',
                description: 'Test your reflexes by tapping moving targets!',
                color: const Color(0xFFE91E63),
                icon: Icons.blur_circular,
                difficulty: 'Reflexes',
                game: GameType.photonBurst,
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
    required IconData icon,
    required String difficulty,
    required GameType game,
  }) {
    return Hero(
      tag: title,
      child: Card(
        elevation: 8,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showDifficultyDialog(context, game),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    color.withOpacity(0.8),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Icon(
                      icon,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      difficulty,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context, GameType game) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Select Difficulty',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDifficultyButton(
                    context,
                    'Easy',
                    game == GameType.memoryCommand
                        ? 'Longer timers, more forgiving'
                        : 'Slower targets, more time',
                    Difficulty.easy,
                    Colors.green,
                    game: game,
                  ),
                  const SizedBox(height: 8),
                  _buildDifficultyButton(
                    context,
                    'Normal',
                    'Balanced challenge',
                    Difficulty.normal,
                    Colors.blue,
                    game: game,
                  ),
                  const SizedBox(height: 8),
                  _buildDifficultyButton(
                    context,
                    'Hard',
                    game == GameType.memoryCommand
                        ? 'Quick timers, high pressure'
                        : 'Fast targets, quick reactions needed',
                    Difficulty.hard,
                    Colors.red,
                    game: game,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    String title,
    String description,
    Difficulty difficulty,
    Color color, {
    required GameType game,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 200),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withOpacity(0.8),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return game == GameType.photonBurst
                      ? PhotonBurstGame(difficulty: difficulty)
                      : MemoryCommandGame(difficulty: difficulty);
                },
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
