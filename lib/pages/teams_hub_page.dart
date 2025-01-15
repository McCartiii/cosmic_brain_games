import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/team_manager.dart';
import '../models/team.dart';
import '../models/player.dart';

class TeamsHubPage extends StatelessWidget {
  const TeamsHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Hub'),
        centerTitle: true,
      ),
      body: Consumer<TeamManager>(
        builder: (context, teamManager, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _TeamMemberCard(
                name: 'Carter Church',
                role: 'Lead Developer',
                description:
                    'Computer Science student at the University of Utah, passionate about game development and AI.',
                imageUrl: 'assets/images/carter.jpg',
              ),
              // Add more team members here
            ],
          );
        },
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String description;
  final String imageUrl;

  const _TeamMemberCard({
    required this.name,
    required this.role,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(imageUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        role,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
