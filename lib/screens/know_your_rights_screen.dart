import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';

class KnowYourRightsScreen extends StatefulWidget {
  const KnowYourRightsScreen({super.key});

  @override
  State<KnowYourRightsScreen> createState() => _KnowYourRightsScreenState();
}

class _KnowYourRightsScreenState extends State<KnowYourRightsScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final Map<String, bool> _expandedState = {};
  String? _currentlySpeakingTitle;

  @override
  void initState() {
    super.initState();
    _initTTS();
  }

  Future<void> _initTTS() async {
    await flutterTts.setLanguage("en-IN");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    flutterTts.setCompletionHandler(() {
      setState(() {
        _currentlySpeakingTitle = null;
      });
    });
    flutterTts.setCancelHandler(() {
      setState(() {
        _currentlySpeakingTitle = null;
      });
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void _speak(String title, String text) async {
    await flutterTts.stop();
    setState(() {
      _currentlySpeakingTitle = title;
    });
    await flutterTts.speak(text);
  }

  void _launchPhoneDialer(String number) async {
    final Uri url = Uri.parse('tel:$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open phone dialer')),
      );
    }
  }

  Widget buildInfoCard(
    String title,
    String emoji,
    List<String> points, {
    bool isHelpline = false,
  }) {
    _expandedState.putIfAbsent(title, () => false);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6A82FB).withOpacity(0.3),
            const Color(0xFFFC5C7D).withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              iconColor: Colors.white,
              collapsedIconColor: Colors.white70,
              onExpansionChanged: (expanded) {
                setState(() {
                  _expandedState[title] = expanded;
                });
              },
              title: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _currentlySpeakingTitle == title
                          ? Icons.stop
                          : Icons.volume_up,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      final combinedText = "$title: ${points.join('. ')}";
                      if (_currentlySpeakingTitle == title) {
                        flutterTts.stop();
                        setState(() {
                          _currentlySpeakingTitle = null;
                        });
                      } else {
                        _speak(title, combinedText);
                      }
                    },
                  ),
                ],
              ),
              children: points.map((point) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: isHelpline
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "• $point",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.call,
                                  color: Colors.greenAccent),
                              onPressed: () {
                                final phone =
                                    RegExp(r'\d{3,}').stringMatch(point);
                                if (phone != null) _launchPhoneDialer(phone);
                              },
                            )
                          ],
                        )
                      : Text(
                          "• $point",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: const Text(
          "Know Your Rights",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF302B63),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 30, top: 16),
        children: [
          buildInfoCard("Your Legal Rights", "📜", [
            "Right to File an FIR at any police station (Zero FIR)",
            "Right to Privacy while recording statements",
            "Right to Virtual Complaint via email or post",
            "Right to Legal Aid and free legal services",
          ]),
          buildInfoCard("Important Laws for Women", "⚖️", [
            "Section 354 IPC: Outraging modesty of women",
            "Section 509 IPC: Words or gestures intended to insult modesty",
            "POSH Act: Protection against workplace harassment",
            "Domestic Violence Act, 2005",
          ]),
          buildInfoCard("Emergency Helplines", "📞", [
            "Women Helpline: 1091",
            "Police: 100",
            "Emergency (All India): 112",
            "Child Helpline: 1098",
            "National Commission for Women: 7827170170",
          ], isHelpline: true),
          buildInfoCard("What to Do in an Emergency", "🚨", [
            "Call 1091 or 112 immediately",
            "Use SOS feature on your phone",
            "Note down vehicle number, location, or identity markers",
            "Try to move to a public place if unsafe",
            "Share your live location with trusted contacts",
          ]),
        ],
      ),
    );
  }
}
