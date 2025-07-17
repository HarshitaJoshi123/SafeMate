import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareLiveLocationWithLocationPlugin extends StatefulWidget {
  const ShareLiveLocationWithLocationPlugin({super.key});

  @override
  State<ShareLiveLocationWithLocationPlugin> createState() =>
      _ShareLiveLocationWithLocationPluginState();
}

class _ShareLiveLocationWithLocationPluginState
    extends State<ShareLiveLocationWithLocationPlugin> {
  final Location location = Location();
  bool _loading = false;
  String? _locationUrl;

  // Check & request location permission + service
  Future<bool> _setupLocation() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return false;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }

    return true;
  }

  // Fetch current location & construct Google Maps URL
  Future<void> _fetchLocation() async {
    setState(() => _loading = true);
    print("Fetching location...");

    final canAccess = await _setupLocation();
    print("Location permission granted: $canAccess");

    if (!canAccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "We can't access your location. Did you allow location access?")),
      );
      setState(() => _loading = false);
      return;
    }

    try {
      final loc = await location.getLocation();
      print("Got location: ${loc.latitude}, ${loc.longitude}");

      final url =
          'https://www.google.com/maps/search/?api=1&query=${loc.latitude},${loc.longitude}';

      setState(() {
        _locationUrl = url;
      });
    } catch (e) {
      print("Location error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // Open WhatsApp with location message
  Future<void> _shareOnWhatsApp() async {
    if (_locationUrl == null) return;

    final message =
        Uri.encodeComponent("Here is my live location: $_locationUrl");
    final whatsappUrl = "whatsapp://send?text=$message";

    final uri = Uri.parse(whatsappUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("WhatsApp not installed or can't be opened")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: const Text('Share Live Location',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF302B63),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'Share your real‑time location via WhatsApp.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text("Fetch My Location"),
              onPressed: _loading ? null : _fetchLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A2387),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(color: Colors.white),
            if (_locationUrl != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _locationUrl!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.contact_emergency),
                label: const Text("Share on WhatsApp"),
                onPressed: _shareOnWhatsApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
