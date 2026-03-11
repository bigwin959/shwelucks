import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state.dart';

class LoyaltyBanner extends StatefulWidget {
  const LoyaltyBanner({super.key});

  @override
  State<LoyaltyBanner> createState() => _LoyaltyBannerState();
}

class _LoyaltyBannerState extends State<LoyaltyBanner> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final state = context.read<GameState>();
      if (!state.canClaimBonus) {
        final next = state.nextBonusTime;
        if (next != null) {
          setState(() => _remaining = next.difference(DateTime.now()));
        }
      } else {
        setState(() => _remaining = Duration.zero);
      }
    });
  }

  String _formatCountdown(Duration d) {
    if (d.isNegative || d == Duration.zero) return '';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '${h}h ${m}m' : '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final state      = context.watch<GameState>();
    final canClaim   = state.canClaimBonus;
    final countdown  = _formatCountdown(_remaining);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: icon + text
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.card_giftcard, color: Colors.amber, size: 28),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Reward',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    canClaim ? 'Claim your free 500 Ks!' : 'Next bonus in $countdown',
                    style: TextStyle(
                      color: canClaim ? Colors.amberAccent : Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right: claim / disabled button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: canClaim
                ? ElevatedButton(
                    key: const ValueKey('claim'),
                    onPressed: () {
                      state.claimBonus(500);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '🎁 +500 Ks Daily Bonus claimed!',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Colors.amber,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text('CLAIM', style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                : Container(
                    key: const ValueKey('cooldown'),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Claimed ✓',
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
