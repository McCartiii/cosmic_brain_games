import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class MemoryMatrixPage extends StatefulWidget {
  const MemoryMatrixPage({super.key});

  @override
  State<MemoryMatrixPage> createState() => _MemoryMatrixPageState();
}

class _MemoryMatrixPageState extends State<MemoryMatrixPage> {
  int gridSize = 3;
  List<bool> grid = [];
  List<bool> playerGrid = [];
  bool isShowingPattern = true;
  int score = 0;
  int level = 1;
  bool isGameOver = false;
  late Timer patternTimer;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      gridSize = 3;
      score = 0;
      level = 1;
      isGameOver = false;
      _generateNewPattern();
    });
  }

  void _generateNewPattern() {
    setState(() {
      grid = List.generate(
        gridSize * gridSize,
        (index) => math.Random().nextDouble() < 0.4,
      );
      playerGrid = List.generate(gridSize * gridSize, (index) => false);
      isShowingPattern = true;
    });

    patternTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isShowingPattern = false;
        });
      }
    });
  }

  void _checkPattern() {
    bool isCorrect = true;
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] != playerGrid[i]) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect) {
      setState(() {
        score += 100 * level;
        level++;
        if (level % 2 == 0 && gridSize < 6) {
          gridSize++;
        }
      });
      _generateNewPattern();
    } else {
      setState(() {
        isGameOver = true;
      });
    }
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
              Colors.purple.shade900,
              Colors.purple.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const Spacer(),
              _buildGrid(),
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
                'Level: $level',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gridSize * gridSize,
          itemBuilder: (context, index) {
            return _buildGridItem(index);
          },
        ),
      ),
    );
  }

  Widget _buildGridItem(int index) {
    bool isActive = isShowingPattern ? grid[index] : playerGrid[index];

    return GestureDetector(
      onTap: () {
        if (!isShowingPattern && !isGameOver) {
          setState(() {
            playerGrid[index] = !playerGrid[index];
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
      ),
    );
  }

  Widget _buildControls() {
    if (isGameOver) {
      return Column(
        children: [
          Text(
            'Game Over!\nFinal Score: $score',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
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
                color: Colors.purple,
              ),
            ),
          ),
        ],
      );
    }

    return Visibility(
      visible: !isShowingPattern,
      child: ElevatedButton(
        onPressed: _checkPattern,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
        ),
        child: const Text(
          'Check Pattern',
          style: TextStyle(
            fontSize: 20,
            color: Colors.purple,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    patternTimer.cancel();
    super.dispose();
  }
}
