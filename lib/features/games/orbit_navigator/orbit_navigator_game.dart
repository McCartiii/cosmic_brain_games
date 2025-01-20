import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../../widgets/animated_stars_background.dart';

enum AsteroidType { small, medium, large }

class Asteroid {
  double x;
  double y;
  double speed;
  double size;
  double rotation;
  double rotationSpeed;
  double horizontalSpeed;
  AsteroidType type;

  Asteroid({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.rotationSpeed,
    required this.horizontalSpeed,
    this.rotation = 0,
    this.type = AsteroidType.medium,
  });
}

class Collectible {
  double x;
  double y;
  double speed;

  Collectible({
    required this.x,
    required this.y,
    this.speed = 2.0,
  });
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  int lifetime;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.lifetime,
  });

  void update() {
    x += vx;
    y += vy;
    lifetime--;
  }
}

class OrbitNavigatorGame extends StatefulWidget {
  const OrbitNavigatorGame({super.key});

  @override
  State<OrbitNavigatorGame> createState() => _OrbitNavigatorGameState();
}

class _OrbitNavigatorGameState extends State<OrbitNavigatorGame>
    with SingleTickerProviderStateMixin {
  int score = 0;
  bool isPlaying = false;
  bool isGameOver = false;
  final Random random = Random();
  double gameSpeed = 1.0;
  int gameLevel = 1;
  Timer? gameTimer;

  final List<Asteroid> asteroids = [];
  final List<Collectible> collectibles = [];
  final List<Particle> engineParticles = [];
  final List<Particle> collisionParticles = [];

  double shipX = 0;
  double shipY = 0;
  bool isDragging = false;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      shipX = MediaQuery.of(context).size.width / 2;
      shipY = MediaQuery.of(context).size.height * 0.85;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    gameTimer?.cancel();
    super.dispose();
  }

  void startGame() {
    setState(() {
      isPlaying = true;
      isGameOver = false;
      score = 0;
      gameSpeed = 1.0;
      gameLevel = 1;
      shipX = MediaQuery.of(context).size.width / 2;
      shipY = MediaQuery.of(context).size.height * 0.85;
      asteroids.clear();
      collectibles.clear();
      engineParticles.clear();
      collisionParticles.clear();
    });

    for (int i = 0; i < 5; i++) {
      spawnAsteroid();
    }

    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!isPlaying) {
        timer.cancel();
        return;
      }

      setState(() {
        updateAsteroids();
        updateCollectibles();
        updateParticles();

        if (random.nextDouble() < 0.02 * gameSpeed) {
          spawnAsteroid();
        }
        if (random.nextDouble() < 0.01) {
          spawnCollectible();
        }

        checkCollisions();

        if (isPlaying && !isGameOver) {
          addEngineParticle();
        }

        gameSpeed += 0.0001;
        if (gameSpeed > gameLevel * 1.5) {
          gameLevel++;
        }
      });
    });
  }

  void spawnAsteroid() {
    double size = random.nextDouble() * 30 + 20;
    asteroids.add(Asteroid(
      x: random.nextDouble() * MediaQuery.of(context).size.width,
      y: -50,
      speed: (random.nextDouble() * 2 + 2) * gameSpeed,
      size: size,
      rotationSpeed: (random.nextDouble() - 0.5) * 0.1,
      horizontalSpeed: (random.nextDouble() - 0.5) * 2 * gameSpeed,
      type: AsteroidType.values[random.nextInt(AsteroidType.values.length)],
    ));
  }

  void spawnCollectible() {
    collectibles.add(Collectible(
      x: random.nextDouble() * MediaQuery.of(context).size.width,
      y: -20,
      speed: 3.0,
    ));
  }

  void updateAsteroids() {
    for (var asteroid in asteroids) {
      asteroid.y += asteroid.speed;
      asteroid.rotation += asteroid.rotationSpeed;
      asteroid.x += asteroid.horizontalSpeed * sin(asteroid.y / 30);

      if (asteroid.x < 0 || asteroid.x > MediaQuery.of(context).size.width) {
        asteroid.horizontalSpeed *= -0.8;
      }
    }

    asteroids.removeWhere(
        (asteroid) => asteroid.y > MediaQuery.of(context).size.height);
  }

  void updateParticles() {
    for (var particle in engineParticles) {
      particle.update();
    }
    engineParticles.removeWhere((particle) => particle.lifetime <= 0);

    for (var particle in collisionParticles) {
      particle.update();
    }
    collisionParticles.removeWhere((particle) => particle.lifetime <= 0);
  }

  void updateCollectibles() {
    for (var collectible in collectibles) {
      collectible.y += collectible.speed * gameSpeed;
    }

    collectibles.removeWhere(
        (collectible) => collectible.y > MediaQuery.of(context).size.height);

    if (collectibles.isEmpty && random.nextDouble() < 0.02) {
      collectibles.add(Collectible(
        x: random.nextDouble() * MediaQuery.of(context).size.width,
        y: -20,
      ));
    }
  }

  void checkCollisions() {
    for (var asteroid in asteroids) {
      double dx = asteroid.x - shipX;
      double dy = asteroid.y - shipY;
      double distance = sqrt(dx * dx + dy * dy);

      if (distance < (asteroid.size / 2 + 15)) {
        gameOver();
        addCollisionParticles();
        break;
      }
    }

    collectibles.removeWhere((collectible) {
      double dx = collectible.x - shipX;
      double dy = collectible.y - shipY;
      double distance = sqrt(dx * dx + dy * dy);

      if (distance < 25) {
        score += 10;
        addCollectParticles(collectible.x, collectible.y);
        return true;
      }
      return false;
    });
  }

  void addCollisionParticles() {
    for (int i = 0; i < 20; i++) {
      double angle = random.nextDouble() * 2 * pi;
      double speed = random.nextDouble() * 5;
      collisionParticles.add(Particle(
        x: shipX,
        y: shipY,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        color: Colors.red.withOpacity(0.8),
        size: random.nextDouble() * 4 + 2,
        lifetime: random.nextInt(20) + 15,
      ));
    }
  }

  void addCollectParticles(double x, double y) {
    for (int i = 0; i < 10; i++) {
      double angle = random.nextDouble() * 2 * pi;
      double speed = random.nextDouble() * 3;
      collisionParticles.add(Particle(
        x: x,
        y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        color: Colors.yellow.withOpacity(0.8),
        size: random.nextDouble() * 3 + 1,
        lifetime: random.nextInt(15) + 10,
      ));
    }
  }

  void gameOver() {
    setState(() {
      isPlaying = false;
      isGameOver = true;
    });
    gameTimer?.cancel();
  }

  void addEngineParticle() {
    engineParticles.add(Particle(
      x: shipX,
      y: shipY + 15,
      vx: (random.nextDouble() - 0.5) * 2,
      vy: random.nextDouble() * 2 + 2,
      color: Colors.orange.withOpacity(0.8),
      size: random.nextDouble() * 3 + 1,
      lifetime: random.nextInt(10) + 10,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedStarsBackground(),
          SafeArea(
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
                        'Level $gameLevel',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Score: $score',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RepaintBoundary(
                    child: GestureDetector(
                      onPanStart: (details) {
                        if (!isPlaying) return;
                        isDragging = true;
                      },
                      onPanUpdate: (details) {
                        if (!isPlaying || !isDragging) return;
                        setState(() {
                          shipX = (shipX + details.delta.dx).clamp(
                            20,
                            MediaQuery.of(context).size.width - 20,
                          );
                          shipY = (shipY + details.delta.dy).clamp(
                            MediaQuery.of(context).size.height * 0.7,
                            MediaQuery.of(context).size.height * 0.9,
                          );
                        });
                      },
                      onPanEnd: (_) => isDragging = false,
                      child: CustomPaint(
                        painter: GamePainter(
                          asteroids: asteroids,
                          collectibles: collectibles,
                          particles: [
                            ...engineParticles,
                            ...collisionParticles
                          ],
                          shipX: shipX,
                          shipY: shipY,
                          isPlaying: isPlaying,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isPlaying)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isGameOver) ...[
                    Text(
                      'Game Over!',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    'Final Score: $score',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    'Level $gameLevel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: Text(isGameOver ? 'Play Again' : 'Start Game'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    onPressed: startGame,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  final List<Asteroid> asteroids;
  final List<Collectible> collectibles;
  final List<Particle> particles;
  final double shipX;
  final double shipY;
  final bool isPlaying;

  GamePainter({
    required this.asteroids,
    required this.collectibles,
    required this.particles,
    required this.shipX,
    required this.shipY,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        Paint()..color = particle.color,
      );
    }

    for (var asteroid in asteroids) {
      canvas.save();
      canvas.translate(asteroid.x, asteroid.y);
      canvas.rotate(asteroid.rotation);

      final asteroidPainter = AsteroidPainter(type: asteroid.type);
      asteroidPainter.paint(
        canvas,
        Size(asteroid.size, asteroid.size),
      );

      canvas.restore();
    }

    for (var collectible in collectibles) {
      canvas.drawCircle(
        Offset(collectible.x, collectible.y),
        7.5,
        Paint()
          ..color = Colors.yellow
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }

    if (isPlaying) {
      canvas.drawCircle(
        Offset(shipX, shipY),
        20,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}

class AsteroidPainter extends CustomPainter {
  final AsteroidType type;
  final Random random = Random(42);

  AsteroidPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.shade800
      ..style = PaintingStyle.fill;

    final path = Path();
    final points = List.generate(8, (i) {
      final angle = i * pi / 4;
      final variance = type == AsteroidType.small
          ? 0.2
          : type == AsteroidType.medium
              ? 0.3
              : 0.4;
      final radius = size.width / 2 * (0.8 + random.nextDouble() * variance);
      return Offset(
        cos(angle) * radius + size.width / 2,
        sin(angle) * radius + size.height / 2,
      );
    });

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    canvas.drawPath(path, paint);

    paint.color = Colors.red.shade900;
    int craterCount = type == AsteroidType.small
        ? 2
        : type == AsteroidType.medium
            ? 3
            : 4;
    for (int i = 0; i < craterCount; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        size.width * (0.1 + random.nextDouble() * 0.1),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
