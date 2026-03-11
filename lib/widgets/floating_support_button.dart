import 'package:flutter/material.dart';

class FloatingSupportButton extends StatelessWidget {
  const FloatingSupportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.6),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          // TODO: Link to Live Chat or Viber/Telegram Support
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Connecting to Shwe Lucks Support...", style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.blueGrey,
            ),
          );
        },
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        elevation: 8,
        child: const Icon(Icons.support_agent, size: 30),
      ),
    );
  }
}
