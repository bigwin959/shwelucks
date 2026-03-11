import 'dart:async';
import 'package:flutter/material.dart';

class LiveWinnersTicker extends StatefulWidget {
  const LiveWinnersTicker({super.key});

  @override
  State<LiveWinnersTicker> createState() => _LiveWinnersTickerState();
}

class _LiveWinnersTickerState extends State<LiveWinnersTicker> {
  final PageController _controller = PageController(viewportFraction: 1.0);
  int    _currentPage = 0;
  Timer? _timer;

  final List<String> _events = const [
    '⚗️  Lab_04*** synthesized Crystal x3  (+3,200 EU)',
    '🌀  Lab_12*** triggered Vortex Chain Reaction  (+8,750 EU)',
    '☢️  Lab_77*** achieved CRITICAL SYNTHESIS  (+42,000 EU)',
    '🧬  Lab_33*** completed Helix formula  (+1,800 EU)',
    '💎  Lab_08*** unlocked Crystal Formation  (+12,500 EU)',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _currentPage = (_currentPage + 1) % _events.length;
      _controller.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF00F5FF).withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00F5FF).withOpacity(0.2)),
      ),
      child: PageView.builder(
        controller: _controller,
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final int i = index % _events.length;
          return Center(
            child: Text(
              _events[i],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xBBFFFFFF),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          );
        },
      ),
    );
  }
}
