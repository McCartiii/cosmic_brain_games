import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Pages
import 'pages/home_page.dart';
import 'pages/games/games_menu.dart';
import 'pages/games/color_match_game.dart';
import 'pages/games/memory_matrix_game.dart';
import 'pages/games/photon_burst_game.dart';
import 'pages/games/orbit_navigator_game.dart';
import 'pages/leaderboard_page.dart';
import 'pages/teams_hub_page.dart';

// Models
import 'models/team.dart';
import 'models/player.dart';
import 'models/game_score.dart';

// Services
import 'services/team_manager.dart';
import 'services/score_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TeamManager()),
        ChangeNotifierProvider(create: (context) => ScoreManager()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cosmic Brain Games',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/games': (context) => const GamesMenu(),
        '/color_match': (context) => const ColorMatchGame(),
        '/memory_matrix': (context) => const MemoryMatrixGame(),
        '/photon_burst': (context) => const PhotonBurstGame(),
        '/orbit_navigator': (context) => const OrbitNavigatorGame(),
        '/leaderboard': (context) => const LeaderboardPage(),
        '/teams_hub': (context) => const TeamsHubPage(),
      },
    );
  }
}
