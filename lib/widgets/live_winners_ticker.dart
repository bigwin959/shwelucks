import 'dart:async';
import 'package:flutter/material.dart';

class LiveWinnersTicker extends StatefulWidget {
  const LiveWinnersTicker({super.key});

  @override
  State<LiveWinnersTicker> createState() => _LiveWinnersTickerState();
}

class _LiveWinnersTickerState extends State<LiveWinnersTicker> {
  final PageController _controller = PageController(viewportFraction: 1.0);
  int _currentPage = 0;
  Timer? _timer;

  final List<String> _winners = const [
    "🎉 User 09*** won 50,000 Ks on Jili Games!",
    "⭐ User 09*** won 120,000 Ks on PG Soft!",
    "💎 User 09*** hit Jackpot 500,000 Ks!",
    "🔥 User 09*** won 25,000 Ks on Pragmatic Play!",
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      _currentPage = (_currentPage + 1) % _winners.length;
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
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: PageView.builder(
        controller: _controller,
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final int i = index % _winners.length;
          return Center(
            child: Text(
              _winners[i],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          );
        },
      ),
    );
  }
}
