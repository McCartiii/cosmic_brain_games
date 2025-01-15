import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class PhotonBurstPage extends StatefulWidget {
  const PhotonBurstPage({super.key});

  @override
  State<PhotonBurstPage> createState() => _PhotonBurstPageState();
}

class _PhotonBurstPageState extends State<PhotonBurstPage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Timer gameTimer;
  final List<Photon> photons = [];
  int score = 0;
  int timeLeft = 30;
  bool isGameOver = false;
  int combo = 1;
  double spawnRate = 1.0;
  final math.Random random = math.Random();

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      score = 0;
      timeLeft = 30;
      isGameOver = false;
      combo = 1;
      spawnRate = 1.0;
      photons.clear();
    });
    _startTimers();
  }

  void _startTimers() {
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        if (timeLeft <= 0) {
          _endGame();
          return;
        }

        // Update photon positions
        for (var photon in photons) {
          photon.update();
        }

        // Remove off-screen photons
        photons.removeWhere((photon) => photon.isOffScreen());

        // Spawn new photons
        if (random.nextDouble() < spawnRate / 60) {
          _spawnPhoton();
        }

        // Update time every second
        if (timer.tick % 60 == 0) {
          timeLeft--;
          spawnRate = math.min(2.0, spawnRate + 0.1);
        }
      });
    });
  }

  void _spawnPhoton() {
    final angle = random.nextDouble() * 2 * math.pi;
    final speed = 2.0 + random.nextDouble() * 2.0;
    final size = 30.0 + random.nextDouble() * 20.0;
    final color = _getRandomColor();

    photons.add(Photon(
      x: MediaQuery.of(context).size.width / 2,
      y: MediaQuery.of(context).size.height / 2,
      angle: angle,
      speed: speed,
      size: size,
      color: color,
    ));
  }

  Color _getRandomColor() {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.orange,
      Colors.green,
    ];
    return colors[random.nextInt(colors.length)];
  }

  void _handleTapDown(TapDownDetails details) {
    if (isGameOver) return;

    bool hitPhoton = false;
    for (var photon in photons) {
      if (photon.containsPoint(details.localPosition)) {
        setState(() {
          score += 10 * combo;
          combo++;
          photons.remove(photon);
        });
        hitPhoton = true;
        break;
      }
    }

    if (!hitPhoton) {
      setState(() {
        combo = 1;
      });
    }
  }

  void _endGame() {
    gameTimer.cancel();
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
              Colors.indigo.shade900,
              Colors.indigo.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Game area
              GestureDetector(
                onTapDown: _handleTapDown,
                child: CustomPaint(
                  painter: PhotonPainter(
                    photons: photons,
                    rotationAnimation: _rotationController,
                  ),
                  size: Size.infinite,
                ),
              ),

              // UI Elements
              Column(
                children: [
                  _buildHeader(),
                  if (isGameOver) _buildGameOver(),
                ],
              ),
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
                'Combo: x$combo',
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

  Widget _buildGameOver() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                  color: Colors.indigo,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    gameTimer.cancel();
    super.dispose();
  }
}

class Photon {
  double x;
  double y;
  final double angle;
  final double speed;
  final double size;
  final Color color;

  Photon({
    required this.x,
    required this.y,
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });

  void update() {
    x += math.cos(angle) * speed;
    y += math.sin(angle) * speed;
  }

  bool isOffScreen() {
    return x < -size || x > 1000 + size || y < -size || y > 2000 + size;
  }

  bool containsPoint(Offset point) {
    final dx = point.dx - x;
    final dy = point.dy - y;
    return dx * dx + dy * dy <= size * size / 4;
  }
}

class PhotonPainter extends CustomPainter {
  final List<Photon> photons;
  final Animation<double> rotationAnimation;

  PhotonPainter({
    required this.photons,
    required this.rotationAnimation,
  }) : super(repaint: rotationAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw background effects
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.blue.withOpacity(0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: center,
        radius: size.width / 2,
      ));

    canvas.drawCircle(center, size.width / 2, bgPaint);

    // Draw photons
    for (var photon in photons) {
      final paint = Paint()
        ..color = photon.color
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(
        Offset(photon.x, photon.y),
        photon.size / 2,
        paint,
      );

      // Draw glow effect
      final glowPaint = Paint()
        ..color = photon.color.withOpacity(0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

      canvas.drawCircle(
        Offset(photon.x, photon.y),
        photon.size,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
