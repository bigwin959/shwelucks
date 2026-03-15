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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF080825), Color(0xFF0A0A20), Color(0xFF060618)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF00F5FF).withOpacity(0.35), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x3300F5FF), blurRadius: 24, spreadRadius: 2),
        ],
      ),
      child: Row(
        children: [
          // Glowing logo ring
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00F5FF).withOpacity(0.18),
                  const Color(0xFF7B2FFF).withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
              border: Border.all(color: const Color(0xFF00F5FF).withOpacity(0.4), width: 1.5),
              boxShadow: const [
                BoxShadow(color: Color(0x5500F5FF), blurRadius: 20, spreadRadius: 2),
              ],
            ),
            padding: const EdgeInsets.all(6),
            child: Image.asset('assets/logo.png', fit: BoxFit.contain),
          ),
          const SizedBox(width: 18),
          // Text section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF99).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00FF99).withOpacity(0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: Color(0xFF00FF99), size: 7),
                      SizedBox(width: 5),
                      Text('LIVE · ALCHEMY LAB',
                        style: TextStyle(
                          color: Color(0xFF00FF99),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [Color(0xFF00F5FF), Color(0xFFAA77FF)],
                  ).createShader(b),
                  child: const Text(
                    'ShweLucks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Synthesis Reactor · Free to Experiment',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // Right accent atoms
          Column(
            children: [
              const Text('⚗️', style: TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              const Text('☢️', style: TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
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
