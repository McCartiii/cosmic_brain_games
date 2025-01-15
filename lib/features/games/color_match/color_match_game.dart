import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import './color_match_constants.dart';

class ColorMatchGame extends StatefulWidget {
  const ColorMatchGame({super.key});

  @override
  State<ColorMatchGame> createState() => _ColorMatchGameState();
}

class _ColorMatchGameState extends State<ColorMatchGame> {
  int score = 0;
  bool isPlaying = false;
  late Timer gameTimer;
  int timeLeft = ColorMatchConstants.gameDurationSeconds;

  Color targetColor = Colors.black;
  Color displayedColor = Colors.black;
  String displayedColorName = '';

  final Random random = Random();

  @override
  void dispose() {
    if (isPlaying) {
      gameTimer.cancel();
    }
    super.dispose();
  }

  void startGame() {
    setState(() {
      isPlaying = true;
      score = 0;
      timeLeft = ColorMatchConstants.gameDurationSeconds;
    });

    generateNewColors();
    startTimer();
  }

  void startTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          endGame();
        }
      });
    });
  }

  void endGame() {
    gameTimer.cancel();
    setState(() {
      isPlaying = false;
    });
    showGameOverDialog();
  }

  void generateNewColors() {
    final List<Color> colors = List.from(ColorMatchConstants.gameColors);

    // Select random target color
    targetColor = colors[random.nextInt(colors.length)];

    // Select random displayed color
    displayedColor = colors[random.nextInt(colors.length)];

    // Select random color name (might not match the displayed color)
    final colorName = colors[random.nextInt(colors.length)];
    displayedColorName = getColorName(colorName);

    setState(() {});
  }

  String getColorName(Color color) {
    if (color == Colors.red) return 'RED';
    if (color == Colors.blue) return 'BLUE';
    if (color == Colors.green) return 'GREEN';
    if (color == Colors.yellow) return 'YELLOW';
    if (color == Colors.purple) return 'PURPLE';
    if (color == Colors.orange) return 'ORANGE';
    return '';
  }

  void handleAnswer(bool matches) {
    bool isCorrect = (targetColor == displayedColor) == matches;

    setState(() {
      if (isCorrect) {
        score += ColorMatchConstants.pointsPerCorrectMatch;
      } else {
        score += ColorMatchConstants.pointsPerWrongMatch;
      }
    });

    generateNewColors();
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'),
        content: Text('Final Score: $score'),
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
              Navigator.of(context).pop(); // Return to game selection
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
        title: const Text('Color Match'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Score: $score',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isPlaying) ...[
              const Text(
                'Match the color with the text!',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: startGame,
                child: const Text('Start Game'),
              ),
            ] else ...[
              Text(
                'Time Left: $timeLeft',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 40),
              Container(
                width: 200,
                height: 100,
                color: targetColor,
                margin: const EdgeInsets.symmetric(vertical: 20),
              ),
              const SizedBox(height: 20),
              Text(
                displayedColorName,
                style: TextStyle(
                  color: displayedColor,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => handleAnswer(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                    ),
                    child: const Text('MATCH'),
                  ),
                  ElevatedButton(
                    onPressed: () => handleAnswer(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                    ),
                    child: const Text('NO MATCH'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
