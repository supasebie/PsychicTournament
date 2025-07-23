import 'package:flutter/material.dart';
import 'screens/zener_game_screen.dart';

void main() {
  runApp(const PsychicTournament());
}

class PsychicTournament extends StatelessWidget {
  const PsychicTournament({super.key});

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
      home: const ZenerGameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
