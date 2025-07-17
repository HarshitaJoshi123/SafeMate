import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class EmergencyEscapeScreen extends StatefulWidget {
  const EmergencyEscapeScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyEscapeScreen> createState() => _EmergencyEscapeScreenState();
}

class _EmergencyEscapeScreenState extends State<EmergencyEscapeScreen> {
  GoogleMapController? _mapController;
  final Location _location = Location();
  LatLng? _currentLatLng;
  final LatLng _safeLocation =
      const LatLng(28.6210, 77.0879); // Example Safe Location
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  final FlutterTts _tts = FlutterTts();
  String _distance = "";
  String _duration = "";
  final String _apiKey = 'YOUR_API_KEY_HERE'; // Replace with your API key

  @override
  void initState() {
    super.initState();
    _initLocationAndRoute();
  }

  Future<void> _initLocationAndRoute() async {
    final permission = await _location.requestPermission();
    if (permission != PermissionStatus.granted) return;

    final currentLocation = await _location.getLocation();
    _currentLatLng =
        LatLng(currentLocation.latitude!, currentLocation.longitude!);

    _addSafeMarker();
    _drawSafeRoute();
  }

  void _addSafeMarker() {
    _markers.add(
      Marker(
        markerId: const MarkerId("safe_marker"),
        position: _safeLocation,
        infoWindow: const InfoWindow(title: "Safe Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
  }

  Future<void> _drawSafeRoute() async {
    if (_currentLatLng == null) return;

    final start = _currentLatLng!;
    final end = _safeLocation;

    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&mode=walking&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if ((data['routes'] as List).isEmpty) {
          _showError("No route found.");
          return;
        }

        final route = data['routes'][0];
        final points = route['overview_polyline']['points'];
        final legs = route['legs'][0];

        _distance = legs['distance']['text'];
        _duration = legs['duration']['text'];

        List<PointLatLng> decodedPoints =
            PolylinePoints().decodePolyline(points);

        List<LatLng> polylineCoordinates =
            decodedPoints.map((e) => LatLng(e.latitude, e.longitude)).toList();

        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId("safe_route"),
            color: Colors.red,
            width: 5,
            points: polylineCoordinates,
          ),
        );

        setState(() {}); // Update UI
        await _speakRouteInfo();
      } else {
        _showError("Failed to fetch route. Try again.");
      }
    } catch (e) {
      _showError("An error occurred. Please check your connection.");
    }
  }

  Future<void> _speakRouteInfo() async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.0);
    await _tts.speak(
        "Safe route loaded. Estimated distance is $_distance and time is $_duration.");
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ $message")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Escape"),
        backgroundColor: Colors.redAccent,
        elevation: 0, // Removes shadow under the app bar
        iconTheme: const IconThemeData(
            color: Colors.white), // Ensure icons are visible
      ),
      body: _currentLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLatLng!,
                    zoom: 15,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled:
                      false, // Hide default button, use custom
                  onMapCreated: (controller) => _mapController = controller,
                ),
                // Custom My Location Button
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: _goToCurrentLocation,
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.my_location, color: Colors.white),
                  ),
                ),
                Positioned(
                  top: 15,
                  left: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.directions_walk,
                                color: Colors.redAccent),
                            const SizedBox(width: 8),
                            Text("Distance: $_distance",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.timer, color: Colors.redAccent),
                            const SizedBox(width: 8),
                            Text("ETA: $_duration",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "📍 Follow the red route to reach your safe location.",
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
                // Panic Button
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 75, // Place above the My Location button
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle panic action
                        _showError("Panic button pressed!");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("🆘 Panic!"),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Added function to animate the camera to the current location
  Future<void> _goToCurrentLocation() async {
    final locData = await _location.getLocation();
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(locData.latitude ?? 0.0, locData.longitude ?? 0.0),
          zoom: 15,
        ),
      ),
    );
  }
}
