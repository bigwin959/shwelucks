import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state.dart';

const _kCyan   = Color(0xFF00F5FF);
const _kViolet = Color(0xFF7B2FFF);

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
        if (next != null) setState(() => _remaining = next.difference(DateTime.now()));
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
    final state    = context.watch<GameState>();
    final canClaim = state.canClaimBonus;
    final countdown = _formatCountdown(_remaining);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF080820),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kCyan.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(color: _kCyan.withOpacity(0.12), blurRadius: 12, spreadRadius: 2),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _kCyan.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Text('⚗️', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Reagent Drop',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    canClaim ? 'Collect 500 EU free reagents!' : 'Next drop in $countdown',
                    style: TextStyle(
                      color: canClaim ? _kCyan : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: canClaim
                ? GestureDetector(
                    key: const ValueKey('collect'),
                    onTap: () {
                      state.claimBonus(500);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '⚗️ +500 EU Daily Reagents collected!',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: _kCyan,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_kCyan, Color(0xFF00A8B5)]),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Color(0x7700F5FF), blurRadius: 10)],
                      ),
                      child: const Text(
                        'COLLECT',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    ),
                  )
                : Container(
                    key: const ValueKey('cooldown'),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Collected ✓',
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
