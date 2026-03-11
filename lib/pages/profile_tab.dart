import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../game_state.dart';

const _kCyan   = Color(0xFF00F5FF);
const _kViolet = Color(0xFF7B2FFF);

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  static String _rankLabel(int highScore) {
    if (highScore >= 50000) return 'Archmage';
    if (highScore >= 20000) return 'Sage';
    if (highScore >= 10000) return 'Alchemist';
    if (highScore >= 5000)  return 'Scholar';
    return 'Apprentice';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final fmt   = NumberFormat('#,###');
    final rank  = _rankLabel(state.highScore);

    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── Lab Profile Hero ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF080825), Color(0xFF050510)],
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _kCyan, width: 3),
                          boxShadow: const [BoxShadow(color: Color(0x6600F5FF), blurRadius: 20, spreadRadius: 2)],
                          image: const DecorationImage(
                            image: NetworkImage("https://i.pravatar.cc/150?img=11"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(color: _kCyan, shape: BoxShape.circle),
                        child: const Icon(Icons.edit, color: Colors.black, size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Lab_9921',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kCyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _kCyan.withOpacity(0.5), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.science_rounded, color: _kCyan, size: 14),
                        const SizedBox(width: 4),
                        Text(rank,
                          style: const TextStyle(color: _kCyan, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Live Stats Row ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _statCard('${fmt.format(state.coins)} EU', 'Energy', Icons.bolt_rounded, _kCyan),
                  const SizedBox(width: 10),
                  _statCard(state.totalSpins.toString(), 'Experiments', Icons.science_rounded, const Color(0xFF9966FF)),
                  const SizedBox(width: 10),
                  _statCard(state.totalWins.toString(), 'Reactions', Icons.local_fire_department_rounded, const Color(0xFF00FF99)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Menu Items ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _menuItem(Icons.account_balance_wallet_rounded, 'EU Wallet', 'Deposit & Withdraw energy'),
                  _menuItem(Icons.history_rounded, 'Experiment Log', 'View all synthesis history'),
                  _menuItem(Icons.card_giftcard_rounded, 'Reagent Bonuses', '3 active formulas'),
                  _menuItem(Icons.security_rounded, 'Lab Security', 'PIN & access settings'),
                  _menuItem(Icons.support_agent_rounded, 'Lab Support', 'Contact chemists 24/7'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Sign Out ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text('Leave Lab', style: TextStyle(color: Colors.redAccent)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value,
              style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11),
              textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kCyan.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _kCyan, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}
