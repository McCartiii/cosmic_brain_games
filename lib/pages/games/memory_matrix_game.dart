import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../../models/game_score.dart';
import '../../services/score_manager.dart';

class MemoryMatrixGame extends StatefulWidget {
  const MemoryMatrixGame({super.key});

  @override
  State<MemoryMatrixGame> createState() => _MemoryMatrixGameState();
}

class _MemoryMatrixGameState extends State<MemoryMatrixGame> {
  late ScoreManager _scoreManager;
  late int _gridSize;
  late List<List<bool>> _grid;
  late List<List<bool>> _playerGrid;
  late List<List<double>> _cellOpacity;
  bool _isShowingPattern = false;
  bool _isPlaying = false;
  int _score = 0;
  int _highScore = 0;
  int _level = 1;
  int _patternCount = 3;
  int _remainingLives = 3;
  bool _canInteract = false;

  int _getGridSizeForLevel(int level) {
    if (level >= 15) return 6;
    if (level >= 10) return 5;
    if (level >= 5) return 4;
    return 3;
  }

  @override
  void initState() {
    super.initState();
    _gridSize = _getGridSizeForLevel(_level);
    _initializeGame();
  }

  void _initializeGame() {
    _scoreManager = Provider.of<ScoreManager>(context, listen: false);
    _updateHighScore();
    _initializeGrids();
  }

  void _initializeGrids() {
    _grid = List.generate(_gridSize, (_) => List.filled(_gridSize, false));
    _playerGrid =
        List.generate(_gridSize, (_) => List.filled(_gridSize, false));
    _cellOpacity = List.generate(_gridSize, (_) => List.filled(_gridSize, 1.0));
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _level = 1;
      _gridSize = _getGridSizeForLevel(_level);
      _patternCount = 3;
      _remainingLives = 3;
      _isPlaying = true;
      _initializeGrids();
    });
    _startNewRound();
  }

  void _clearGrids() {
    for (int i = 0; i < _gridSize; i++) {
      for (int j = 0; j < _gridSize; j++) {
        _grid[i][j] = false;
        _playerGrid[i][j] = false;
        _cellOpacity[i][j] = 1.0;
      }
    }
  }

  void _startNewRound() {
    _clearGrids();
    _generatePattern();
    setState(() {
      _isShowingPattern = true;
      _canInteract = false;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isShowingPattern = false;
          _canInteract = true;
        });
      }
    });
  }

  void _generatePattern() {
    final random = Random();
    int count = 0;
    while (count < _patternCount) {
      int row = random.nextInt(_gridSize);
      int col = random.nextInt(_gridSize);
      if (!_grid[row][col]) {
        _grid[row][col] = true;
        count++;
      }
    }
  }

  void _handleTileTap(int row, int col) {
    if (_isShowingPattern || !_isPlaying || !_canInteract) return;

    setState(() {
      _playerGrid[row][col] = !_playerGrid[row][col];

      if (_grid[row][col] == _playerGrid[row][col]) {
        _cellOpacity[row][col] = 1.0;
      } else {
        _cellOpacity[row][col] = 0.3;
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) {
            setState(() {
              _playerGrid[row][col] = false;
              _cellOpacity[row][col] = 1.0;
            });
          }
        });
      }
    });

    if (_isPatternComplete()) {
      _canInteract = false;
      Future.delayed(const Duration(milliseconds: 500), () {
        _checkPattern();
      });
    }
  }

  bool _isPatternComplete() {
    int playerCount = 0;
    for (var row in _playerGrid) {
      playerCount += row.where((cell) => cell).length;
    }
    return playerCount == _patternCount;
  }

  void _checkPattern() {
    bool isCorrect = true;
    for (int i = 0; i < _gridSize; i++) {
      for (int j = 0; j < _gridSize; j++) {
        if (_grid[i][j] != _playerGrid[i][j]) {
          isCorrect = false;
          break;
        }
      }
    }

    if (isCorrect) {
      _handleCorrectPattern();
    } else {
      _handleIncorrectPattern();
    }
  }

  void _handleCorrectPattern() {
    setState(() {
      _score += _patternCount * 10;
      _level++;

      int newGridSize = _getGridSizeForLevel(_level);
      if (newGridSize != _gridSize) {
        _gridSize = newGridSize;
        _initializeGrids();
      }

      _patternCount = min(3 + (_level ~/ 2), _gridSize * _gridSize - 1);
    });
    _startNewRound();
  }

  void _handleIncorrectPattern() {
    setState(() {
      _remainingLives--;
    });

    if (_remainingLives <= 0) {
      _endGame();
    } else {
      _startNewRound();
    }
  }

  void _endGame() {
    setState(() {
      _isPlaying = false;
    });
    _checkHighScore();
    _showGameOverDialog();
  }

  void _checkHighScore() {
    if (_score > _highScore) {
      _scoreManager.addScore(
        GameScore(
          gameType: GameType.memoryMatrix,
          score: _score,
        ),
      );
      _updateHighScore();
    }
  }

  void _updateHighScore() {
    setState(() {
      _highScore = _scoreManager.getHighScore(GameType.memoryMatrix);
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Game Over',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Final Score: $_score',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Level Reached: $_level',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            if (_score > _highScore)
              const Text(
                'New High Score!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startGame();
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Quit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: _isPlaying ? _buildGameScreen() : _buildStartScreen(),
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final gridSize = min(screenWidth * 0.8, screenHeight * 0.5);

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Center(
            child: SizedBox(
              width: gridSize,
              height: gridSize,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _gridSize,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: _gridSize * _gridSize,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final row = index ~/ _gridSize;
                  final col = index % _gridSize;
                  final isActive = _isShowingPattern
                      ? _grid[row][col]
                      : _playerGrid[row][col];

                  return GestureDetector(
                    onTap: () => _handleTileTap(row, col),
                    child: AnimatedOpacity(
                      opacity: _cellOpacity[row][col],
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.blue.shade400
                              : Colors.blue.shade900.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.shade200.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color:
                                        Colors.blue.shade400.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoColumn('Score', _score.toString()),
          _buildInfoColumn('Level', _level.toString()),
          _buildInfoColumn(
            'Lives',
            '❤️' * _remainingLives,
            _remainingLives == 1 ? Colors.red : null,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, [Color? valueColor]) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Memory Matrix',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'High Score: $_highScore',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Start Game',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
