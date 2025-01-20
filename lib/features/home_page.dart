import 'package:flutter/material.dart';
import '../widgets/animated_stars_background.dart';
import 'games/game_selection_screen.dart';
import 'teams/teams_hub_screen.dart';
import 'leaderboard/leaderboard_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedStarsBackground(),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with reduced glow
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 150,
                    height: 150,
                  ),
                ),
                const SizedBox(height: 40),

                // Game Selection Button
                _buildMenuButton(
                  context,
                  'Play Games',
                  Icons.games,
                  Colors.deepPurple.shade400,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameSelectionScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Teams Button
                _buildMenuButton(
                  context,
                  'Teams',
                  Icons.group,
                  Colors.blue.shade400,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TeamsHubScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Leaderboard Button
                _buildMenuButton(
                  context,
                  'Leaderboard',
                  Icons.leaderboard,
                  Colors.amber.shade400,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LeaderboardScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
