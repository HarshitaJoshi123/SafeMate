import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:location/location.dart';
import 'package:safemate/models/contact_model.dart';
import 'package:safemate/screens/emergency_escape_screen.dart';
import 'package:safemate/screens/journey_timer_screen.dart';
import 'package:safemate/screens/know_your_rights_screen.dart';
import 'package:safemate/screens/report_incident_screen.dart';
import 'package:safemate/screens/safety_tips_screen.dart';
import 'package:safemate/screens/settings_screen.dart';
import 'package:safemate/screens/share_live_location_screen.dart';
import 'package:safemate/screens/view_contacts_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Location _locationSvc = Location();
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer(); // ✅ Added for panic alarm

  Future<void> _triggerSOS() async {
    try {
      bool service = await _locationSvc.serviceEnabled();
      if (!service) service = await _locationSvc.requestService();
      if (!service) return;

      final permission = await _locationSvc.requestPermission();
      if (permission != PermissionStatus.granted) return;

      final loc = await _locationSvc.getLocation();
      final lat = loc.latitude;
      final lon = loc.longitude;
      final mapsUrl =
          "https://www.google.com/maps/search/?api=1&query=$lat,$lon";
      final message =
          "🚨 SOS ALERT 🚨\nI need help immediately!\nMy current location: $mapsUrl";

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String>? saved = prefs.getStringList('emergency_contacts');

      if (saved == null || saved.isEmpty) {
        await _tts.speak("No emergency contacts found. Please add them first.");
        return;
      }

      final List<EmergencyContact> contacts =
          saved.map((e) => EmergencyContact.fromJson(jsonDecode(e))).toList();

      for (var contact in contacts) {
        final smsUri = Uri.parse(
            "sms:${contact.number}?body=${Uri.encodeComponent(message)}");
        final whatsappUri = Uri.parse(
            "https://wa.me/${contact.number}?text=${Uri.encodeComponent(message)}");

        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri, mode: LaunchMode.externalApplication);
        }

        if (await canLaunchUrl(whatsappUri)) {
          await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        }
      }

      await _tts.speak("SOS sent to all emergency contacts.");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("📨 SOS sent to all saved contacts!"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      print("❌ SOS Error: $e");
      await _tts.speak("Failed to send SOS. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF8A2387)),
              child: Text('SafeMate Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            drawerTile(context, Icons.home, 'Home', const HomeScreen()),
            drawerTile(context, Icons.timer, 'My Journey Timer',
                const JourneyTimerScreen()),
            drawerTile(context, Icons.location_on, 'Share Live Location',
                const ShareLiveLocationWithLocationPlugin()),
            drawerTile(context, Icons.emergency_rounded, 'Emergency Escape',
                const EmergencyEscapeScreen()),
            drawerTile(context, Icons.report, 'Report Incident', const ReportIncidentScreen()),

            drawerTile(context, Icons.gavel, 'Know Your Rights',
                const KnowYourRightsScreen()),
            drawerTile(
                context, Icons.shield, 'Safety Tips', const SafetyTipsScreen()),
            ListTile(
              leading: Icon(Icons.contacts),
              title: Text('Emergency Contacts'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ViewContactsScreen()),
                );
              },
            ),
            drawerTile(
                context, Icons.settings, 'Settings', const SettingsScreen()),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("SafeMate", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF302B63),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Welcome to SafeMate',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: [Colors.pink, Colors.blueAccent],
                    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your safety companion — anytime, anywhere.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 30),
              // Logo
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE94057), Color(0xFF8A2387)],
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.purple.shade300,
                        blurRadius: 20,
                        spreadRadius: 2)
                  ],
                ),
                child: ClipOval(
                  child:
                      Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 30),

              // Carousel
              CarouselSlider(
                options: CarouselOptions(
                  height: 160.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  autoPlayInterval: const Duration(seconds: 3),
                ),
                items: [
                  'assets/images/1_new.png',
                  'assets/images/2_new.png',
                  'assets/images/3_new.png'
                ].map((imgPath) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.purple.shade100, blurRadius: 12)
                          ],
                          image: DecorationImage(
                            image: AssetImage(imgPath),
                            fit: BoxFit.fill,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              // Emergency SOS Button
              gradientButton(
                icon: Icons.warning,
                text: "Emergency SOS",
                color1: const Color(0xFFDA4453),
                color2: const Color(0xFF89216B),
                onPressed: _triggerSOS,
              ),

              const SizedBox(height: 15),

              // Panic Alarm Button
              gradientButton(
                icon: Icons.volume_up,
                text: "Panic Alarm",
                color1: const Color(0xFFFF416C),
                color2: const Color(0xFFFF4B2B),
                onPressed: () async {
                  // _tts.speak("⚠️ Panic Alarm Triggered! Please assist!");
                  // await _audioPlayer.play(AssetSource(
                  //     'sounds/siren.mp3')); // ✅ Play siren sound from assets
                  try {
                    await _audioPlayer.play(AssetSource('sounds/siren.mp3'));
                  } catch (e) {
                    print('Audio error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Audio error: $e')),
                    );
                  }

                  // Optional: Auto-stop after 10 seconds
                  Future.delayed(Duration(seconds: 10), () {
                    _audioPlayer.stop(); // ✅ Stop siren after 10 seconds
                  });
                },
              ),

              const SizedBox(height: 30),

              const Text(
                '“Empowering you to walk fearless. Tap the menu to explore features.”',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget gradientButton({
    required IconData icon,
    required String text,
    required Color color1,
    required Color color2,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color1, color2]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: color1.withOpacity(0.6), blurRadius: 10, spreadRadius: 1)
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(text,
            style: const TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  ListTile drawerTile(
      BuildContext context, IconData icon, String title, Widget screen) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
    );
  }
}