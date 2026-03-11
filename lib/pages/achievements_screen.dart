import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state.dart';

// Achievement definitions
class Achievement {
  final String id;
  final String emoji;
  final String title;
  final String desc;
  final Color color;
  const Achievement({
    required this.id,
    required this.emoji,
    required this.title,
    required this.desc,
    required this.color,
  });
}

const List<Achievement> kAchievements = [
  Achievement(id: 'first_spin',  emoji: '🎰', title: 'First Spin!',       desc: 'Spin the reels for the first time',   color: Color(0xFFFFCC00)),
  Achievement(id: 'first_win',   emoji: '🎉', title: 'First Win!',        desc: 'Score your first coin match',          color: Color(0xFF4CAF50)),
  Achievement(id: 'streak_3',    emoji: '🔥', title: 'On Fire!',           desc: 'Win 3 times in a row',                color: Color(0xFFFF5722)),
  Achievement(id: 'streak_5',    emoji: '🌋', title: 'Unstoppable!',       desc: 'Win 5 times in a row',                color: Color(0xFFFF1744)),
  Achievement(id: 'coins_5000',  emoji: '💰', title: '5K Club',            desc: 'Reach 5,000 coins',                   color: Color(0xFFFFD700)),
  Achievement(id: 'coins_10000', emoji: '🤑', title: '10K Elite',          desc: 'Reach 10,000 coins',                  color: Color(0xFFFF8800)),
  Achievement(id: 'spins_50',    emoji: '🎡', title: 'Committed',          desc: 'Spin the reels 50 times',             color: Color(0xFF2196F3)),
  Achievement(id: 'spins_100',   emoji: '💫', title: 'Spin Master',        desc: 'Spin the reels 100 times',            color: Color(0xFF9C27B0)),
  Achievement(id: 'scatter_1',   emoji: '🌟', title: 'Scatter Hunter',     desc: 'Trigger your first Free Spins round', color: Color(0xFFAA88FF)),
  Achievement(id: 'jackpot_1',   emoji: '7️⃣',  title: 'Lucky Seven!',      desc: 'Hit the Lucky 7 jackpot',             color: Color(0xFFFF4444)),
];

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final unlocked = state.unlocked;
    final unlockedCount = unlocked.values.where((v) => v).length;

    return Scaffold(
      backgroundColor: const Color(0xFF080810),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🏆 Achievements',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$unlockedCount of ${kAchievements.length} unlocked',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: unlockedCount / kAchievements.length,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Stats Summary ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildStatsSummary(state),
            ),
            const SizedBox(height: 16),

            // ── Achievement Grid ──────────────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                physics: const BouncingScrollPhysics(),
                itemCount: kAchievements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final ach = kAchievements[i];
                  final isUnlocked = unlocked[ach.id] ?? false;
                  return _buildAchievementTile(ach, isUnlocked);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary(GameState state) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _miniStat('🎲', state.totalSpins.toString(), 'Spins'),
          _divider(),
          _miniStat('✅', state.totalWins.toString(), 'Wins'),
          _divider(),
          _miniStat('🔥', state.bestStreak.toString(), 'Best Streak'),
          _divider(),
          _miniStat('🌟', state.scattersHit.toString(), 'Scatters'),
        ],
      ),
    );
  }

  Widget _miniStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _divider() => Container(width: 1, height: 36, color: Colors.white10);

  Widget _buildAchievementTile(Achievement ach, bool isUnlocked) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnlocked ? ach.color.withOpacity(0.08) : const Color(0xFF0F0F18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? ach.color.withOpacity(0.5) : Colors.white.withOpacity(0.05),
          width: 1.5,
        ),
        boxShadow: isUnlocked
            ? [BoxShadow(color: ach.color.withOpacity(0.15), blurRadius: 12)]
            : [],
      ),
      child: Row(
        children: [
          // Emoji / lock
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isUnlocked ? ach.color.withOpacity(0.15) : Colors.white.withOpacity(0.04),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isUnlocked
                  ? Text(ach.emoji, style: const TextStyle(fontSize: 28))
                  : const Icon(Icons.lock, color: Colors.white24, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          // Title + desc
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ach.title,
                  style: TextStyle(
                    color: isUnlocked ? Colors.white : Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  ach.desc,
                  style: TextStyle(
                    color: isUnlocked ? Colors.grey[400] : Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Badge
          if (isUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ach.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '✓',
                style: TextStyle(color: ach.color, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
