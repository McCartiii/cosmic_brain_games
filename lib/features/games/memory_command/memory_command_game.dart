import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' show max;
import 'memory_command_constants.dart';
import 'station.dart';
import 'memory_command_results.dart';

class MemoryCommandGame extends StatefulWidget {
  final Difficulty difficulty;
  final Function(int score)? onComplete;

  const MemoryCommandGame({
    super.key,
    this.difficulty = Difficulty.normal,
    this.onComplete,
  });

  @override
  State<MemoryCommandGame> createState() => _MemoryCommandGameState();
}

class _MemoryCommandGameState extends State<MemoryCommandGame>
    with SingleTickerProviderStateMixin {
  late List<Station> stations;
  late Timer gameTimer;
  late AnimationController _feedbackController;
  late PageController _pageController;

  int currentStationIndex = 0;
  int score = 0;
  int streak = 0;
  int timeRemaining = 60;
  int tasksCompleted = 0;
  int perfectTasks = 0;
  bool isGameActive = false;
  bool showResults = false;

  Color? _feedbackColor;
  String? _feedbackMessage;

  @override
  void initState() {
    super.initState();
    initializeStations();

    _feedbackController = AnimationController(
      vsync: this,
      duration: MemoryCommandConstants.feedbackDuration,
    );

    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.8,
    );
  }

  void initializeStations() {
    final timers = MemoryCommandConstants.stationTimers[widget.difficulty]!;
    stations = [
      Station(
        name: 'Energy Generator',
        icon: Icons.bolt,
        taskDuration: timers.energyGenerator,
        color: Colors.yellow,
      ),
      Station(
        name: 'Data Uplink',
        icon: Icons.cloud_upload,
        taskDuration: timers.dataUplink,
        color: Colors.blue,
      ),
      Station(
        name: 'Storage Depot',
        icon: Icons.inventory,
        taskDuration: timers.storageDepot,
        color: Colors.orange,
      ),
    ];
  }

  void startGame() {
    setState(() {
      isGameActive = true;
      timeRemaining = 60;
      score = 0;
      streak = 0;
      tasksCompleted = 0;
      perfectTasks = 0;
      showResults = false;
    });

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeRemaining--;
        if (timeRemaining <= 0) {
          endGame();
        }
      });
    });
  }

  void endGame() {
    gameTimer.cancel();
    setState(() {
      isGameActive = false;
      showResults = true;
    });
    widget.onComplete?.call(score);
  }

  void restartGame() {
    setState(() {
      showResults = false;
      stations.forEach((station) => station.resetTask());
    });
    startGame();
  }

  void exitGame() {
    Navigator.of(context).pop();
  }

  void switchStation(int direction) {
    final newIndex =
        (currentStationIndex + direction + stations.length) % stations.length;
    _pageController.animateToPage(
      newIndex,
      duration: MemoryCommandConstants.switchStationDuration,
      curve: Curves.easeInOut,
    );
    setState(() {
      currentStationIndex = newIndex;
    });
  }

  void showFeedback({required Color color, required String message}) {
    setState(() {
      _feedbackColor = color;
      _feedbackMessage = message;
    });
    _feedbackController.forward(from: 0).then((_) {
      _feedbackController.reverse();
    });
  }

  void startStationTask() {
    final station = stations[currentStationIndex];
    if (!station.isTaskActive) {
      setState(() {
        station.startTask();
      });
    }
  }

  void collectOutput() {
    final station = stations[currentStationIndex];
    if (station.isTaskComplete) {
      setState(() {
        score += MemoryCommandConstants.basePoints +
            (streak * MemoryCommandConstants.streakBonus);
        streak++;
        tasksCompleted++;
        perfectTasks++;
        station.resetTask();
      });
      showFeedback(
        color: Colors.green,
        message: MemoryCommandConstants.perfectTiming,
      );
    } else if (station.isTaskActive) {
      tasksCompleted++;
      if (station.progress < 1.0) {
        setState(() {
          score = max(0, score + MemoryCommandConstants.earlyPenalty);
          streak = 0;
        });
        showFeedback(
          color: Colors.red,
          message: MemoryCommandConstants.tooEarly,
        );
      } else {
        setState(() {
          score = max(0, score + MemoryCommandConstants.latePenalty);
          streak = 0;
        });
        showFeedback(
          color: Colors.orange,
          message: MemoryCommandConstants.tooLate,
        );
      }
      station.resetTask();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MemoryCommandConstants.backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildStationDisplay(),
                ),
                _buildControls(),
              ],
            ),
          ),
          // Feedback overlay
          AnimatedBuilder(
            animation: _feedbackController,
            builder: (context, child) {
              return _feedbackController.value > 0
                  ? Container(
                      color: _feedbackColor?.withOpacity(0.3),
                      child: Center(
                        child: Text(
                          _feedbackMessage ?? '',
                          style: TextStyle(
                            color: _feedbackColor,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
          // Results overlay
          if (showResults)
            MemoryCommandResults(
              score: score,
              tasksCompleted: tasksCompleted,
              perfectTasks: perfectTasks,
              onRestart: restartGame,
              onExit: exitGame,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Score: $score',
            style: MemoryCommandConstants.scoreStyle,
          ),
          Text(
            'Time: $timeRemaining',
            style: MemoryCommandConstants.timerStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildStationDisplay() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          currentStationIndex = index;
        });
      },
      itemCount: stations.length,
      itemBuilder: (context, index) {
        final station = stations[index];
        return AnimatedOpacity(
          duration: MemoryCommandConstants.switchStationDuration,
          opacity: index == currentStationIndex ? 1.0 : 0.6,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MemoryCommandConstants.stationBackgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: station.color.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  station.icon,
                  size: 80,
                  color: station.color,
                ),
                const SizedBox(height: 16),
                Text(
                  station.name,
                  style: MemoryCommandConstants.stationNameStyle,
                ),
                if (station.isTaskActive && station.isVisible) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: station.progress,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(station.color),
                      minHeight: 8,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    final station = stations[currentStationIndex];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_left, color: Colors.white),
            onPressed: () => switchStation(-1),
          ),
          if (!isGameActive)
            ElevatedButton(
              onPressed: startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Start Game'),
            )
          else if (!station.isTaskActive)
            ElevatedButton(
              onPressed: startStationTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Start Task'),
            )
          else
            ElevatedButton(
              onPressed: collectOutput,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Collect Output'),
            ),
          IconButton(
            icon: const Icon(Icons.arrow_right, color: Colors.white),
            onPressed: () => switchStation(1),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _pageController.dispose();
    if (isGameActive) {
      gameTimer.cancel();
    }
    stations.forEach((station) => station.dispose());
    super.dispose();
  }
}
