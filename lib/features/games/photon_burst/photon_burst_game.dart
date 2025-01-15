import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import '../../constants/photon_burst_constant

class PhotonBurstGame extends StatefulWidget {
  const PhotonBurstGame({super.key});

  @override
  State<PhotonBurstGame> createState() => _PhotonBurstGameState();
}

class _PhotonBurstGameState extends State<PhotonBurstGame>
    with TickerProviderStateMixin {
  bool isPlaying = false;
  int score = 0;
  int timeLeft = PhotonBurstConstants.gameDuration;
  Timer? gameTimer;
  Timer? spawnTimer;
  final Random random = Random();

  String? currentPhotonKey;
  Offset? currentPhotonPosition;
  late AnimationController _photonController;
  late AnimationController _popController;
  late AnimationController _explosionController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _explosionScale;

  List<ParticleEffect> explosionParticles = [];
  List<ScoreFeedback> scoreFeedbacks = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _photonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _explosionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _photonController,
      curve: Curves.easeInOut,
    ));

    _explosionScale = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _explosionController,
      curve: Curves.easeOut,
    ));

    _explosionController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _showWrongPress(Offset position) {
    final wrongParticles = List.generate(10, (index) {
      final angle = index * (2 * pi / 10);
      final speed = 1.0 + random.nextDouble();
      final size = 3.0 + random.nextDouble() * 3.0;

      return ParticleEffect(
        position: position,
        angle: angle,
        speed: speed,
        size: size,
        color: Colors.red,
        lifetime: const Duration(milliseconds: 300),
      );
    });

    setState(() {
      explosionParticles.addAll(wrongParticles);
      scoreFeedbacks.add(
        ScoreFeedback(
          points: -5,
          position: position,
        ),
      );
    });

    _explosionController.forward(from: 0.0).then((_) {
      setState(() {
        explosionParticles
            .removeWhere((particle) => particle.color == Colors.red);
        scoreFeedbacks.clear();
      });
    });
  }

  void _createExplosion(Offset position, Color color) {
    final particles = List.generate(20, (index) {
      final angle = index * (2 * pi / 20);
      final speed = 2.0 + random.nextDouble() * 2.0;
      final size = 5.0 + random.nextDouble() * 5.0;

      return ParticleEffect(
        position: position,
        angle: angle,
        speed: speed,
        size: size,
        color: color,
        lifetime: const Duration(milliseconds: 500),
      );
    });

    setState(() {
      explosionParticles = particles;
      scoreFeedbacks.add(
        ScoreFeedback(
          points: PhotonBurstConstants.photonTypes[currentPhotonKey]!.points,
          position: position,
        ),
      );
    });

    _explosionController.forward(from: 0.0).then((_) {
      setState(() {
        explosionParticles.clear();
        scoreFeedbacks.clear();
      });
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _photonController.dispose();
    _popController.dispose();
    _explosionController.dispose();
    super.dispose();
  }

  void startGame() {
    setState(() {
      isPlaying = true;
      score = 0;
      timeLeft = PhotonBurstConstants.gameDuration;
      currentPhotonKey = null;
      currentPhotonPosition = null;
      explosionParticles.clear();
      scoreFeedbacks.clear();
    });

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft <= 0) {
          endGame();
        } else {
          timeLeft--;
        }
      });
    });

    spawnPhoton();
  }

  void spawnPhoton() {
    if (!isPlaying) return;

    final photonTypes = PhotonBurstConstants.photonTypes.keys.toList();
    final newKey = photonTypes[random.nextInt(photonTypes.length)];

    // Get the actual game area size from the context
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    // Calculate safe area for spawning
    final safeWidth = size.width - PhotonBurstConstants.photonSize - 64;
    final safeHeight = size.height - PhotonBurstConstants.photonSize - 64;

    // Ensure we're spawning within visible bounds
    final newX = 32.0 + random.nextDouble() * safeWidth;
    final newY = 32.0 + random.nextDouble() * safeHeight;

    setState(() {
      currentPhotonKey = newKey;
      currentPhotonPosition = Offset(newX, newY);
    });

    // Smoother fade in
    _photonController.reset();
    _photonController.forward();

    // Add a buffer time before spawning the next photon
    Timer(const Duration(milliseconds: 100), () {
      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _photonController,
        curve: Curves.easeInOut,
      ));
    });

    // Set up disappear timer
    Timer(PhotonBurstConstants.photonLifespan, () {
      if (currentPhotonKey == newKey) {
        _photonController.reverse().then((_) {
          removeCurrentPhoton();
        });
      }
    });
  }

  void removeCurrentPhoton() {
    setState(() {
      currentPhotonKey = null;
      currentPhotonPosition = null;
    });

    if (isPlaying) {
      spawnPhoton();
    }
  }

  void endGame() {
    setState(() {
      isPlaying = false;
    });

    gameTimer?.cancel();
    _photonController.stop();
    _popController.stop();
    _explosionController.stop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Colors.blue, width: 2),
        ),
        title: const Text(
          'Game Over!',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Final Score: $score',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKey: (RawKeyEvent event) {
          if (!isPlaying ||
              event is! RawKeyDownEvent ||
              currentPhotonKey == null) return;

          String? pressedKey;
          if (event.logicalKey == LogicalKeyboardKey.arrowUp)
            pressedKey = 'ArrowUp';
          else if (event.logicalKey == LogicalKeyboardKey.arrowRight)
            pressedKey = 'ArrowRight';
          else if (event.logicalKey == LogicalKeyboardKey.arrowDown)
            pressedKey = 'ArrowDown';
          else if (event.logicalKey == LogicalKeyboardKey.arrowLeft)
            pressedKey = 'ArrowLeft';

          if (pressedKey != null) {
            if (pressedKey == currentPhotonKey) {
              final points =
                  PhotonBurstConstants.photonTypes[currentPhotonKey]!.points;
              final color = Color(
                  PhotonBurstConstants.photonTypes[currentPhotonKey]!.color);

              setState(() {
                score += points;
              });

              if (currentPhotonPosition != null) {
                _createExplosion(currentPhotonPosition!, color);
              }

              _popController.forward(from: 0.0).then((_) {
                removeCurrentPhoton();
              });
            } else {
              setState(() {
                score = max(0, score - 5);
              });

              if (currentPhotonPosition != null) {
                _showWrongPress(currentPhotonPosition!);
              }
            }
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Score: $score',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Time: $timeLeft',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                    ...explosionParticles.map((particle) {
                      final progress = _explosionController.value;
                      final dx = particle.position.dx +
                          cos(particle.angle) * particle.speed * progress * 100;
                      final dy = particle.position.dy +
                          sin(particle.angle) * particle.speed * progress * 100;
                      final opacity = (1 - progress);

                      return Positioned(
                        left: dx,
                        top: dy,
                        child: Opacity(
                          opacity: opacity,
                          child: Container(
                            width: particle.size,
                            height: particle.size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: particle.color,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    ...scoreFeedbacks.map((feedback) {
                      return feedback;
                    }).toList(),
                    if (currentPhotonKey != null &&
                        currentPhotonPosition != null)
                      Positioned(
                        left: currentPhotonPosition!.dx,
                        top: currentPhotonPosition!.dy,
                        child: RepaintBoundary(
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _popController,
                              child: Container(
                                width: PhotonBurstConstants.photonSize,
                                height: PhotonBurstConstants.photonSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(PhotonBurstConstants
                                      .photonTypes[currentPhotonKey]!.color),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(PhotonBurstConstants
                                              .photonTypes[currentPhotonKey]!
                                              .color)
                                          .withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (!isPlaying)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Photon Burst',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10.0,
                                      color: Colors.blue,
                                      offset: Offset(2.0, 2.0),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: PhotonBurstConstants
                                    .photonTypes.entries
                                    .map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(entry.value.color),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          entry.key == 'ArrowUp'
                                              ? '↑'
                                              : entry.key == 'ArrowRight'
                                                  ? '→'
                                                  : entry.key == 'ArrowDown'
                                                      ? '↓'
                                                      : entry.key == 'ArrowLeft'
                                                          ? '←'
                                                          : '',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${entry.value.points} pts',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 30),
                              const Text(
                                'Press the matching arrow key when\nthe photon color appears!',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 30),
                              ElevatedButton(
                                onPressed: startGame,
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
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ParticleEffect {
  final Offset position;
  final double angle;
  final double speed;
  final double size;
  final Color color;
  final Duration lifetime;

  ParticleEffect({
    required this.position,
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.lifetime,
  });
}

class ScoreFeedback extends StatelessWidget {
  final int points;
  final Offset position;

  const ScoreFeedback({
    required this.points,
    required this.position,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Positioned(
          left: position.dx,
          top: position.dy - (30 * value),
          child: Opacity(
            opacity: 1 - value,
            child: Text(
              points >= 0 ? '+$points' : '$points',
              style: TextStyle(
                color: points >= 0 ? Colors.green : Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
