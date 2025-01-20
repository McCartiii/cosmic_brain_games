import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'focus_pulse_constants.dart';

class FocusPulseGame extends StatefulWidget {
  const FocusPulseGame({super.key});

  @override
  State<FocusPulseGame> createState() => _FocusPulseGameState();
}

class _FocusPulseGameState extends State<FocusPulseGame>
    with SingleTickerProviderStateMixin {
  final Random random = Random();
  late GameRule currentRule;
  List<Target> targets = [];
  int score = 0;
  int streak = 0;
  int consecutiveErrors = 0;
  int currentLevel = 1;
  int roundsCompleted = 0;
  double scoreMultiplier = FocusPulseConstants.initialScoreMultiplier;
  GameState gameState = GameState.menu;
  RoundPhase roundPhase = RoundPhase.instruction;
  Timer? gameTimer;
  Timer? phaseTimer;
  Timer? warningTimer;
  double gameSpeed = 1.0;
  int gridSize = FocusPulseConstants.initialGridSize;
  Map<int, bool> feedbackMap = {};

  late final AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: FocusPulseConstants.feedbackDuration,
    );
    currentRule = FocusPulseConstants.basicRules[0];
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    phaseTimer?.cancel();
    warningTimer?.cancel();
    _feedbackController.dispose();
    super.dispose();
  }

  void startGame() {
    setState(() {
      score = 0;
      streak = 0;
      consecutiveErrors = 0;
      currentLevel = 1;
      roundsCompleted = 0;
      scoreMultiplier = FocusPulseConstants.initialScoreMultiplier;
      gameState = GameState.playing;
      roundPhase = RoundPhase.instruction;
      gameSpeed = 1.0;
      gridSize = FocusPulseConstants.initialGridSize;
      targets.clear();
      feedbackMap.clear();
      currentRule = FocusPulseConstants
          .basicRules[random.nextInt(FocusPulseConstants.basicRules.length)];
    });

    startInstructionPhase();
  }

  void startInstructionPhase() {
    setState(() {
      roundPhase = RoundPhase.instruction;
      targets.clear();
    });

    phaseTimer = Timer(FocusPulseConstants.instructionPhaseDuration, () {
      if (mounted) {
        startActionPhase();
      }
    });
  }

  void startActionPhase() {
    setState(() {
      roundPhase = RoundPhase.action;
      targets.clear();
      spawnTargets();
    });

    startGameLoop();

    phaseTimer = Timer(FocusPulseConstants.actionPhaseDuration, () {
      if (mounted) {
        endActionPhase();
      }
    });
  }

  void endActionPhase() {
    gameTimer?.cancel();

    setState(() {
      roundsCompleted++;
      if (roundsCompleted >= FocusPulseConstants.roundsPerLevel) {
        currentLevel++;
        roundsCompleted = 0;
        gameSpeed += FocusPulseConstants.speedIncreasePerLevel;
        if (gridSize < FocusPulseConstants.maxGridSize) {
          gridSize++;
        }
      }
    });

    startPausePhase();
  }

  void startPausePhase() {
    setState(() {
      roundPhase = RoundPhase.pause;
      targets.clear();
    });

    phaseTimer = Timer(FocusPulseConstants.pausePhaseDuration, () {
      if (mounted && gameState == GameState.playing) {
        currentRule = FocusPulseConstants
            .basicRules[random.nextInt(FocusPulseConstants.basicRules.length)];
        startInstructionPhase();
      }
    });
  }

  void startGameLoop() {
    gameTimer?.cancel();

    gameTimer = Timer.periodic(
        Duration(
            milliseconds:
                (FocusPulseConstants.baseTargetDuration.inMilliseconds /
                        gameSpeed)
                    .round()), (timer) {
      if (mounted &&
          gameState == GameState.playing &&
          roundPhase == RoundPhase.action) {
        setState(() {
          if (targets.isEmpty || targets.length < gridSize) {
            spawnTargets();
          }
          feedbackMap.clear();
        });
      } else {
        timer.cancel();
      }
    });
  }

  void showWarning() {
    setState(() {
      gameState = GameState.warning;
      scoreMultiplier = FocusPulseConstants.initialScoreMultiplier;
    });

    warningTimer = Timer(FocusPulseConstants.warningDuration, () {
      if (mounted) {
        setState(() {
          gameState = GameState.playing;
        });
      }
    });
  }

  void onTargetTapped(Target target) {
    if (gameState != GameState.playing || roundPhase != RoundPhase.action)
      return;

    bool isCorrect = currentRule.isValidTarget(target);

    setState(() {
      feedbackMap[target.gridPosition] = isCorrect;

      if (isCorrect) {
        score +=
            (FocusPulseConstants.pointsForCorrectTap * scoreMultiplier).round();
        streak++;
        consecutiveErrors = 0;
        if (streak > 0 &&
            streak % FocusPulseConstants.streakBonusThreshold == 0) {
          score += FocusPulseConstants.streakBonusPoints;
          scoreMultiplier += 0.5;
        }
        // Remove the tapped target
        targets.removeWhere((t) => t.gridPosition == target.gridPosition);
      } else {
        score = max(0, score + FocusPulseConstants.pointsForIncorrectTap);
        streak = 0;
        consecutiveErrors++;
        if (consecutiveErrors >= FocusPulseConstants.maxConsecutiveErrors) {
          showWarning();
        }
      }
    });

    _feedbackController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() {
          feedbackMap.remove(target.gridPosition);
        });
      }
    });
  }

  void spawnTargets() {
    // Clear inactive targets
    targets.removeWhere((target) => !target.isActive);

    // Only add new targets if we need more
    if (targets.length < gridSize * gridSize) {
      // Ensure at least one valid target
      if (!targets.any((t) => currentRule.isValidTarget(t))) {
        final validTarget = createValidTarget();
        targets.add(validTarget);
      }

      // Add bait target if in higher levels
      if (currentLevel >= 2 && !targets.any((t) => t.isBait)) {
        final baitTarget = createBaitTarget();
        targets.add(baitTarget);
      }

      // Fill remaining spaces with random targets
      while (targets.length < gridSize * gridSize) {
        final target = createRandomTarget();
        if (!targets.any((t) => t.gridPosition == target.gridPosition)) {
          targets.add(target);
        }
      }
    }
  }

  Target createValidTarget() {
    ShapeType shape;
    TargetColor color;

    do {
      shape = ShapeType.values[random.nextInt(ShapeType.values.length)];
      color = TargetColor.values[random.nextInt(TargetColor.values.length)];
    } while (!currentRule
        .isValidTarget(Target(shape: shape, color: color, gridPosition: 0)));

    return Target(
      shape: shape,
      color: color,
      gridPosition: getRandomEmptyPosition(),
    );
  }

  Target createBaitTarget() {
    ShapeType shape;
    TargetColor color;

    do {
      shape = ShapeType.values[random.nextInt(ShapeType.values.length)];
      color = TargetColor.values[random.nextInt(TargetColor.values.length)];
    } while (currentRule
        .isValidTarget(Target(shape: shape, color: color, gridPosition: 0)));

    return Target(
      shape: shape,
      color: color,
      gridPosition: getRandomEmptyPosition(),
      isBait: true,
    );
  }

  Target createRandomTarget() {
    return Target(
      shape: ShapeType.values[random.nextInt(ShapeType.values.length)],
      color: TargetColor.values[random.nextInt(TargetColor.values.length)],
      gridPosition: getRandomEmptyPosition(),
    );
  }

  int getRandomEmptyPosition() {
    int position;
    do {
      position = random.nextInt(gridSize * gridSize);
    } while (targets.any((t) => t.gridPosition == position));
    return position;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FocusPulseConstants.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Column(
                        children: [
                          Text(
                            'Score: $score',
                            style: FocusPulseConstants.scoreStyle,
                          ),
                          Text(
                            'Level: $currentLevel',
                            style: FocusPulseConstants.levelStyle,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Streak: $streak',
                            style: FocusPulseConstants.streakStyle,
                          ),
                          Text(
                            '${scoreMultiplier}x',
                            style: FocusPulseConstants.streakStyle.copyWith(
                              color: Colors.yellow,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (roundPhase == RoundPhase.instruction ||
                    roundPhase == RoundPhase.action)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      currentRule.instruction,
                      style: FocusPulseConstants.instructionStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (roundPhase == RoundPhase.pause)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Get Ready...',
                      style: FocusPulseConstants.instructionStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(FocusPulseConstants.gridPadding),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridSize,
                          crossAxisSpacing: FocusPulseConstants.gridSpacing,
                          mainAxisSpacing: FocusPulseConstants.gridSpacing,
                        ),
                        itemCount: gridSize * gridSize,
                        itemBuilder: (context, index) {
                          final target = targets.firstWhere(
                            (t) => t.gridPosition == index,
                            orElse: () => Target(
                              shape: ShapeType.circle,
                              color: TargetColor.blue,
                              gridPosition: index,
                              isActive: false,
                            ),
                          );

                          if (!target.isActive) return const SizedBox.shrink();

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final size = min(
                                constraints.maxWidth,
                                FocusPulseConstants.maxTargetSize,
                              );

                              return Center(
                                child: SizedBox(
                                  width: size,
                                  height: size,
                                  child: AnimatedBuilder(
                                    animation: _feedbackController,
                                    builder: (context, child) {
                                      final feedback =
                                          feedbackMap[target.gridPosition];
                                      final color = feedback == null
                                          ? null
                                          : feedback
                                              ? FocusPulseConstants
                                                  .correctFeedbackColor
                                              : FocusPulseConstants
                                                  .incorrectFeedbackColor;

                                      return GestureDetector(
                                        onTap: () => onTargetTapped(target),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: color != null
                                                ? Border.all(
                                                    color: color.withOpacity(
                                                        _feedbackController
                                                            .value),
                                                    width: 3,
                                                  )
                                                : null,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: GameShape(target: target),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                if (gameState == GameState.menu)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: ElevatedButton(
                      onPressed: startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                      ),
                      child: Text(
                        'Start Game',
                        style: FocusPulseConstants.buttonStyle,
                      ),
                    ),
                  ),
              ],
            ),
            if (gameState == GameState.warning)
              Container(
                color: FocusPulseConstants.warningColor.withOpacity(0.3),
                child: Center(
                  child: Text(
                    'Warning!',
                    style: FocusPulseConstants.warningStyle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GameShape extends StatelessWidget {
  final Target target;

  const GameShape({super.key, required this.target});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ShapePainter(
        shape: target.shape,
        color: FocusPulseConstants.targetColors[target.color]!,
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final ShapeType shape;
  final Color color;

  ShapePainter({required this.shape, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (shape) {
      case ShapeType.circle:
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          min(size.width, size.height) / 2,
          paint,
        );
        break;
      case ShapeType.triangle:
        final path = Path();
        path.moveTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        path.close();
        canvas.drawPath(path, paint);
        break;
      case ShapeType.square:
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          paint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
