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
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initialPosition,
          zoom: 14.0,
        ),
        markers: _rentableMarkers,
      ),
    );
  }
}
