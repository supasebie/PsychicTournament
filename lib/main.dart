import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/main_menu_screen.dart';
import 'screens/zener_game_screen.dart';
import 'screens/game_history_screen.dart';
import 'screens/game_statistics_screen.dart';
import 'screens/session_detail_screen.dart';
import 'screens/stats_menu_screen.dart';
import 'screens/options_screen.dart';
import 'services/supabase_service.dart';
import 'database/models/game_session.dart';

// App theme
import 'theme/app_theme.dart';

/// Simple AdMob initialization with test IDs.
/// We initialize MobileAds before runApp to avoid first-ad jank.
/// Also lock orientation to portrait to avoid layout overflow for ads.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      // Add DeviceOrientation.portraitDown if you want upside-down allowed.
    ]);
  } catch (e) {
    debugPrint('Failed to set preferred orientations: $e');
  }

  // Initialize Supabase with error handling
  try {
    await SupabaseService.initialize();
  } catch (e) {
    // Log error but continue app startup
    debugPrint('Failed to initialize Supabase: $e');
  }

  // Initialize Google Mobile Ads SDK with default settings.
  // Consider setting requestConfiguration (e.g., testDeviceIds) if needed.
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint('Failed to initialize Google Mobile Ads: $e');
  }

  runApp(const PsychicTournament());
}

class PsychicTournament extends StatelessWidget {
  const PsychicTournament({super.key});

  // Named routes for better navigation management
  static const String mainMenuRoute = '/';
  static const String zenerGameRoute = '/zener-game';
  static const String gameHistoryRoute = '/game-history';
  static const String gameStatisticsRoute = '/game-statistics';
  static const String sessionDetailRoute = '/session-detail';
  static const String statsMenuRoute = '/stats-menu';
  static const String optionsRoute = '/options';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Psychic Tournament',
      theme: AppTheme.dark(),
      initialRoute: mainMenuRoute,
      routes: {
        mainMenuRoute: (context) => const MainMenuScreen(),
        zenerGameRoute: (context) => const ZenerGameScreen(),
        gameHistoryRoute: (context) => const GameHistoryScreen(),
        gameStatisticsRoute: (context) => const GameStatisticsScreen(),
        statsMenuRoute: (context) => const PerformanceMenuScreen(),
        optionsRoute: (context) => const OptionsScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle routes that require parameters
        switch (settings.name) {
          case sessionDetailRoute:
            final session = settings.arguments as GameSession;
            return MaterialPageRoute(
              builder: (context) => SessionDetailScreen(session: session),
              settings: settings,
            );
          default:
            return null;
        }
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
