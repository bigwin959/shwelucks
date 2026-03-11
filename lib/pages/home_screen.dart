import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onPlayTap;
  const HomeScreen({super.key, required this.onPlayTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App Title Row ─────────────────────────────────────────────
            _buildTitleRow(),
            const SizedBox(height: 20),

            // ── Stats Cards ───────────────────────────────────────────────
            _buildStatsCards(state),
            const SizedBox(height: 20),

            // ── Daily Bonus Card ──────────────────────────────────────────
            _buildDailyBonusCard(context, state),
            const SizedBox(height: 20),

            // ── Play Now Card ─────────────────────────────────────────────
            _buildPlayNowCard(context),
            const SizedBox(height: 20),

            // ── Tips Section ──────────────────────────────────────────────
            _buildTips(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFF2A1A00), Color(0xFF1A0D00)],
            ),
            border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5),
          ),
          child: const Center(child: Text('🎰', style: TextStyle(fontSize: 24))),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFF8800)],
              ).createShader(b),
              child: const Text(
                'Lucky Reels',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
            const Text(
              'Virtual Coins · Free to Play',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards(GameState state) {
    return Row(
      children: [
        _statCard('🪙', 'My Coins', state.coins.toString(), Colors.amber),
        const SizedBox(width: 10),
        _statCard('🏆', 'High Score', state.highScore.toString(), Colors.greenAccent),
        const SizedBox(width: 10),
        _statCard('🎯', 'Total Spins', state.totalSpins.toString(), Colors.blue[300]!),
      ],
    );
  }

  Widget _statCard(String emoji, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 15),
            ),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyBonusCard(BuildContext context, GameState state) {
    final canClaim = state.canClaimBonus;
    return GestureDetector(
      onTap: canClaim
          ? () {
              state.claimBonus(200);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎁 Daily Bonus Claimed! +200 Coins'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: canClaim
                ? [const Color(0xFF1A2A00), const Color(0xFF0D1800)]
                : [const Color(0xFF1A1A1A), const Color(0xFF111111)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: canClaim ? Colors.greenAccent.withOpacity(0.6) : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: canClaim
              ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.1), blurRadius: 16)]
              : [],
        ),
        child: Row(
          children: [
            Text(canClaim ? '🎁' : '✅', style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    canClaim ? 'Daily Bonus Ready!' : 'Daily Bonus Claimed',
                    style: TextStyle(
                      color: canClaim ? Colors.white : Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    canClaim ? 'Tap to claim +200 free coins!' : 'Come back tomorrow for more!',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (canClaim)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.greenAccent, width: 1),
                ),
                child: const Text(
                  'CLAIM',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayNowCard(BuildContext context) {
    return GestureDetector(
      onTap: onPlayTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A1A00), Color(0xFF1A0D00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.amber.withOpacity(0.12), blurRadius: 20),
          ],
        ),
        child: Row(
          children: [
            const Text('🎰', style: TextStyle(fontSize: 48)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lucky Slots',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Match 3 symbols · Earn bonus coins!',
                    style: TextStyle(color: Colors.amber[300], fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFCC00), Color(0xFFFF8800)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '▶  PLAY NOW',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTips() {
    const tips = [
      ('⭐', 'Land 3 Stars for a big coin bonus!'),
      ('🌟', 'Match 3 Scatters to unlock 5 Free Spins!'),
      ('🔥', 'Keep winning to build a streak multiplier!'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💡 Tips',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...tips.map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(tip.$1, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(tip.$2, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
