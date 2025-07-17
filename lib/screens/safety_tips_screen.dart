import 'package:flutter/material.dart';

class SafetyTipsScreen extends StatelessWidget {
  const SafetyTipsScreen({super.key});

  // Neon safety tip card builder
  Widget buildNeonCard({
    required IconData icon,
    required String title,
    required List<String> tips,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            const Color(0xFF0F0C29),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 14,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...tips.map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "• ",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        Expanded(
                          child: Text(
                            tip,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29), // Matches KnowYourRightsScreen
      appBar: AppBar(
        backgroundColor: const Color(0xFF302B63), // Dark violet shade
        title: const Text(
          "Safety Tips",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 6,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Be Prepared. Be Safe.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            buildNeonCard(
              icon: Icons.security,
              title: "General Personal Safety",
              color: Colors.purpleAccent,
              tips: [
                "Stay aware of your surroundings",
                "Avoid isolated or poorly lit areas",
                "Trust your instincts—leave if something feels off",
                "Keep your phone charged at all times",
                "Share your location with someone you trust",
              ],
            ),
            buildNeonCard(
              icon: Icons.lock,
              title: "Travel Safety",
              color: Colors.lightBlueAccent,
              tips: [
                "Note down vehicle number before entering",
                "Use trusted cab services with live tracking",
                "Avoid sleeping in public transport when alone",
                "Share ride info with friends or family",
              ],
            ),
            buildNeonCard(
              icon: Icons.flash_on,
              title: "Emergency Readiness",
              color: Colors.orangeAccent,
              tips: [
                "Keep SOS apps ready and accessible",
                "Learn basic self-defense or carry pepper spray",
                "Save emergency contacts on speed dial",
              ],
            ),
            buildNeonCard(
              icon: Icons.home,
              title: "At Home",
              color: Colors.pinkAccent,
              tips: [
                "Do not open doors to unknown people",
                "Avoid posting 'home alone' updates",
                "Install a peephole or smart doorbell if possible",
                "Use double locks for added security",
              ],
            ),
            buildNeonCard(
              icon: Icons.nightlight_round,
              title: "Night Safety",
              color: Colors.indigoAccent,
              tips: [
                "Avoid walking alone in poorly lit streets",
                "Remove distractions like headphones",
                "Walk confidently and alert",
                "Choose longer but safer routes",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
