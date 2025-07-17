import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0F0C29);
    const tileColor = Color(0xFF1F1B3A);
    const textColor = Colors.white;
    const subTextColor = Colors.white54;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF302B63),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // About SafeMate
          const Text(
            "About SafeMate",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            tileColor: tileColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            leading: const Icon(Icons.info_outline, color: Colors.tealAccent),
            title: const Text("App version 1.0.0", style: TextStyle(color: textColor)),
            subtitle: const Text(
              "SafeMate is built to enhance your personal safety with real-time features and emergency tools.",
              style: TextStyle(color: subTextColor),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white30),

          // Help & Support
          const Text(
            "Help & Support",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            tileColor: tileColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            leading: const Icon(Icons.help_outline, color: Colors.tealAccent),
            title: const Text("FAQs & Contact Support", style: TextStyle(color: textColor)),
            subtitle: const Text("Need help? Reach out to us.", style: TextStyle(color: subTextColor)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: subTextColor),
            onTap: () {
              // TODO: Implement contact navigation
            },
          ),
        ],
      ),
    );
  }
}
