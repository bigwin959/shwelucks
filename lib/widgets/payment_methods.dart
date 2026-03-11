import 'package:flutter/material.dart';

class PaymentMethods extends StatelessWidget {
  const PaymentMethods({super.key});

  final List<Map<String, dynamic>> methods = const [
    {"name": "KBZ Pay", "color": Colors.blueAccent},
    {"name": "Wave Pay", "color": Colors.yellowAccent},
    {"name": "CB Pay", "color": Colors.redAccent},
    {"name": "AYA Pay", "color": Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Trusted Payment Methods",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 15,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: methods.map((method) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_balance_wallet, color: method['color'], size: 18),
                  const SizedBox(width: 8),
                  Text(
                    method['name'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
