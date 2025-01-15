import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../../models/game_score.dart';
import '../../services/score_manager.dart';

class PhotonBurstGame extends StatefulWidget {
  const PhotonBurstGame({super.key});

  @override
  State<PhotonBurstGame> createState() => _PhotonBurstGameState();
}

class _PhotonBurstGameState extends State<PhotonBurstGame>
    with TickerProviderStateMixin {
  late ScoreManager _scoreManager;
  bool _isPlaying = false;
  int _score = 0;
  int _highScore = 0;
  double _difficulty = 1.0;

  // Game objects
  List<PhotonDot> _dots = [];
  final Random _random = Random();
  late AnimationController _gameLoopController;

  // Game settings
  final Map<PhotonColor, Color> _colorMap = {
    PhotonColor.red: Colors.red,
    PhotonColor.blue: Colors.blue,
    PhotonColor.green: Colors.green,
    PhotonColor.yellow: Colors.yellow,
  };

  final Map<PhotonColor, SwipeDirection> _colorDirections = {
    PhotonColor.red: SwipeDirection.up,
    PhotonColor.blue: SwipeDirection.right,
    PhotonColor.green: SwipeDirection.down,
    PhotonColor.yellow: SwipeDirection.left,
  };

  // Dot properties
  final double _dotSize = 60.0;
  final double _dotSpawnInterval = 1.5; // seconds
  double _lastSpawnTime = 0.0;
  double _gameTime = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _setupAnimations();
  }

  void _initializeGame() {
    _scoreManager = Provider.of<ScoreManager>(context, listen: false);
    _updateHighScore();
  }

  void _setupAnimations() {
    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )..addListener(_gameLoop);
  }

  void _resetGame() {
    _dots.clear();
    _score = 0;
    _difficulty = 1.0;
    _gameTime = 0.0;
    _lastSpawnTime = 0.0;
    _isPlaying = true;
  }

  void _startGame() {
    setState(() {
      _resetGame();
    });
    _gameLoopController.forward();
  }

  void _gameLoop() {
    if (!_isPlaying) return;

    setState(() {
      _gameTime += 0.016; // Approximately 60fps
      _difficulty = 1.0 + (_gameTime / 20); // Increase difficulty over time

      // Spawn new dots
      if (_gameTime - _lastSpawnTime >= _dotSpawnInterval / _difficulty) {
        _spawnDot();
        _lastSpawnTime = _gameTime;
      }

      // Update existing dots
      for (var dot in _dots) {
        dot.timeRemaining -= 0.016;
        if (dot.timeRemaining <= 0) {
          _handleGameOver();
          break;
        }
      }
    });
  }

  void _spawnDot() {
    final screenSize = MediaQuery.of(context).size;
    final position = Offset(
      _random.nextDouble() * (screenSize.width - _dotSize),
      _random.nextDouble() * (screenSize.height - _dotSize),
    );

    final color =
        PhotonColor.values[_random.nextInt(PhotonColor.values.length)];

    _dots.add(PhotonDot(
      position: position,
      color: color,
      timeRemaining: 3.0, // 3 seconds to swipe
      size: _dotSize,
    ));
  }

  void _handleSwipe(SwipeDirection direction, Offset position) {
    if (!_isPlaying) return;

    // Find the closest dot to the swipe position
    PhotonDot? closestDot;
    double closestDistance = double.infinity;

    for (var dot in _dots) {
      final distance = (dot.position - position).distance;
      if (distance < closestDistance) {
        closestDistance = distance;
        closestDot = dot;
      }
    }

    // Check if the swipe was close enough to a dot
    if (closestDot != null && closestDistance < _dotSize * 1.5) {
      final correctDirection = _colorDirections[closestDot.color]!;

      if (direction == correctDirection) {
        // Correct swipe
        setState(() {
          _score++;
          _dots.remove(closestDot);
        });
      } else {
        // Wrong direction
        _handleGameOver();
      }
    }
  }

  void _handleGameOver() {
    _isPlaying = false;
    _gameLoopController.stop();
    _checkHighScore();
    _showGameOverDialog();
  }

  void _checkHighScore() {
    if (_score > _highScore) {
      _scoreManager.addScore(
        GameScore(
          gameType: GameType.photonBurst,
          score: _score,
        ),
      );
      _updateHighScore();
    }
  }

  void _updateHighScore() {
    setState(() {
      _highScore = _scoreManager.getHighScore(GameType.photonBurst);
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
              'Score: $_score',
              style: const TextStyle(fontSize: 24, color: Colors.white),
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
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          final velocity = details.velocity.pixelsPerSecond;
          if (velocity.dy.abs() > velocity.dx.abs()) {
            _handleSwipe(
              velocity.dy > 0 ? SwipeDirection.down : SwipeDirection.up,
              details.localPosition,
            );
          }
        },
        onHorizontalDragEnd: (details) {
          final velocity = details.velocity.pixelsPerSecond;
          if (velocity.dx.abs() > velocity.dy.abs()) {
            _handleSwipe(
              velocity.dx > 0 ? SwipeDirection.right : SwipeDirection.left,
              details.localPosition,
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey[900]!, Colors.black],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                if (_isPlaying) ...[
                  // Score display
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Text(
                      'Score: $_score',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Direction indicators
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Column(
                      children: [
                        _buildDirectionIndicator(PhotonColor.red, '↑'),
                        _buildDirectionIndicator(PhotonColor.blue, '→'),
                        _buildDirectionIndicator(PhotonColor.green, '↓'),
                        _buildDirectionIndicator(PhotonColor.yellow, '←'),
                      ],
                    ),
                  ),

                  // Dots
                  ..._dots.map((dot) => Positioned(
                        left: dot.position.dx,
                        top: dot.position.dy,
                        child: Container(
                          width: dot.size,
                          height: dot.size,
                          decoration: BoxDecoration(
                            color: _colorMap[dot.color],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _colorMap[dot.color]!.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              dot.timeRemaining.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )),
                ] else ...[
                  // Start screen
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Photon Burst',
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
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionIndicator(PhotonColor color, String arrow) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _colorMap[color]!.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        arrow,
        style: TextStyle(
          color: _colorMap[color],
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gameLoopController.dispose();
    super.dispose();
  }
}

enum PhotonColor {
  red,
  blue,
  green,
  yellow,
}

enum SwipeDirection {
  up,
  right,
  down,
  left,
}

class PhotonDot {
  final Offset position;
  final PhotonColor color;
  final double size;
  double timeRemaining;

  PhotonDot({
    required this.position,
    required this.color,
    required this.timeRemaining,
    required this.size,
  });
}
