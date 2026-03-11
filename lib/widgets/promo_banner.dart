import 'dart:async';
import 'package:flutter/material.dart';

class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  final PageController _controller = PageController();
  int    _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _promos = const [
    {'emoji': '☢️', 'title': 'Double Synthesis Weekend',   'sub': 'x2 EU on every Critical Synthesis'},
    {'emoji': '🧬', 'title': 'Helix Catalyst Event',       'sub': 'Rare Helix x3 combo pays 50 EU'},
    {'emoji': '🌀', 'title': 'Free Reaction Friday',       'sub': '5 free syntheses for all labs'},
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      _currentPage = (_currentPage + 1) % _promos.length;
      _controller.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
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
    return SizedBox(
      height: 80,
      child: PageView.builder(
        controller: _controller,
        itemCount: _promos.length,
        itemBuilder: (context, index) {
          final p = _promos[index];
          return Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D0D30), Color(0xFF14003A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF7B2FFF).withOpacity(0.6), width: 1.5),
              boxShadow: const [
                BoxShadow(color: Color(0x447B2FFF), blurRadius: 12, spreadRadius: 1),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(p['emoji']!, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      p['sub']!,
                      style: const TextStyle(color: Color(0xFFAA88FF), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}