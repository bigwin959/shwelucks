import 'package:flutter/material.dart';
import '../widgets/slot_game.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080810),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── App Header ──────────────────────────────────────────
                _buildHeader(),
                const SizedBox(height: 24),

                // ── Game ─────────────────────────────────────────────────
                const SlotGame(),

                const SizedBox(height: 24),

                // ── For Entertainment Only badge ─────────────────────────
                _buildDisclaimerBadge(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF2A1A00), Color(0xFF1A0D00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.amber.withOpacity(0.6), width: 2),
            boxShadow: [
              BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 30, spreadRadius: 5),
            ],
          ),
          child: const Center(
            child: Text('🎰', style: TextStyle(fontSize: 40)),
          ),
        ),
        const SizedBox(height: 12),

        // Title
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFF8800), Color(0xFFFFD700)],
          ).createShader(bounds),
          child: const Text(
            'LUCKY REELS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Spin & Match to Win Virtual Coins!',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimerBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, color: Colors.white38, size: 15),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'For entertainment only · No real money · Free to play',
              style: TextStyle(color: Colors.white38, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
