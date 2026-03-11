import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state.dart';

const _kCyan   = Color(0xFF00F5FF);
const _kViolet = Color(0xFF7B2FFF);

// Formula tablet definitions (alchemy-themed achievements)
class Formula {
  final String id;
  final String emoji;
  final String title;
  final String desc;
  final Color  color;
  const Formula({
    required this.id,
    required this.emoji,
    required this.title,
    required this.desc,
    required this.color,
  });
}

const List<Formula> kFormulas = [
  Formula(id: 'first_spin',  emoji: '⚗️', title: 'First Synthesis',     desc: 'Run your first molecular reaction',      color: _kCyan),
  Formula(id: 'first_win',   emoji: '🧪', title: 'First Reaction!',      desc: 'Trigger your first successful bond',     color: Color(0xFF00FF99)),
  Formula(id: 'streak_3',    emoji: '🔥', title: 'Chain Reaction x3',    desc: 'Win 3 reactions in a row',               color: Color(0xFFFF6644)),
  Formula(id: 'streak_5',    emoji: '🌋', title: 'Unstable Chain x5',    desc: 'Win 5 reactions in a row',               color: Color(0xFFFF2244)),
  Formula(id: 'coins_5000',  emoji: '💰', title: '5K EU Reserve',        desc: 'Accumulate 5,000 Energy Units',          color: Color(0xFF00CFFF)),
  Formula(id: 'coins_10000', emoji: '🤑', title: '10K EU Vault',         desc: 'Accumulate 10,000 Energy Units',         color: _kCyan),
  Formula(id: 'spins_50',    emoji: '🔬', title: '50 Experiments',       desc: 'Complete 50 synthesis experiments',      color: Color(0xFF88AAFF)),
  Formula(id: 'spins_100',   emoji: '🌀', title: 'Synthesis Master',     desc: 'Complete 100 synthesis experiments',     color: _kViolet),
  Formula(id: 'scatter_1',   emoji: '🌟', title: 'Catalyst Trigger',     desc: 'Activate your first Catalyst+ event',    color: Color(0xFFAA44FF)),
  Formula(id: 'jackpot_1',   emoji: '☢️', title: 'Critical Synthesis!',  desc: 'Achieve a Critical Synthesis reaction',  color: Color(0xFFFF2244)),
];

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state         = context.watch<GameState>();
    final unlocked      = state.unlocked;
    final unlockedCount = unlocked.values.where((v) => v).length;

    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🧫 Formula Tablets',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$unlockedCount of ${kFormulas.length} formulas unlocked',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: unlockedCount / kFormulas.length,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(_kCyan),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Stats Summary ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildLabStats(state),
            ),
            const SizedBox(height: 16),

            // ── Formula Tablets Grid ─────────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                physics: const BouncingScrollPhysics(),
                itemCount: kFormulas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final f          = kFormulas[i];
                  final isUnlocked = unlocked[f.id] ?? false;
                  return _buildFormulaTile(f, isUnlocked);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabStats(GameState state) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kCyan.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kCyan.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _miniStat('⚗️',  state.totalSpins.toString(),  'Experiments'),
          _divider(),
          _miniStat('✅',  state.totalWins.toString(),  'Reactions'),
          _divider(),
          _miniStat('🔥',  state.bestStreak.toString(), 'Best Chain'),
          _divider(),
          _miniStat('🌟',  state.scattersHit.toString(),'Catalysts'),
        ],
      ),
    );
  }

  Widget _miniStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _divider() => Container(width: 1, height: 36, color: Colors.white10);

  Widget _buildFormulaTile(Formula f, bool isUnlocked) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnlocked ? f.color.withOpacity(0.07) : const Color(0xFF0A0A18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? f.color.withOpacity(0.55) : Colors.white.withOpacity(0.04),
          width: 1.5,
        ),
        boxShadow: isUnlocked
            ? [BoxShadow(color: f.color.withOpacity(0.18), blurRadius: 14)]
            : [],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: isUnlocked ? f.color.withOpacity(0.12) : Colors.white.withOpacity(0.03),
              shape: BoxShape.circle,
              border: isUnlocked
                  ? Border.all(color: f.color.withOpacity(0.4), width: 1)
                  : null,
            ),
            child: Center(
              child: isUnlocked
                  ? Text(f.emoji, style: const TextStyle(fontSize: 26))
                  : const Icon(Icons.lock_outlined, color: Colors.white12, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.title,
                  style: TextStyle(
                    color: isUnlocked ? Colors.white : Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  f.desc,
                  style: TextStyle(
                    color: isUnlocked ? Colors.grey[400] : Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: f.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('✓', style: TextStyle(color: f.color, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}
