import 'package:flutter/material.dart';

const _kCyan = Color(0xFF00F5FF);

class GameProviderGrid extends StatelessWidget {
  const GameProviderGrid({super.key});

  final List<Map<String, dynamic>> providers = const [
    {'name': 'Molecular Lab',   'icon': Icons.biotech_rounded,      'color': Color(0xFF00F5FF)},
    {'name': 'Plasma Works',    'icon': Icons.blur_on_rounded,      'color': Color(0xFF9966FF)},
    {'name': 'Crystal Forge',   'icon': Icons.diamond_rounded,      'color': Color(0xFF44DDFF)},
    {'name': 'Helix Studio',    'icon': Icons.loop_rounded,         'color': Color(0xFF00FF99)},
    {'name': 'Vortex Engine',   'icon': Icons.cyclone_rounded,      'color': Color(0xFFFF6644)},
    {'name': 'Catalyst Labs',   'icon': Icons.science_rounded,      'color': Color(0xFFFFAA00)},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Research Labs',
            style: TextStyle(color: _kCyan, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: providers.length,
            itemBuilder: (context, index) {
              final p = providers[index];
              final color = p['color'] as Color;
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12, left: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.08), const Color(0xFF050510)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: color.withOpacity(0.35), width: 1.2),
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.1), blurRadius: 8),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(p['icon'] as IconData, color: color, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      p['name'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
