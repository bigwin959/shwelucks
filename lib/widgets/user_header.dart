import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../game_state.dart';

class UserHeader extends StatelessWidget {
  const UserHeader({super.key});

  static String _rankLabel(int highScore) {
    if (highScore >= 50000) return 'Archmage';
    if (highScore >= 20000) return 'Sage';
    if (highScore >= 10000) return 'Alchemist';
    if (highScore >= 5000)  return 'Scholar';
    return 'Apprentice';
  }

  static int _rankLevel(int highScore) {
    if (highScore >= 50000) return 5;
    if (highScore >= 20000) return 4;
    if (highScore >= 10000) return 3;
    if (highScore >= 5000)  return 2;
    return 1;
  }

  static const kCyan   = Color(0xFF00F5FF);
  static const kViolet = Color(0xFF7B2FFF);

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<GameState>();
    final coins  = state.coins;
    final rank   = _rankLabel(state.highScore);
    final level  = _rankLevel(state.highScore);
    final fmt    = NumberFormat('#,###');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Avatar with cyan glow
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kCyan, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Color(0x4400F5FF), blurRadius: 12),
                      ],
                      image: const DecorationImage(
                        image: NetworkImage("https://i.pravatar.cc/150?img=11"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lab_9921 🧪',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: kCyan.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kCyan.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.science_rounded, color: kCyan, size: 12),
                            const SizedBox(width: 3),
                            Text(
                              'Rank $level · $rank',
                              style: const TextStyle(color: kCyan, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Notification
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No new lab alerts'), duration: Duration(seconds: 1)),
                ),
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kCyan.withOpacity(0.15)),
                      ),
                      child: const Icon(Icons.notifications_outlined, color: Colors.white54, size: 22),
                    ),
                    Positioned(
                      right: 8, top: 8,
                      child: Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(color: kCyan, shape: BoxShape.circle),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Energy balance card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kCyan.withOpacity(0.25), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: kCyan, size: 20),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Energy Units', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: coins, end: coins),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (_, val, __) => Text(
                        '${fmt.format(val)} EU',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [kCyan, kViolet]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '+ Charge',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
