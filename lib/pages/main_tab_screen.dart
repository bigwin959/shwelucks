import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../game_state.dart';
import 'home_screen.dart';
import 'game_screen.dart';
import 'achievements_screen.dart';
import 'profile_tab.dart';

const _kCyan   = Color(0xFF00F5FF);
const _kViolet = Color(0xFF7B2FFF);

// Map formula IDs to alchemy toast labels
const _formulaNames = {
  'first_spin':  '⚗️ First Synthesis!',
  'first_win':   '🧪 First Reaction!',
  'streak_3':    '🔥 Chain Reaction x3!',
  'streak_5':    '🌋 Unstable Chain x5!',
  'coins_5000':  '💰 5K EU Reserve!',
  'coins_10000': '🤑 10K EU Vault!',
  'spins_50':    '🔬 50 Experiments!',
  'spins_100':   '🌀 Synthesis Master!',
  'scatter_1':   '🌟 Catalyst Trigger!',
  'jackpot_1':   '☢️ Critical Synthesis!',
};

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameState>().addListener(_onGameStateChange);
    });
  }

  @override
  void dispose() {
    try { context.read<GameState>().removeListener(_onGameStateChange); } catch (_) {}
    super.dispose();
  }

  void _onGameStateChange() {
    if (!mounted) return;
    final toasts = context.read<GameState>().popNewlyUnlocked();
    for (final id in toasts) {
      final name = _formulaNames[id] ?? id;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Formula Unlocked: $name',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: _kCyan,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        ),
      );
    }
  }

  void _goToPlay() => setState(() => _currentIndex = 1);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onPlayTap: _goToPlay),
      const GameScreen(),
      const AchievementsScreen(),
      const ProfileTab(),
    ];

    const tabs = [
      _TabData(icon: Icons.home_rounded,        label: 'Home'),
      _TabData(icon: Icons.science_rounded,      label: 'Lab',      isHighlight: true),
      _TabData(icon: Icons.biotech_rounded,      label: 'Formulas'),
      _TabData(icon: Icons.person_rounded,       label: 'Profile'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          child: KeyedSubtree(
            key: ValueKey(_currentIndex),
            child: pages[_currentIndex],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(tabs),
    );
  }

  Widget _buildBottomNav(List<_TabData> tabs) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080818),
        border: Border(
          top: BorderSide(color: _kCyan.withOpacity(0.12), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(tabs.length, (i) => Expanded(
              child: _buildNavItem(i, tabs[i]),
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, _TabData tab) {
    final isSelected = _currentIndex == index;

    if (tab.isHighlight) {
      return GestureDetector(
        onTap: () { HapticFeedback.lightImpact(); setState(() => _currentIndex = index); },
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 52, height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [_kCyan, _kViolet],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _kCyan.withOpacity(isSelected ? 0.6 : 0.25),
                  blurRadius: isSelected ? 20 : 8,
                ),
              ],
            ),
            child: Icon(tab.icon, color: Colors.white, size: 26),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); setState(() => _currentIndex = index); },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isSelected ? _kCyan : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(tab.icon,
              color: isSelected ? _kCyan : Colors.grey[600], size: 22),
            const SizedBox(height: 3),
            Text(
              tab.label,
              style: TextStyle(
                color: isSelected ? _kCyan : Colors.grey[600],
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabData {
  final IconData icon;
  final String   label;
  final bool     isHighlight;
  const _TabData({required this.icon, required this.label, this.isHighlight = false});
}
