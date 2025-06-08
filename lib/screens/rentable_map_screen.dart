import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/rental_service.dart';

class RentableMapScreen extends StatefulWidget {
  final LatLng initialPosition;

  const RentableMapScreen({super.key, required this.initialPosition});

  @override
  State<RentableMapScreen> createState() => _RentableMapScreenState();
}

class _RentableMapScreenState extends State<RentableMapScreen> {
  final RentalService _rentalService = RentalService();
  Set<Marker> _rentableMarkers = {};

  @override
  void initState() {
    super.initState();
    _loadRentableMarkers();
  }

  // Added logging to debug marker generation and rendering.
  Future<void> _loadRentableMarkers() async {
    print("Loading rentable markers...");
    final markers = await _rentalService.getRentableMarkers(
      'assets/all_rent.json',
    );
    print("Markers loaded: ${markers.length}");
    if (mounted) {
      setState(() {
        _rentableMarkers = markers;
        print("Markers set: ${_rentableMarkers.length}");
      });
    } else {
      print("Widget is no longer mounted, skipping setState.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('可租房屋地圖'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialPosition,
              zoom: 14.0,
            ),
            markers: _rentableMarkers,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '宜居評分: 85', // Replace with dynamic score
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
