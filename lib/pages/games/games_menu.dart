import 'package:flutter/material.dart';

class GamesMenu extends StatelessWidget {
  const GamesMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildGameCard(
            context,
            'Color Match',
            'Test your color perception',
            '/color_match',
            Colors.blue,
          ),
          _buildGameCard(
            context,
            'Memory Matrix',
            'Challenge your memory',
            '/memory_matrix',
            Colors.green,
          ),
          _buildGameCard(
            context,
            'Photon Burst',
            'Test your reflexes',
            '/photon_burst',
            Colors.purple,
          ),
          _buildGameCard(
            context,
            'Orbit Navigator',
            'Navigate through space',
            '/orbit_navigator',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, String title, String description,
      String route, Color color) {
    return Card(
      elevation: 4,
      color: color.withOpacity(0.2),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
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
