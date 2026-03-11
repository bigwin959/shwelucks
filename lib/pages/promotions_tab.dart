import 'package:flutter/material.dart';

class PromotionsTab extends StatelessWidget {
  const PromotionsTab({super.key});

  final List<Map<String, dynamic>> _promos = const [
    {
      "title": "Welcome Bonus 100%",
      "subtitle": "Double your first deposit up to 500,000 Ks!",
      "icon": Icons.celebration,
      "color": Colors.amber,
    },
    {
      "title": "Daily Cashback 5%",
      "subtitle": "Get back 5% of your losses every day.",
      "icon": Icons.replay_circle_filled,
      "color": Colors.orangeAccent,
    },
    {
      "title": "Weekend Reload 50%",
      "subtitle": "Boost your weekend play with a 50% reload.",
      "icon": Icons.data_saver_on,
      "color": Colors.redAccent,
    },
    {
      "title": "VIP Exclusive Tourney",
      "subtitle": "Compete for a pool of 10,000,000 Ks!",
      "icon": Icons.emoji_events,
      "color": Colors.purpleAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Promotions",
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: _promos.length,
        itemBuilder: (context, index) {
          final promo = _promos[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[900]!, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.amber.withOpacity(0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: promo["color"].withOpacity(0.15),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: promo["color"].withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(promo["icon"], color: promo["color"], size: 30),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        promo["title"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  promo["subtitle"],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Redirecting to Claim Promotion...", style: TextStyle(color: Colors.black)),
                          backgroundColor: Colors.amber,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      "CLAIM NOW",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
