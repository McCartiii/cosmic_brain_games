import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

// Enums and Constants
enum Difficulty { easy, medium, hard }

enum MemoryShape {
  circle,
  triangle,
  square,
  star,
  diamond,
  hexagon,
  cross,
  heart,
}

enum GamePhase {
  watching,
  input,
  complete,
}

class MemoryTrailConstants {
  static const Duration feedbackDuration = Duration(milliseconds: 300);
  static const Duration pauseBetweenShapes = Duration(milliseconds: 300);

  static const Map<Difficulty, int> sequenceLengths = {
    Difficulty.easy: 4,
    Difficulty.medium: 6,
    Difficulty.hard: 8,
  };

  static const Map<Difficulty, Duration> shapeDurations = {
    Difficulty.easy: Duration(milliseconds: 1200),
    Difficulty.medium: Duration(milliseconds: 800),
    Difficulty.hard: Duration(milliseconds: 500),
  };

  static const Map<Difficulty, List<MemoryShape>> availableShapes = {
    Difficulty.easy: [
      MemoryShape.circle,
      MemoryShape.triangle,
      MemoryShape.square,
    ],
    Difficulty.medium: [
      MemoryShape.circle,
      MemoryShape.triangle,
      MemoryShape.square,
      MemoryShape.star,
      MemoryShape.diamond,
    ],
    Difficulty.hard: [
      MemoryShape.circle,
      MemoryShape.triangle,
      MemoryShape.square,
      MemoryShape.star,
      MemoryShape.diamond,
      MemoryShape.hexagon,
      MemoryShape.cross,
      MemoryShape.heart,
    ],
  };

  static const Map<MemoryShape, Color> shapeColors = {
    MemoryShape.circle: Colors.blue,
    MemoryShape.triangle: Colors.green,
    MemoryShape.square: Colors.red,
    MemoryShape.star: Colors.yellow,
    MemoryShape.diamond: Colors.purple,
    MemoryShape.hexagon: Colors.orange,
    MemoryShape.cross: Colors.cyan,
    MemoryShape.heart: Colors.pink,
  };

  static const int pointsPerCorrect = 100;
  static const int pointsPerIncorrect = -50;
  static const Map<Difficulty, int> perfectSequenceBonus = {
    Difficulty.easy: 200,
    Difficulty.medium: 400,
    Difficulty.hard: 800,
  };

  static const Map<Difficulty, double> speedMultiplier = {
    Difficulty.easy: 0.9,
    Difficulty.medium: 0.85,
    Difficulty.hard: 0.8,
  };

  static const Color backgroundColor = Color(0xFF1A1A1A);
  static const Color laneColor = Color(0xFF2A2A2A);
  static const Color correctColor = Colors.green;
  static const Color incorrectColor = Colors.red;

  static const double gridPadding = 16.0;
  static const double laneSpacing = 8.0;
  static const double shapeSize = 60.0;
  static const double bottomShapeSize = 50.0;
  static const double bottomPadding = 24.0;

  static const TextStyle scoreStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle instructionStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );
}

// Sequence Item Class
class MemorySequenceItem {
  final MemoryShape shape;
  final int lane;

  const MemorySequenceItem({
    required this.shape,
    required this.lane,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemorySequenceItem &&
          runtimeType == other.runtimeType &&
          shape == other.shape &&
          lane == other.lane;

  @override
  int get hashCode => shape.hashCode ^ lane.hashCode;
}

// Main Game Widget
class MemoryTrailGame extends StatefulWidget {
  final Difficulty difficulty;
  final Function(int score)? onComplete;

  const MemoryTrailGame({
    super.key,
    this.difficulty = Difficulty.easy,
    this.onComplete,
  });

  @override
  State<MemoryTrailGame> createState() => _MemoryTrailGameState();
}

// Game State
class _MemoryTrailGameState extends State<MemoryTrailGame>
    with SingleTickerProviderStateMixin {
  final Random random = Random();
  List<MemorySequenceItem> sequence = [];
  List<MemorySequenceItem> playerInput = [];
  GamePhase currentPhase = GamePhase.watching;
  int currentIndex = 0;
  int currentLevel = 1;
  int score = 0;
  int consecutiveCorrect = 0;
  Timer? sequenceTimer;
  MemorySequenceItem? currentItem;
  late AnimationController _feedbackController;
  bool? lastInputCorrect;
  Duration currentShapeDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: MemoryTrailConstants.feedbackDuration,
    );
    currentShapeDuration =
        MemoryTrailConstants.shapeDurations[widget.difficulty]!;
    startNewLevel();
  }

