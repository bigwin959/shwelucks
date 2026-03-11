import 'package:flutter/material.dart';

class GameProviderGrid extends StatelessWidget {
  const GameProviderGrid({super.key});

  final List<Map<String, dynamic>> providers = const [
    {
      "name": "Jili Games",
      "icon": Icons.casino,
      "color": Colors.redAccent,
    },
    {
      "name": "PG Soft",
      "icon": Icons.videogame_asset,
      "color": Colors.orangeAccent,
    },
    {
      "name": "Pragmatic Play",
      "icon": Icons.gamepad,
      "color": Colors.blueAccent,
    },
    {
      "name": "Evolution",
      "icon": Icons.laptop_windows,
      "color": Colors.purpleAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            "Top Providers",
            style: TextStyle(
              color: Colors.amber,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: providers.length,
            itemBuilder: (context, index) {
              final provider = providers[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 15, left: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey[900]!, Colors.black],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      provider["icon"],
                      color: provider["color"],
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      provider["name"],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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
