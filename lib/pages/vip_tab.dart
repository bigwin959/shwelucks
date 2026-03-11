import 'package:flutter/material.dart';

class VipTab extends StatelessWidget {
  const VipTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "VIP Club",
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // VIP Badge
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.amber[800]!, Colors.amber[200]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.diamond, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 20),

              // Current Status
              const Text(
                "Current Rank: VIP 3",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),

              // Progress Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("2,450 XP", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                        Text("5,000 XP (VIP 4)", style: TextStyle(color: Colors.white54)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 2450 / 5000,
                        backgroundColor: Colors.black,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Earn 2,550 more XP to unlock VIP 4 benefits!",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Benefits List
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Your Current Benefits",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              _buildBenefitRow(Icons.monetization_on, "Daily Cashback increased to 3%"),
              _buildBenefitRow(Icons.support_agent, "Priority 24/7 Customer Support"),
              _buildBenefitRow(Icons.card_giftcard, "Weekly VIP Mystery Bonus"),
              _buildBenefitRow(Icons.fast_forward, "Accelerated Withdrawals"),

              const SizedBox(height: 50), // Padding for nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.amber, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
