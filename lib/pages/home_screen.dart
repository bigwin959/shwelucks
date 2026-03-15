import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state.dart';

const _kCyan   = Color(0xFF00F5FF);
const _kViolet = Color(0xFF7B2FFF);

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
            _buildTitleRow(),
            const SizedBox(height: 20),
            _buildStatsCards(state),
            const SizedBox(height: 20),
            _buildDailyBonusCard(context, state),
            const SizedBox(height: 20),
            _buildSynthesizeNowCard(context),
            const SizedBox(height: 20),
            _buildLabTips(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      children: [
        // Real ShweLucks logo
        SizedBox(
          width: 88,
          height: 88,
          child: Image.asset('assets/logo.png', fit: BoxFit.contain),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [_kCyan, _kViolet],
              ).createShader(b),
              child: const Text(
                'ShweLucks',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
            ),
            const Text(
              'Molecular Synthesis · Free to Experiment',
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
        _statCard('⚡', 'Energy', state.coins.toString(),         _kCyan),
        const SizedBox(width: 10),
        _statCard('📈', 'Peak EU',  state.highScore.toString(),   const Color(0xFF00FF99)),
        const SizedBox(width: 10),
        _statCard('🔬', 'Experiments', state.totalSpins.toString(), const Color(0xFF9966FF)),
      ],
    );
  }

  Widget _statCard(String emoji, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14),
                maxLines: 1, overflow: TextOverflow.ellipsis),
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
                  content: Text(
                    '⚗️ Daily Reagents Claimed! +200 EU',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: _kCyan,
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
                ? [const Color(0xFF001A15), const Color(0xFF00120D)]
                : [const Color(0xFF0F0F18), const Color(0xFF080810)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: canClaim ? const Color(0xFF00FF99).withOpacity(0.5) : Colors.grey.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: canClaim
              ? [const BoxShadow(color: Color(0x2200FF99), blurRadius: 16)]
              : [],
        ),
        child: Row(
          children: [
            Text(canClaim ? '⚗️' : '✅', style: const TextStyle(fontSize: 34)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    canClaim ? 'Daily Reagents Ready!' : 'Reagents Collected',
                    style: TextStyle(
                      color: canClaim ? Colors.white : Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    canClaim ? 'Tap to collect +200 EU free reagents' : 'Come back tomorrow for more!',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (canClaim)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF99).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00FF99), width: 1),
                ),
                child: const Text(
                  'COLLECT',
                  style: TextStyle(
                    color: Color(0xFF00FF99),
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

  Widget _buildSynthesizeNowCard(BuildContext context) {
    return GestureDetector(
      onTap: onPlayTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF080825), Color(0xFF04041A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kCyan.withOpacity(0.4), width: 1.5),
          boxShadow: const [BoxShadow(color: Color(0x2200F5FF), blurRadius: 20)],
        ),
        child: Row(
          children: [
            const Text('⚗️', style: TextStyle(fontSize: 48)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Synthesis Reactor',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Combine molecules · Trigger chain reactions!',
                    style: TextStyle(color: _kCyan.withOpacity(0.7), fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_kCyan, _kViolet]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Color(0x8800F5FF), blurRadius: 10)],
                    ),
                    child: const Text(
                      '⚗  SYNTHESIZE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Text('☢️', style: TextStyle(fontSize: 20)),
                const Text('Critical', style: TextStyle(color: Colors.grey, fontSize: 9)),
                const SizedBox(height: 4),
                Text('x50',
                  style: const TextStyle(color: _kCyan, fontWeight: FontWeight.w900, fontSize: 20)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabTips() {
    const tips = [
      ('⚗️',  'Match 3 identical molecules for a Chain Reaction!'),
      ('🌟',  'Trigger 3 Catalyst+ Scatters for 5 Free Reactions!'),
      ('🔥',  'Build a win streak to multiply your EU output!'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🔬 Lab Notes',
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