  @override
  void dispose() {
    sequenceTimer?.cancel();
    _feedbackController.dispose();
    super.dispose();
  }

  void startNewLevel() {
    setState(() {
      playerInput.clear();
      currentPhase = GamePhase.watching;
    });
    generateSequence();
    startSequenceDisplay();
  }

  void generateSequence() {
    sequence.clear();
    int baseLength = MemoryTrailConstants.sequenceLengths[widget.difficulty]!;
    int length = baseLength + ((currentLevel - 1) ~/ 2);

    final availableShapes =
        MemoryTrailConstants.availableShapes[widget.difficulty]!;

    for (int i = 0; i < length; i++) {
      MemoryShape shape;
      int lane;

      do {
        shape = availableShapes[random.nextInt(availableShapes.length)];
        lane = random.nextInt(3);
      } while (sequence.isNotEmpty &&
          (sequence.last.shape == shape || sequence.last.lane == lane));

      sequence.add(MemorySequenceItem(shape: shape, lane: lane));
    }
  }

  void startSequenceDisplay() {
    currentIndex = 0;
    displayNextShape();
  }

  void displayNextShape() {
    if (currentIndex >= sequence.length) {
      setState(() {
        currentPhase = GamePhase.input;
        currentItem = null;
      });
      return;
    }

    setState(() {
      currentItem = sequence[currentIndex];
    });

    sequenceTimer?.cancel();
    sequenceTimer = Timer(
      currentShapeDuration,
      () {
        setState(() {
          currentItem = null;
        });

        sequenceTimer = Timer(
          MemoryTrailConstants.pauseBetweenShapes,
          () {
            currentIndex++;
            displayNextShape();
          },
        );
      },
    );
  }

