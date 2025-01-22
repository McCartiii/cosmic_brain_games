import 'package:flutter/material.dart';

class MemoryCommandResults extends StatelessWidget {
  final int score;
  final int maxScore;
  final int tasksCompleted;
  final int perfectTasks;
  final int totalTasks; // Added this
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const MemoryCommandResults({
    super.key,
    required this.score,
    required this.maxScore,
    required this.tasksCompleted,
    required this.perfectTasks,
    this.totalTasks = 0, // Optional with default value
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game Over',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Final Score: $score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tasks Completed: $tasksCompleted',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            Text(
              'Perfect Tasks: $perfectTasks',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            if (totalTasks > 0)
              Text(
                'Total Tasks: $totalTasks',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Best Score: $maxScore',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Restart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: onExit,
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Exit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
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
    );
  }
}
