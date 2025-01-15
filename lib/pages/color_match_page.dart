import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class ColorMatchPage extends StatefulWidget {
  const ColorMatchPage({super.key});

  @override
  State<ColorMatchPage> createState() => _ColorMatchPageState();
}

class _ColorMatchPageState extends State<ColorMatchPage> {
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  late Color targetColor;
  late Color displayedColor;
  late String displayedText;
  late Timer gameTimer;
  late Timer countdownTimer;

  int score = 0;
  int timeLeft = 60;
  bool isGameOver = false;
  int streak = 0;
  double difficulty = 1.0;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      score = 0;
      timeLeft = 60;
      isGameOver = false;
      streak = 0;
      difficulty = 1.0;
    });
    _generateNewRound();
    _startTimers();
  }

  void _startTimers() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          _endGame();
        }
      });
    });
  }

  void _generateNewRound() {
    final random = math.Random();

    // Select random target color
    targetColor = colors[random.nextInt(colors.length)];

    // Decide if this should be a matching or non-matching round
    bool shouldMatch = random.nextBool();

    if (shouldMatch) {
      // Matching case - color and text match
      displayedColor = targetColor;
      displayedText = _getColorName(targetColor);
    } else {
      // Non-matching case
      do {
        displayedColor = colors[random.nextInt(colors.length)];
        displayedText = _getColorName(colors[random.nextInt(colors.length)]);
      } while (displayedColor == targetColor ||
          _getColorName(displayedColor) == displayedText);
    }
  }

  String _getColorName(Color color) {
    if (color == Colors.red) return 'RED';
    if (color == Colors.blue) return 'BLUE';
    if (color == Colors.green) return 'GREEN';
    if (color == Colors.yellow) return 'YELLOW';
    if (color == Colors.purple) return 'PURPLE';
    if (color == Colors.orange) return 'ORANGE';
    return '';
  }

  void _handleAnswer(bool userSaysMatch) {
    bool isActualMatch = displayedColor == targetColor;

    if (userSaysMatch == isActualMatch) {
      setState(() {
        streak++;
        score += (10 * streak * difficulty).round();
        difficulty += 0.1;
      });
    } else {
      setState(() {
        streak = 0;
        difficulty = math.max(1.0, difficulty - 0.2);
      });
    }

    _generateNewRound();
  }

  void _endGame() {
    countdownTimer.cancel();
    setState(() {
      isGameOver = true;
    });
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
              Colors.blue.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const Spacer(),
              _buildGameContent(),
              const Spacer(),
              _buildControls(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Streak: $streak',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Time: $timeLeft',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    if (isGameOver) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Game Over!\nFinal Score: $score',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _startNewGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
            child: const Text(
              'Play Again',
              style: TextStyle(
                fontSize: 20,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Match the color with the target:',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: targetColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: targetColor.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: displayedColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: displayedColor.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            displayedText,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    if (isGameOver) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => _handleAnswer(false),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
          ),
          child: const Text(
            'No Match',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => _handleAnswer(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
          ),
          child: const Text(
            'Match',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    countdownTimer.cancel();
    super.dispose();
  }
}
