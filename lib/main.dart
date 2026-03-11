import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_state.dart';
import 'pages/main_tab_screen.dart';

void main() {
  runApp(const LuckyReelsApp());
}

class LuckyReelsApp extends StatelessWidget {
  const LuckyReelsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(),
      child: MaterialApp(
        title: 'Lucky Reels',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF080810),
          primaryColor: Colors.amber,
          colorScheme: const ColorScheme.dark(
            primary: Colors.amber,
            secondary: Colors.amberAccent,
          ),
        ),
        home: const MainTabScreen(),
      ),
    );
  }
}