import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactButtons extends StatelessWidget {
  const ContactButtons({super.key});

  Future<void> _launch(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget buildButton({
    required String text,
    required IconData icon,
    required Color color,
    required String url,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _launch(url),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.6),
                blurRadius: 15,
                spreadRadius: 1,
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildButton(
          text: "Contact Telegram",
          icon: Icons.send,
          color: Colors.green[700]!,
          url: "https://t.me/", // TODO: Add Shwe Lucks Telegram
        ),
        buildButton(
          text: "Contact Facebook",
          icon: Icons.facebook,
          color: Colors.red[800]!,
          url: "https://www.facebook.com/", // TODO: Add Shwe Lucks Facebook
        ),
      ],
    );
  }
}