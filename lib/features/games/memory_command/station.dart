import 'package:flutter/material.dart';
import 'dart:async';
import 'memory_command_constants.dart';

class Station {
  final String name;
  final IconData icon;
  final Duration taskDuration;
  final Color color;

  bool isTaskActive = false;
  bool isTaskComplete = false;
  bool isOverdue = false;
  Timer? _taskTimer;
  Timer? _progressTimer;
  DateTime? _startTime;
  double _progress = 0.0;

  // Constructor
  Station({
    required this.name,
    required this.icon,
    required this.taskDuration,
    required this.color,
  });

  // Getters
  bool get isVisible => isTaskActive && !isTaskComplete;
  String get description =>
      MemoryCommandConstants.stationDescriptions[name] ?? '';

  // Returns progress from 0.0 to 1.0
  double get progress => _progress;

  // Start a new task
  void startTask() {
    if (isTaskActive) return;

    isTaskActive = true;
    isTaskComplete = false;
    isOverdue = false;
    _startTime = DateTime.now();
    _progress = 0.0;

    // Cancel any existing timers
    _taskTimer?.cancel();
    _progressTimer?.cancel();

    // Start the task completion timer
    _taskTimer = Timer(taskDuration, () {
      isTaskComplete = true;
      _updateProgress();
    });

    // Start progress update timer
    _progressTimer = Timer.periodic(
      MemoryCommandConstants.progressBarUpdateInterval,
      (_) => _updateProgress(),
    );
  }

  // Update the progress value
  void _updateProgress() {
    if (!isTaskActive || _startTime == null) return;

    final elapsed = DateTime.now().difference(_startTime!);
    final newProgress = (elapsed.inMilliseconds / taskDuration.inMilliseconds)
        .clamp(0.0, MemoryCommandConstants.lateThreshold);

    if (newProgress >= 1.0) {
      isOverdue = true;
    }

    _progress = newProgress;
  }

  // Check if the task was completed with perfect timing
  bool isPerfectTiming() {
    if (!isTaskComplete || _startTime == null) return false;

    final elapsed = DateTime.now().difference(_startTime!);
    final ratio = elapsed.inMilliseconds / taskDuration.inMilliseconds;

    // Perfect timing is considered between 0.95 and 1.05 of the target duration
    return ratio >= 0.95 && ratio <= 1.05;
  }

  // Reset the station
  void resetTask() {
    isTaskActive = false;
    isTaskComplete = false;
    isOverdue = false;
    _startTime = null;
    _progress = 0.0;
    _taskTimer?.cancel();
    _progressTimer?.cancel();
  }

  // Clean up resources
  void dispose() {
    _taskTimer?.cancel();
    _progressTimer?.cancel();
  }

  // Get the current status text
  String getStatusText() {
    if (!isTaskActive) return MemoryCommandConstants.stationReady;
    if (isTaskComplete) return MemoryCommandConstants.perfectTiming;
    if (isOverdue) return MemoryCommandConstants.tooLate;
    return '${(_progress * 100).toInt()}%';
  }

  // Get the appropriate color for the current state
  Color getStatusColor() {
    if (!isTaskActive) return Colors.green;
    if (isTaskComplete) return Colors.blue;
    if (isOverdue) return Colors.red;
    return color;
  }

  @override
  String toString() =>
      'Station($name, active: $isTaskActive, complete: $isTaskComplete)';
}
