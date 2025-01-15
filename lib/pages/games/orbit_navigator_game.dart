import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../../models/game_score.dart';
import '../../services/score_manager.dart';

class OrbitNavigatorGame extends StatefulWidget {
  const OrbitNavigatorGame({super.key});

  @override
  State<OrbitNavigatorGame> createState() => _OrbitNavigatorGameState();
}

class _OrbitNavigatorGameState extends State<OrbitNavigatorGame>
    with TickerProviderStateMixin {
  late ScoreManager _scoreManager;
  bool _isPlaying = false;
  int _score = 0;
  int _highScore = 0;
  double _difficulty = 1.0;
  double _survivalTime = 0.0;

  // Game objects
  late Offset _playerPosition;
  List<Projectile> _projectiles = [];
  final Random _random = Random();
  late AnimationController _gameLoopController;

  // Player properties
  final double _playerSize = 30.0;
  bool _isAlive = true;
  double _playerRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _setupAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize player position here
    if (!_isPlaying) {
      final screenSize = MediaQuery.of(context).size;
      _playerPosition = Offset(
        screenSize.width / 2,
        screenSize.height * 0.7,
      );
    }
  }

  void _initializeGame() {
    _scoreManager = Provider.of<ScoreManager>(context, listen: false);
    _updateHighScore();
  }

  void _setupAnimations() {
    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(days: 1), // Runs indefinitely
    )..addListener(_gameLoop);
  }

  void _resetGame() {
    final screenSize = MediaQuery.of(context).size;
    _playerPosition = Offset(
      screenSize.width / 2,
      screenSize.height * 0.7,
    );
    _projectiles.clear();
    _score = 0;
    _difficulty = 1.0;
    _survivalTime = 0.0;
    _isAlive = true;
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _resetGame();
    });
    _gameLoopController.forward();
  }

  void _gameLoop() {
    if (!_isAlive || !_isPlaying) return;

    setState(() {
      // Update survival time and score
      _survivalTime += 0.016; // Approximately 60fps
      _score = (_survivalTime * 10).round();
      _difficulty = 1.0 + (_survivalTime / 10);

      // Update projectiles and spawn new ones
      _updateProjectiles();

      // Check collisions
      _checkCollisions();
    });
  }

  void _updateProjectiles() {
    // Remove offscreen projectiles
    _projectiles.removeWhere((projectile) => projectile.isOffscreen);

    // Spawn new projectiles based on difficulty
    if (_random.nextDouble() < 0.03 * _difficulty) {
      _spawnProjectile();
    }

    // Update projectile positions
    for (var projectile in _projectiles) {
      projectile.update();
    }
  }

  void _spawnProjectile() {
    final screenSize = MediaQuery.of(context).size;
    final spawnSide =
        _random.nextInt(4); // 0: top, 1: right, 2: bottom, 3: left
    late Offset position;
    late Offset velocity;

    switch (spawnSide) {
      case 0: // Top
        position = Offset(_random.nextDouble() * screenSize.width, -20);
        velocity = Offset(
          (_playerPosition.dx - position.dx) / 100,
          (_playerPosition.dy - position.dy) / 100,
        );
        break;
      case 1: // Right
        position = Offset(
            screenSize.width + 20, _random.nextDouble() * screenSize.height);
        velocity = Offset(
          (_playerPosition.dx - position.dx) / 100,
          (_playerPosition.dy - position.dy) / 100,
        );
        break;
      case 2: // Bottom
        position = Offset(
            _random.nextDouble() * screenSize.width, screenSize.height + 20);
        velocity = Offset(
          (_playerPosition.dx - position.dx) / 100,
          (_playerPosition.dy - position.dy) / 100,
        );
        break;
      case 3: // Left
        position = Offset(-20, _random.nextDouble() * screenSize.height);
        velocity = Offset(
          (_playerPosition.dx - position.dx) / 100,
          (_playerPosition.dy - position.dy) / 100,
        );
        break;
    }

    _projectiles.add(Projectile(
      position: position,
      velocity: velocity.scale(3, 3),
      size: 10,
    ));
  }

  void _checkCollisions() {
    for (var projectile in _projectiles) {
      final distance = (projectile.position - _playerPosition).distance;
      if (distance < (_playerSize / 2 + projectile.size / 2)) {
        _handleGameOver();
        break;
      }
    }
  }

  void _handleGameOver() {
    _isAlive = false;
    _gameLoopController.stop();
    _checkHighScore();
    _showGameOverDialog();
  }

  void _checkHighScore() {
    if (_score > _highScore) {
      _scoreManager.addScore(
        GameScore(
          gameType: GameType.orbitNavigator,
          score: _score,
        ),
      );
      _updateHighScore();
    }
  }

  void _updateHighScore() {
    setState(() {
      _highScore = _scoreManager.getHighScore(GameType.orbitNavigator);
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
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Time Survived: ${_survivalTime.toStringAsFixed(1)}s',
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
      body: GestureDetector(
        onPanUpdate: (details) {
          if (_isPlaying && _isAlive) {
            setState(() {
              _playerPosition += details.delta;
              _playerRotation = details.delta.direction;

              // Keep player within bounds
              final screenSize = MediaQuery.of(context).size;
              _playerPosition = Offset(
                _playerPosition.dx
                    .clamp(_playerSize / 2, screenSize.width - _playerSize / 2),
                _playerPosition.dy.clamp(
                    _playerSize / 2, screenSize.height - _playerSize / 2),
              );
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.indigo.shade900,
                Colors.black,
              ],
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

                  // Projectiles
                  ...List.generate(_projectiles.length, (index) {
                    final projectile = _projectiles[index];
                    return Positioned(
                      left: projectile.position.dx - projectile.size / 2,
                      top: projectile.position.dy - projectile.size / 2,
                      child: Container(
                        width: projectile.size,
                        height: projectile.size,
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.shade400.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Player (Brain)
                  Positioned(
                    left: _playerPosition.dx - _playerSize / 2,
                    top: _playerPosition.dy - _playerSize / 2,
                    child: Transform.rotate(
                      angle: _playerRotation,
                      child: CustomPaint(
                        size: Size(_playerSize, _playerSize),
                        painter: BrainShipPainter(),
                      ),
                    ),
                  ),
                ] else ...[
                  // Start screen
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Orbit Navigator',
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
                            backgroundColor: Colors.indigo,
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

  @override
  void dispose() {
    _gameLoopController.dispose();
    super.dispose();
  }
}

class Projectile {
  Offset position;
  final Offset velocity;
  final double size;

  Projectile({
    required this.position,
    required this.velocity,
    required this.size,
  });

  void update() {
    position += velocity;
  }

  bool get isOffscreen {
    return position.dx < -100 ||
        position.dx > 1000 ||
        position.dy < -100 ||
        position.dy > 1000;
  }
}

class BrainShipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.pink.shade200
      ..style = PaintingStyle.fill;

    final path = Path();

    // Left lobe
    path.moveTo(size.width * 0.3, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.3,
      size.width * 0.3,
      size.height * 0.2,
    );
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.1,
      size.width * 0.5,
      size.height * 0.2,
    );

    // Right lobe
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.1,
      size.width * 0.7,
      size.height * 0.2,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.3,
      size.width * 0.7,
      size.height * 0.5,
    );

    // Bottom curve
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.7,
      size.width * 0.3,
      size.height * 0.5,
    );

    canvas.drawPath(path, paint);

    // Add glow effect
    final glowPaint = Paint()
      ..color = Colors.pink.shade200.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
