import 'package:flutter/material.dart';
import 'memory_command_constants.dart';

class MemoryCommandResults extends StatelessWidget {
  final int score;
  final int tasksCompleted;
  final int perfectTasks;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const MemoryCommandResults({
    super.key,
    required this.score,
    required this.tasksCompleted,
    required this.perfectTasks,
    required this.onRestart,
    required this.onExit,
  });

  String get efficiencyRating {
    final efficiency = perfectTasks / (tasksCompleted > 0 ? tasksCompleted : 1);
    if (efficiency >= 0.8) return 'Master Commander!';
    if (efficiency >= 0.6) return 'Expert Operator';
    if (efficiency >= 0.4) return 'Skilled Technician';
    if (efficiency >= 0.2) return 'Trainee Officer';
    return 'Needs Practice';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MemoryCommandConstants.backgroundColor.withOpacity(0.9),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: MemoryCommandConstants.stationBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.blue.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Mission Complete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildStatRow('Final Score', score.toString()),
              _buildStatRow('Tasks Completed', tasksCompleted.toString()),
              _buildStatRow('Perfect Timing', perfectTasks.toString()),
              const SizedBox(height: 16),
              Text(
                efficiencyRating,
                style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: onRestart,
                    icon: const Icon(Icons.replay),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: onExit,
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('Exit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
