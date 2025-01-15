import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../../models/game_score.dart';
import '../../services/score_manager.dart';

class ColorMatchGame extends StatefulWidget {
  const ColorMatchGame({super.key});

  @override
  State<ColorMatchGame> createState() => _ColorMatchGameState();
}

class _ColorMatchGameState extends State<ColorMatchGame>
    with TickerProviderStateMixin {
  late ScoreManager _scoreManager;
  late Timer _gameTimer;
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  Color _targetColor = Colors.white;
  Color _displayedText = Colors.white;
  String _colorText = '';
  int _score = 0;
  int _highScore = 0;
  int _timeLeft = 60;
  bool _isPlaying = false;
  int _streak = 0;
  int _bestStreak = 0;

  // Animation controllers
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Bounce animation for text
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));

    // Glow animation for color box
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 2.0, end: 15.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  void _initializeGame() {
    _scoreManager = Provider.of<ScoreManager>(context, listen: false);
    _updateHighScore();
  }

  void _updateHighScore() {
    setState(() {
      _highScore = _scoreManager.getHighScore(GameType.colorMatch);
    });
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 60;
      _isPlaying = true;
      _streak = 0;
      _bestStreak = 0;
    });
    _generateNewRound();
    _startTimer();
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _endGame();
        }
      });
    });
  }

  void _generateNewRound() {
    final random = Random();
    final targetColorIndex = random.nextInt(_colors.length);
    final displayedTextIndex = random.nextInt(_colors.length);
    final colorNames = ['Red', 'Blue', 'Green', 'Yellow', 'Purple', 'Orange'];

    setState(() {
      _targetColor = _colors[targetColorIndex];
      _displayedText = _colors[displayedTextIndex];
      _colorText = colorNames[displayedTextIndex];
    });
    _bounceController.forward(from: 0.0);
  }

  void _handleAnswer(bool matches) {
    final bool isCorrect = (matches && _targetColor == _displayedText) ||
        (!matches && _targetColor != _displayedText);

    if (isCorrect) {
      setState(() {
        _streak++;
        _bestStreak = max(_streak, _bestStreak);
        _score += 10 + (_streak > 1 ? _streak * 2 : 0);
      });
    } else {
      setState(() {
        _streak = 0;
        _score = max(0, _score - 5);
      });
    }

    _generateNewRound();
  }

  void _endGame() {
    _gameTimer.cancel();
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
          gameType: GameType.colorMatch,
          score: _score,
        ),
      );
      _updateHighScore();
    }
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    _bounceController.dispose();
    _glowController.dispose();
    super.dispose();
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
            Text(
              'Best Streak: $_bestStreak',
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
              Colors.deepPurple.shade900,
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
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: _targetColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _targetColor.withOpacity(0.5),
                            blurRadius: _glowAnimation.value,
                            spreadRadius: _glowAnimation.value / 2,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                ScaleTransition(
                  scale: _bounceAnimation,
                  child: Text(
                    _colorText,
                    style: TextStyle(
                      color: _displayedText,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: _displayedText.withOpacity(0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildGameButton(
                        'Match', Colors.green, () => _handleAnswer(true)),
                    _buildGameButton(
                        'No Match', Colors.red, () => _handleAnswer(false)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoColumn('Score', _score.toString()),
          _buildInfoColumn('Time', _timeLeft.toString()),
          if (_streak > 1)
            _buildInfoColumn('Streak', _streak.toString(), Colors.green),
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

  Widget _buildGameButton(String text, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Color Match',
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
          _buildGameButton('Start Game', Colors.blue, _startGame),
        ],
      ),
    );
  }
}
