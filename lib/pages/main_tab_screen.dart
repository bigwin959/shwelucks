import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../game_state.dart';
import 'home_screen.dart';
import 'game_screen.dart';
import 'achievements_screen.dart';
import 'profile_tab.dart';

// Achievement display names for toast notifications
const _achNames = {
  'first_spin':  '🎰 First Spin!',
  'first_win':   '🎉 First Win!',
  'streak_3':    '🔥 On Fire! 3-in-a-row',
  'streak_5':    '🌋 Unstoppable! 5-in-a-row',
  'coins_5000':  '💰 5K Club',
  'coins_10000': '🤑 10K Elite',
  'spins_50':    '🎡 Committed – 50 Spins',
  'spins_100':   '💫 Spin Master – 100 Spins',
  'scatter_1':   '🌟 Scatter Hunter',
  'jackpot_1':   '7️⃣ Lucky Seven – Jackpot!',
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
    // Listen for achievement unlocks and fire toasts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameState>().addListener(_onGameStateChange);
    });
  }

  @override
  void dispose() {
    // Safe to call even if context is no longer mounted
    try { context.read<GameState>().removeListener(_onGameStateChange); } catch (_) {}
    super.dispose();
  }

  void _onGameStateChange() {
    if (!mounted) return;
    final toasts = context.read<GameState>().popNewlyUnlocked();
    for (final id in toasts) {
      final name = _achNames[id] ?? id;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Achievement Unlocked: $name',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.amber,
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
      _TabData(icon: Icons.home_rounded,          label: 'Home'),
      _TabData(icon: Icons.casino_rounded,         label: 'Play',    isHighlight: true),
      _TabData(icon: Icons.emoji_events_rounded,   label: 'Stats'),
      _TabData(icon: Icons.person_rounded,         label: 'Profile'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF080810),
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
        color: const Color(0xFF0D0D16),
        border: Border(
          top: BorderSide(color: Colors.amber.withOpacity(0.12), width: 1),
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFCC00), Color(0xFFFF8800)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8800).withOpacity(isSelected ? 0.7 : 0.3),
                  blurRadius: isSelected ? 18 : 8,
                ),
              ],
            ),
            child: Icon(tab.icon, color: Colors.black, size: 26),
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
              color: isSelected ? Colors.amber : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(tab.icon, color: isSelected ? Colors.amber : Colors.grey[600], size: 22),
            const SizedBox(height: 3),
            Text(
              tab.label,
              style: TextStyle(
                color: isSelected ? Colors.amber : Colors.grey[600],
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
  final String label;
  final bool isHighlight;
  const _TabData({required this.icon, required this.label, this.isHighlight = false});
}
