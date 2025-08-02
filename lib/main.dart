import 'package:flutter/material.dart';
import 'screens/main_menu_screen.dart';
import 'screens/zener_game_screen.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with error handling
  try {
    await SupabaseService.initialize();
  } catch (e) {
    // Log error but continue app startup
    debugPrint('Failed to initialize Supabase: $e');
  }

  runApp(const PsychicTournament());
}

class PsychicTournament extends StatelessWidget {
  const PsychicTournament({super.key});

  // Named routes for better navigation management
  static const String mainMenuRoute = '/';
  static const String zenerGameRoute = '/zener-game';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Psychic Tournament',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      initialRoute: mainMenuRoute,
      routes: {
        mainMenuRoute: (context) => const MainMenuScreen(),
        zenerGameRoute: (context) => const ZenerGameScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
