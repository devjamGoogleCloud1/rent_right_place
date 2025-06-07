import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final LatLng initialPosition;

  const MapScreen({super.key, required this.initialPosition});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  late LatLng _currentPosition;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialPosition;
    // 在地圖初始化時，使用 initialPosition 新增一個標記
    _addMarker(_currentPosition, "搜尋的位置");
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _addMarker(LatLng position, String title) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(title),
          position: position,
          infoWindow: InfoWindow(title: title),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地圖位置'),
        backgroundColor: Colors.green[700],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentPosition,
          zoom: 15.0,
        ),
        markers: _markers,
      ),
    );
  }
}
