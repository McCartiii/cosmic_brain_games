import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<Firework> _fireworks = [];
  final Random random = Random();
  Timer? _fireworkTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _startFireworks();
  }

  void _startFireworks() {
    _fireworkTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted && _fireworks.length < 3) {
        setState(() {
          _fireworks.add(Firework(random));
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fireworkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.blue, Colors.purple],
          ).createShader(bounds),
          child: const Text(
            'Leaderboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Memory Matrix'),
            Tab(text: 'Color Match'),
            Tab(text: 'Photon Burst'),
          ],
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
          ),
          indicatorColor: Colors.blue,
          indicatorWeight: 3,
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.withOpacity(0.1),
                  Colors.purple.withOpacity(0.1),
                ],
              ),
            ),
          ),
          RepaintBoundary(
            child: CustomPaint(
              painter: FireworksPainter(_fireworks),
              size: Size.infinite,
            ),
          ),
          TabBarView(
            controller: _tabController,
            children: [
              _buildGameLeaderboard('Memory Matrix'),
              _buildGameLeaderboard('Color Match'),
              _buildGameLeaderboard('Photon Burst'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameLeaderboard(String gameName) {
    return Column(
      children: [
        const SizedBox(height: 40),
        SizedBox(
          height: 250,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                left: 40,
                bottom: 0,
                child: _buildPodiumItem('Player 2', '850', 2, 160),
              ),
              Positioned(
                bottom: 0,
                child: _buildPodiumItem('Player 1', '1000', 1, 180),
              ),
              Positioned(
                right: 40,
                bottom: 0,
                child: _buildPodiumItem('Player 3', '700', 3, 140),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 20),
                itemCount: 7,
                itemBuilder: (context, index) {
                  return _buildLeaderboardItem(
                    (index + 4).toString(),
                    'Player ${index + 4}',
                    (1000 - (index + 4) * 50).toString(),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumItem(String name, String score, int rank, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (rank == 1) const Icon(Icons.star, color: Colors.amber, size: 40),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                _getRankColor(rank.toString()),
                _getRankColor(rank.toString()).withOpacity(0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _getRankColor(rank.toString()).withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          score,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getRankColor(rank.toString()).withOpacity(0.7),
                _getRankColor(rank.toString()).withOpacity(0.3),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: _getRankColor(rank.toString()).withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(String rank, String name, String score) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                rank,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            score,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(String rank) {
    switch (rank) {
      case '1':
        return Colors.amber;
      case '2':
        return Colors.grey.shade400;
      case '3':
        return Colors.brown.shade300;
      default:
        return Colors.blue;
    }
  }
}

class Firework {
  final List<FireworkParticle> particles;
  final double x;
  final double y;
  double progress;

  Firework(Random random)
      : x = random.nextDouble(),
        y = random.nextDouble() * 0.5,
        progress = 0.0,
        particles = List.generate(50, (index) {
          final angle = index * (2 * pi / 50);
          final velocity = 0.3 + random.nextDouble() * 0.5;
          return FireworkParticle(
            angle: angle,
            velocity: velocity,
            color: _getRandomFireworkColor(random),
          );
        });

  static Color _getRandomFireworkColor(Random random) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];
    return colors[random.nextInt(colors.length)];
  }

  bool update() {
    progress += 0.02;
    return progress < 1.0;
  }
}

class FireworkParticle {
  final double angle;
  final double velocity;
  final Color color;

  FireworkParticle({
    required this.angle,
    required this.velocity,
    required this.color,
  });
}

class FireworksPainter extends CustomPainter {
  final List<Firework> fireworks;

  FireworksPainter(this.fireworks);

  @override
  void paint(Canvas canvas, Size size) {
    for (var firework in fireworks) {
      final paint = Paint()..strokeWidth = 2;

      for (var particle in firework.particles) {
        final progress = firework.progress;
        final distance = progress * particle.velocity * size.height;

        // Add subtle gravity effect
        final gravity = 0.3 * progress * progress;
        final dx = cos(particle.angle) * distance;
        final dy = sin(particle.angle) * distance + (gravity * size.height);

        paint.color = particle.color.withOpacity(1 - progress);

        canvas.drawLine(
          Offset(
            firework.x * size.width,
            firework.y * size.height,
          ),
          Offset(
            firework.x * size.width + dx,
            firework.y * size.height + dy,
          ),
          paint,
        );
      }
    }

    fireworks.removeWhere((firework) => !firework.update());
  }

  @override
  bool shouldRepaint(FireworksPainter oldDelegate) => true;
}
