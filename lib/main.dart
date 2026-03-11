import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_state.dart';
import 'pages/main_tab_screen.dart';

void main() {
  runApp(const AlchemyLabApp());
}

class AlchemyLabApp extends StatelessWidget {
  const AlchemyLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(),
      child: MaterialApp(
        title: 'Shwe Lucks — Alchemy Lab',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF050510),
          primaryColor: const Color(0xFF00F5FF),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00F5FF),
            secondary: Color(0xFF7B2FFF),
          ),
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Color(0xFF00F5FF),
            contentTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        home: const MainTabScreen(),
      ),
    );
  }
}