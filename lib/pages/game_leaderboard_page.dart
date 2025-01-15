import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/leaderboard_entry.dart';
import '../widgets/fireworks.dart';

class GameLeaderboardPage extends StatefulWidget {
  final String gameType;
  final String title;
  final Color primaryColor;
  final IconData gameIcon;

  const GameLeaderboardPage({
    super.key,
    required this.gameType,
    required this.title,
    required this.primaryColor,
    required this.gameIcon,
  });

  @override
  State<GameLeaderboardPage> createState() => _GameLeaderboardPageState();
}

class _GameLeaderboardPageState extends State<GameLeaderboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final FireworksController _fireworksController = FireworksController();
  String _timeFilter = 'All Time';
  late List<LeaderboardEntry> entries;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    entries = LeaderboardEntry.getDemoEntries(widget.gameType);
    _animationController.forward();
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
              widget.primaryColor.withOpacity(0.3),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                _buildFilterBar(),
                _buildLeaderboardList(),
              ],
            ),
            ..._fireworksController.fireworks,
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          '${widget.title} Leaderboard',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Hero(
          tag: '/leaderboards/${widget.gameType}',
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  widget.primaryColor,
                  widget.primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                widget.gameIcon,
                size: 80,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _FilterBarDelegate(
        child: Container(
          color: Theme.of(context).colorScheme.background,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _timeFilter,
                  items: ['All Time', 'This Week', 'This Month']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _timeFilter = newValue;
                      });
                    }
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // Implement share functionality
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final entry = entries[index];
          return _buildLeaderboardEntry(entry, index);
        },
        childCount: entries.length,
      ),
    );
  }

  Widget _buildLeaderboardEntry(LeaderboardEntry entry, int index) {
    final rank = index + 1;
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          (index / entries.length) * 0.5,
          math.min(1.0, ((index + 1) / entries.length) * 0.5 + 0.5),
          curve: Curves.easeOutQuart,
        ),
      )),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: _buildEntryCard(entry, rank),
      ),
    );
  }

  Widget _buildEntryCard(LeaderboardEntry entry, int rank) {
    return Card(
      elevation: rank <= 3 ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: rank <= 3
              ? LinearGradient(
                  colors: [
                    _getRankColor(rank).withOpacity(0.2),
                    Colors.white,
                  ],
                )
              : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: _buildRankWidget(rank),
          title: Text(
            entry.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Achieved: ${_formatDate(entry.dateAchieved)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: widget.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              entry.score.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: widget.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.grey[400]!; // Silver
      case 3:
        return Colors.brown[300]!; // Bronze
      default:
        return widget.primaryColor;
    }
  }

  Widget _buildRankWidget(int rank) {
    if (rank > 3) {
      return CircleAvatar(
        backgroundColor: widget.primaryColor.withOpacity(0.1),
        child: Text(
          '$rank',
          style: TextStyle(
            color: widget.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final iconData = rank == 1
        ? Icons.emoji_events
        : rank == 2
            ? Icons.workspace_premium
            : Icons.stars;

    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          iconData,
          size: 40,
          color: _getRankColor(rank),
        ),
        Text(
          '$rank',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fireworksController.clear();
    super.dispose();
  }
}

class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _FilterBarDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 56.0;

  @override
  double get minExtent => 56.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