  void onShapeTapped(MemoryShape shape) {
    if (currentPhase != GamePhase.input) return;

    final expectedShape = sequence[playerInput.length].shape;
    final isCorrect = shape == expectedShape;

    setState(() {
      playerInput.add(MemorySequenceItem(
        shape: shape,
        lane: sequence[playerInput.length].lane,
      ));

      lastInputCorrect = isCorrect;
      if (isCorrect) {
        score += MemoryTrailConstants.pointsPerCorrect * currentLevel;
        consecutiveCorrect++;
      } else {
        score = max(0, score + MemoryTrailConstants.pointsPerIncorrect);
        consecutiveCorrect = 0;
      }
    });

    _feedbackController.forward(from: 0);

    if (playerInput.length >= sequence.length) {
      bool isPerfect = !playerInput
          .asMap()
          .entries
          .any((entry) => entry.value.shape != sequence[entry.key].shape);

      if (isPerfect) {
        score += MemoryTrailConstants.perfectSequenceBonus[widget.difficulty]! *
            currentLevel;

        setState(() {
          currentLevel++;
          currentShapeDuration *=
              MemoryTrailConstants.speedMultiplier[widget.difficulty]!;
        });
      }

      Timer(MemoryTrailConstants.feedbackDuration, () {
        if (isPerfect) {
          startNewLevel();
        } else {
          setState(() {
            currentPhase = GamePhase.complete;
          });
          widget.onComplete?.call(score);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MemoryTrailConstants.backgroundColor,
      body: SafeArea(
        child: Column(
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
                  Text(
                    'Score: $score',
                    style: MemoryTrailConstants.scoreStyle,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(MemoryTrailConstants.gridPadding),
                child: Row(
                  children: List.generate(3, (laneIndex) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(
                            MemoryTrailConstants.laneSpacing),
                        decoration: BoxDecoration(
                          color: MemoryTrailConstants.laneColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: currentItem?.lane == laneIndex
                            ? Center(
                                child: MemoryShapeWidget(
                                  shape: currentItem!.shape,
                                  size: MemoryTrailConstants.shapeSize,
                                ),
                              )
                            : null,
                      ),
                    );
                  }),
                ),
              ),
            ),
            if (currentPhase == GamePhase.watching)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Watch the sequence...',
                  style: MemoryTrailConstants.instructionStyle,
                ),
              ),
            if (currentPhase == GamePhase.input)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Repeat the sequence!',
                  style: MemoryTrailConstants.instructionStyle,
                ),
              ),
            if (currentPhase == GamePhase.input ||
                currentPhase == GamePhase.complete)
              Padding(
                padding:
                    const EdgeInsets.all(MemoryTrailConstants.bottomPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: MemoryShape.values
                      .where((shape) => MemoryTrailConstants
                          .availableShapes[widget.difficulty]!
                          .contains(shape))
                      .map((shape) {
                    return GestureDetector(
                      onTap: currentPhase == GamePhase.input
                          ? () => onShapeTapped(shape)
                          : null,
                      child: AnimatedBuilder(
                        animation: _feedbackController,
                        builder: (context, child) {
                          Color color =
                              MemoryTrailConstants.shapeColors[shape]!;

                          if (playerInput.isNotEmpty &&
                              playerInput.last.shape == shape &&
                              _feedbackController.value < 1) {
                            color = lastInputCorrect!
                                ? MemoryTrailConstants.correctColor
                                : MemoryTrailConstants.incorrectColor;
                          }

                          return MemoryShapeWidget(
                            shape: shape,
                            size: MemoryTrailConstants.bottomShapeSize,
                            color: color,
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MemoryShapeWidget extends StatelessWidget {
  final MemoryShape shape;
  final double size;
  final Color? color;

  const MemoryShapeWidget({
    super.key,
    required this.shape,
    required this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: MemoryShapePainter(
          shape: shape,
          color: color ?? MemoryTrailConstants.shapeColors[shape]!,
        ),
      ),
    );
  }
}

class MemoryShapePainter extends CustomPainter {
  final MemoryShape shape;
  final Color color;

  MemoryShapePainter({
    required this.shape,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    switch (shape) {
      case MemoryShape.circle:
        canvas.drawCircle(center, radius, paint);
        break;

      case MemoryShape.triangle:
        final path = Path();
        path.moveTo(center.dx, center.dy - radius);
        path.lineTo(
            center.dx + radius * cos(pi / 6), center.dy + radius * sin(pi / 6));
        path.lineTo(
            center.dx - radius * cos(pi / 6), center.dy + radius * sin(pi / 6));
        path.close();
        canvas.drawPath(path, paint);
        break;

      case MemoryShape.square:
        canvas.drawRect(
          Rect.fromCenter(
              center: center,
              width: size.width * 0.8,
              height: size.height * 0.8),
          paint,
        );
        break;

      case MemoryShape.star:
        final path = Path();
        final outerRadius = radius;
        final innerRadius = radius * 0.4;
        for (var i = 0; i < 5; i++) {
          final outerX = center.dx + outerRadius * cos(2 * pi * i / 5 - pi / 2);
          final outerY = center.dy + outerRadius * sin(2 * pi * i / 5 - pi / 2);
          final innerX =
              center.dx + innerRadius * cos(2 * pi * i / 5 + pi / 10 - pi / 2);
          final innerY =
              center.dy + innerRadius * sin(2 * pi * i / 5 + pi / 10 - pi / 2);

          if (i == 0) {
            path.moveTo(outerX, outerY);
          } else {
            path.lineTo(outerX, outerY);
          }
          path.lineTo(innerX, innerY);
        }
        path.close();
        canvas.drawPath(path, paint);
        break;

      case MemoryShape.diamond:
        final path = Path();
        path.moveTo(center.dx, center.dy - radius);
        path.lineTo(center.dx + radius, center.dy);
        path.lineTo(center.dx, center.dy + radius);
        path.lineTo(center.dx - radius, center.dy);
        path.close();
        canvas.drawPath(path, paint);
        break;

      case MemoryShape.hexagon:
        final path = Path();
        for (var i = 0; i < 6; i++) {
          final x = center.dx + radius * cos(2 * pi * i / 6 - pi / 6);
          final y = center.dy + radius * sin(2 * pi * i / 6 - pi / 6);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
        break;

      case MemoryShape.cross:
        final path = Path();
        final width = size.width * 0.25;
        path.addRect(Rect.fromCenter(
          center: center,
          width: width,
          height: size.height * 0.8,
        ));
        path.addRect(Rect.fromCenter(
          center: center,
          width: size.width * 0.8,
          height: width,
        ));
        canvas.drawPath(path, paint);
        break;

      case MemoryShape.heart:
        final path = Path();
        path.moveTo(center.dx, center.dy + radius * 0.7);
        path.cubicTo(
          center.dx + radius,
          center.dy,
          center.dx + radius,
          center.dy - radius * 0.5,
          center.dx,
          center.dy - radius * 0.5,
        );
        path.cubicTo(
          center.dx - radius,
          center.dy - radius * 0.5,
          center.dx - radius,
          center.dy,
          center.dx,
          center.dy + radius * 0.7,
        );
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
