import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:trash_user_app/config.dart';

class MapScreen extends StatefulWidget {
  final Map<String, dynamic>? selectedBin;

  const MapScreen({super.key, this.selectedBin});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List bins = [];
  LatLng? _currentLocation;
  List<LatLng> routePoints = [];

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    fetchBins();
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    if (widget.selectedBin != null) {
      final binLocation = LatLng(
        widget.selectedBin!['lat'],
        widget.selectedBin!['lng'],
      );
      await loadRouteToBin(_currentLocation!, binLocation);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showBinDialog(widget.selectedBin!);
      });
    }
  }

  Future<void> fetchBins() async {
    final res = await http.get(Uri.parse('${backendGlobalUrl}public/bins'));

    if (res.statusCode == 200) {
      setState(() {
        bins = json.decode(res.body);
      });
    }
  }

  Future<List<LatLng>> fetchRouteFromORS(LatLng start, LatLng end) async {
    const apiKey =
        '5b3ce3597851110001cf6248723935fc205e4f038aafe0178d638bf9'; // Replace with your key
    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car',
    );

    final body = json.encode({
      "coordinates": [
        [start.longitude, start.latitude],
        [end.longitude, end.latitude],
      ],
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': apiKey},
      body: body,
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final geometry = decoded['features'][0]['geometry']['coordinates'];
      return geometry
          .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
          .toList();
    } else {
      throw Exception('Failed to fetch route');
    }
  }

  Future<void> loadRouteToBin(LatLng start, LatLng destination) async {
    try {
      final route = await fetchRouteFromORS(start, destination);
      setState(() {
        routePoints = route;
      });
    } catch (e) {
      print('Error loading route: $e');
    }
  }

  void showBinDialog(Map bin) {
    final lat = bin['lat'];
    final lng = bin['lng'];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(bin['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🕒 Open: ${bin['openTime']} - ${bin['closeTime']}"),
            Text("📦 Pickup: ${bin['pickupTime']}"),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.directions),
              label: const Text("Get Directions"),
              onPressed: () async {
                Navigator.of(context).pop();
                if (_currentLocation != null) {
                  final binLatLng = LatLng(lat, lng);
                  await loadRouteToBin(_currentLocation!, binLatLng);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Stack(
          children: [
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(color: Colors.white.withOpacity(0.2)),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                style: TextStyle(color: Colors.grey),
                                decoration: InputDecoration(
                                  hintText: 'Search...',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/300',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: _currentLocation!,
                initialZoom: 16,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      color: Colors.blue,
                      strokeWidth: 5,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: bins.map((bin) {
                    final lat = bin['lat'];
                    final lng = bin['lng'];
                    return Marker(
                      width: 50,
                      height: 50,
                      point: LatLng(lat, lng),
                      child: GestureDetector(
                        onTap: () async {
                          if (_currentLocation != null) {
                            final binLatLng = LatLng(lat, lng);
                            await loadRouteToBin(_currentLocation!, binLatLng);
                          }
                          showBinDialog(bin);
                        },
                        child: const Icon(
                          Icons.location_pin,
                          size: 40,
                          color: Colors.red,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}
