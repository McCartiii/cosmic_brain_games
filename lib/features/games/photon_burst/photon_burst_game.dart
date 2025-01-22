import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'photon_burst_constants.dart';
import 'photon_target.dart';
import 'particle_system.dart';
import 'power_ups.dart';

class PhotonBurstGame extends StatefulWidget {
  final Difficulty difficulty;

  const PhotonBurstGame({
    super.key,
    required this.difficulty,
  });

  @override
  State<PhotonBurstGame> createState() => _PhotonBurstGameState();
} // ... (previous imports and class declaration) ...

class _PhotonBurstGameState extends State<PhotonBurstGame>
    with SingleTickerProviderStateMixin {
  final Random random = Random();
  final ExplosionEffect explosionEffect = ExplosionEffect();
  List<PhotonTarget> targets = [];
  List<PowerUp> activePowerUps = [];
  Timer? gameTimer;
  Timer? spawnTimer;
  late AnimationController _animationController;
  int score = 0;
  int timeRemaining = PhotonBurstConstants.gameDuration;
  bool isGameActive = false;
  int combo = 0;
  double speedMultiplier = 1.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateGame);
    startGame();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    spawnTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _updateGame() {
    if (!isGameActive) return;

    setState(() {
      activePowerUps.removeWhere((powerUp) => powerUp.isExpired);
      explosionEffect.update(0.016);

      final hasTimeFreeze = activePowerUps
          .any((p) => p.type == PowerUpType.timeFreeze && !p.isExpired);

      if (!hasTimeFreeze) {
        for (var target in targets) {
          target.update(MediaQuery.of(context).size);
        }
      }
    });
  }

  void startGame() {
    setState(() {
      targets.clear();
      activePowerUps.clear();
      score = 0;
      timeRemaining = PhotonBurstConstants.gameDuration;
      isGameActive = true;
      combo = 0;
      speedMultiplier =
          PhotonBurstConstants.speedMultiplier[widget.difficulty]!;
    });

    _animationController.repeat();

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeRemaining > 0) {
          final hasTimeFreeze = activePowerUps
              .any((p) => p.type == PowerUpType.timeFreeze && !p.isExpired);
          if (!hasTimeFreeze) {
            timeRemaining--;
          }
        } else {
          endGame();
        }
      });
    });

    spawnTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (isGameActive &&
          targets.length <
              PhotonBurstConstants.maxTargets[widget.difficulty]!) {
        spawnTarget();
      }
    });
  }

  void spawnTarget() {
    if (!isGameActive) return;

    final screenSize = MediaQuery.of(context).size;
    final size =
        PhotonBurstConstants.baseTargetSize * (0.8 + random.nextDouble() * 0.4);

    final roll = random.nextDouble();
    final targetType = switch (roll) {
      < 0.05 when score >= 1000 => TargetType.powerUp,
      < 0.15 => TargetType.bonus,
      < 0.25 => TargetType.trap,
      _ => TargetType.standard,
    };

    final target = PhotonTarget(
      size: size,
      color: _getTargetColor(targetType),
      x: random.nextDouble() * (screenSize.width - size),
      y: random.nextDouble() * (screenSize.height - size),
      type: targetType,
      velocity: PhotonBurstConstants.baseVelocity * speedMultiplier,
      angle: random.nextDouble() * 2 * pi,
    );

    setState(() {
      targets.add(target);
    });
  }

  Color _getTargetColor(TargetType type) {
    return switch (type) {
      TargetType.standard => PhotonBurstConstants.standardTargetColor,
      TargetType.bonus => PhotonBurstConstants.bonusTargetColor,
      TargetType.trap => PhotonBurstConstants.trapTargetColor,
      TargetType.powerUp => PhotonBurstConstants.powerUpColor,
    };
  }

  void onTargetTapped(PhotonTarget target) {
    if (!isGameActive) return;

    explosionEffect.createExplosion(
      Offset(target.x + target.size / 2, target.y + target.size / 2),
      target.color,
    );

    setState(() {
      target.hit();
      targets.remove(target);

      final hasDoublePoints = activePowerUps
          .any((p) => p.type == PowerUpType.doublePoints && !p.isExpired);
      final pointMultiplier = hasDoublePoints ? 2.0 : 1.0;

      switch (target.type) {
        case TargetType.standard:
          score += (PhotonBurstConstants.pointsPerHit *
                  (1 + combo ~/ 5) *
                  pointMultiplier)
              .toInt();
          combo++;
          break;
        case TargetType.bonus:
          score += (PhotonBurstConstants.bonusPoints * pointMultiplier).toInt();
          combo += 2;
          break;
        case TargetType.trap:
          if (!activePowerUps
              .any((p) => p.type == PowerUpType.shield && !p.isExpired)) {
            score = max(0, score + PhotonBurstConstants.penaltyPoints);
            combo = 0;
            speedMultiplier = max(1.0, speedMultiplier - 0.1);
          }
          break;
        case TargetType.powerUp:
          _activatePowerUp();
          break;
      }

      if (score > 0 && score % 1000 == 0) {
        speedMultiplier += 0.1;
      }
    });
  }

  void _activatePowerUp() {
    final availablePowerUps = PowerUpType.values
        .where((type) =>
            !activePowerUps.any((p) => p.type == type && !p.isExpired))
        .toList();

    if (availablePowerUps.isEmpty) return;

    final powerUpType =
        availablePowerUps[random.nextInt(availablePowerUps.length)];
    final powerUp = PowerUp(
      type: powerUpType,
      duration: const Duration(seconds: 5),
    );

    setState(() {
      activePowerUps.add(powerUp);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(powerUp.icon, color: powerUp.color),
            const SizedBox(width: 8),
            Text('${powerUp.name} activated!'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void endGame() {
    setState(() {
      isGameActive = false;
      gameTimer?.cancel();
      spawnTimer?.cancel();
      _animationController.stop();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text(
          'Game Over',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Max Combo: $combo',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
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
      backgroundColor: PhotonBurstConstants.backgroundColor,
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: (details) {
              for (final target in targets) {
                if (target.containsPoint(details.localPosition)) {
                  onTargetTapped(target);
                  break;
                }
              }
            },
            child: CustomPaint(
              painter: GamePainter(
                targets: targets,
                explosionEffect: explosionEffect,
              ),
              size: Size.infinite,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Score: $score',
                        style: PhotonBurstConstants.scoreStyle,
                      ),
                      Text(
                        'Time: $timeRemaining',
                        style: PhotonBurstConstants.timerStyle,
                      ),
                    ],
                  ),
                  if (activePowerUps.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: activePowerUps
                          .where((p) => !p.isExpired)
                          .map((powerUp) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Tooltip(
                                  message: powerUp.name,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        value: powerUp.remainingTime / 5,
                                        valueColor: AlwaysStoppedAnimation(
                                            powerUp.color),
                                      ),
                                      Icon(
                                        powerUp.icon,
                                        color: powerUp.color,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  final List<PhotonTarget> targets;
  final ExplosionEffect explosionEffect;

  GamePainter({
    required this.targets,
    required this.explosionEffect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final target in targets) {
      final paint = Paint()
        ..color = target.color.withOpacity(target.opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(
        target.x + target.size / 2,
        target.y + target.size / 2,
      );
      canvas.rotate(target.rotationAngle);
      canvas.scale(target.scale);

      canvas.drawCircle(
        Offset.zero,
        target.size / 2,
        paint,
      );

      final borderPaint = Paint()
        ..color = Colors.white30
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(
        Offset.zero,
        target.size / 3,
        borderPaint,
      );

      canvas.restore();
    }

    explosionEffect.draw(canvas);
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) => true;
}
