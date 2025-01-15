import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import './memory_matrix_constants.dart';

class MemoryMatrixGame extends StatefulWidget {
  const MemoryMatrixGame({super.key});

  @override
  State<MemoryMatrixGame> createState() => _MemoryMatrixGameState();
}

class _MemoryMatrixGameState extends State<MemoryMatrixGame> {
  late int gridSize;
  late List<List<bool>> pattern;
  late List<List<bool>> userPattern;
  bool isDisplaying = false;
  bool isPlaying = false;
  int score = 0;
  int lives = MemoryMatrixConstants.livesPerGame;
  int cellsSelected = 0;
  int totalCellsToSelect = 0;
  final Random random = Random();

  // User management
  late User currentUser;
  bool isNewHighScore = false;

  String? _message;
  Color _messageColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    currentUser = User(
      name: 'Player',
      scores: [],
      currentLevel: MemoryMatrixConstants.initialGridSize,
    );
    gridSize = currentUser.currentLevel;
    _initializePatterns();
  }

  void _initializePatterns() {
    pattern = List.generate(
      gridSize,
      (_) => List.generate(gridSize, (_) => false),
    );
    userPattern = List.generate(
      gridSize,
      (_) => List.generate(gridSize, (_) => false),
    );
    cellsSelected = 0;
  }

  void startGame() {
    setState(() {
      isPlaying = true;
      score = 0;
      lives = MemoryMatrixConstants.livesPerGame;
      gridSize = currentUser.currentLevel;
      _initializePatterns();
      _message = null;
      isNewHighScore = false;
    });
    _startNewRound();
  }

  void _startNewRound() {
    _generatePattern();
    _displayPattern();
  }

  void _generatePattern() {
    pattern = List.generate(
      gridSize,
      (_) => List.generate(gridSize, (_) => false),
    );

    totalCellsToSelect = gridSize + 1;
    int cellsToFill = totalCellsToSelect;
    while (cellsToFill > 0) {
      int row = random.nextInt(gridSize);
      int col = random.nextInt(gridSize);
      if (!pattern[row][col]) {
        pattern[row][col] = true;
        cellsToFill--;
      }
    }

    userPattern = List.generate(
      gridSize,
      (_) => List.generate(gridSize, (_) => false),
    );
    cellsSelected = 0;
  }

  void _displayPattern() {
    setState(() {
      isDisplaying = true;
      _message = "Watch carefully!";
      _messageColor = Colors.blue;
    });

    Future.delayed(MemoryMatrixConstants.patternShowDuration, () {
      if (mounted) {
        setState(() {
          isDisplaying = false;
          _message = "Now recreate the pattern!";
          _messageColor = Colors.green;
        });
      }
    });
  }

  void _handleCellTap(int row, int col) {
    if (isDisplaying || !isPlaying) return;
    if (userPattern[row][col]) return;

    setState(() {
      userPattern[row][col] = true;
      cellsSelected++;

      if (!pattern[row][col]) {
        // Wrong cell selected
        _message = "Wrong cell! Game Over!";
        _messageColor = Colors.red;
        Future.delayed(const Duration(milliseconds: 500), () {
          _gameOver();
        });
        return;
      }

      // Check if all correct cells have been selected
      if (cellsSelected == totalCellsToSelect) {
        score += MemoryMatrixConstants.pointsPerCorrectPattern;
        _message = "Perfect! Next level!";
        _messageColor = Colors.green;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (gridSize < MemoryMatrixConstants.maxGridSize) {
            gridSize++;
          }
          _startNewRound();
        });
      }
    });
  }

  void _gameOver() {
    setState(() {
      isPlaying = false;
      currentUser.updateScores(score);
      isNewHighScore = currentUser.scores.isNotEmpty &&
          score >= currentUser.scores.reduce((a, b) => a > b ? a : b);
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isNewHighScore ? '🎉 New High Score! 🎉' : 'Game Over!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $score',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Level: ${MemoryMatrixConstants.levelNames[gridSize]}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 15),
            Text(
              'Average Score: ${currentUser.calculateAverageScore().toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 16),
            ),
            if (isNewHighScore)
              const Padding(
                padding: EdgeInsets.only(top: 15),
                child: Text(
                  'Congratulations on the new high score!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              startGame();
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Matrix'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Score: $score',
                        style: const TextStyle(fontSize: 18),
                      ),
                      if (currentUser.scores.isNotEmpty)
                        Text(
                          'Best: ${currentUser.scores.reduce((a, b) => a > b ? a : b)}',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.yellow),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.withOpacity(0.1),
              Colors.purple.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isPlaying) ...[
                  const Text(
                    'Memory Matrix',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Test your memory by remembering and recreating patterns!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: startGame,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Start Game',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Level: ${MemoryMatrixConstants.levelNames[gridSize]}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Row(
                        children: List.generate(
                          lives,
                          (index) => const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2),
                            child: Icon(Icons.favorite,
                                color: Colors.red, size: 28),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_message != null)
                    AnimatedOpacity(
                      opacity: _message != null ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _message!,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _messageColor,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridSize,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: gridSize * gridSize,
                        itemBuilder: (context, index) {
                          final row = index ~/ gridSize;
                          final col = index % gridSize;
                          final isSelected = isDisplaying
                              ? pattern[row][col]
                              : userPattern[row][col];

                          return AnimatedContainer(
                            duration: MemoryMatrixConstants.patternFadeDuration,
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue
                                      .withOpacity(isDisplaying ? 0.8 : 1.0)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? Colors.blue
                                          .withOpacity(isDisplaying ? 0.3 : 0.0)
                                      : Colors.transparent,
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _handleCellTap(row, col),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
