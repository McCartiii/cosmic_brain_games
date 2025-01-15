import 'package:flutter/material.dart';
import 'games/color_match_game.dart';
import 'games/memory_matrix_game.dart';
import 'games/photon_burst_game.dart';
import 'games/orbit_navigator_game.dart';

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cosmic Brain Games'),
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _GameCard(
            title: 'Color Match',
            description: 'Test your color perception and quick thinking!',
            icon: Icons.palette,
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ColorMatchGame()),
            ),
          ),
          _GameCard(
            title: 'Memory Matrix',
            description: 'Challenge your spatial memory!',
            icon: Icons.grid_on,
            color: Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MemoryMatrixGame()),
            ),
          ),
          _GameCard(
            title: 'Photon Burst',
            description: 'Test your reflexes in space!',
            icon: Icons.blur_circular,
            color: Colors.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PhotonBurstGame()),
            ),
          ),
          _GameCard(
            title: 'Orbit Navigator',
            description: 'Navigate through orbital challenges!',
            icon: Icons.track_changes,
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const OrbitNavigatorGame()),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
