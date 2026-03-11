import 'package:flutter/material.dart';
import '../widgets/slot_game.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                const SlotGame(),
                const SizedBox(height: 24),
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
        // Flask icon with glow
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF0A0A2A), Color(0xFF050510)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: const Color(0xFF00F5FF).withOpacity(0.7), width: 2),
            boxShadow: const [
              BoxShadow(color: Color(0x8800F5FF), blurRadius: 30, spreadRadius: 5),
            ],
          ),
          child: const Center(
            child: Text('⚗️', style: TextStyle(fontSize: 40)),
          ),
        ),
        const SizedBox(height: 12),

        // Title with cyan shader
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00F5FF), Color(0xFF7B2FFF), Color(0xFF00F5FF)],
          ).createShader(bounds),
          child: const Text(
            'SYNTHESIS LAB',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Combine molecules · Trigger reactions · Collect Energy',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDisclaimerBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00F5FF).withOpacity(0.1)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.science_outlined, color: Colors.white24, size: 15),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'Simulation only · No real currency · Free to experiment',
              style: TextStyle(color: Colors.white38, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
