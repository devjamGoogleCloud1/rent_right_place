import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rent_right_place/utils/location_utils.dart';
import 'package:proj4dart/proj4dart.dart';

class MapScreen extends StatefulWidget {
  final LatLng initialPosition;
  final String? searchAddress;

  const MapScreen({
    super.key,
    required this.initialPosition,
    this.searchAddress,
  });

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  late LatLng _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  final Set<Marker> _mrtStationMarkers = {};

  static final Projection _twd97Proj = Projection.add(
    'EPSG:3826',
    '+proj=tmerc +lat_0=0 +lon_0=121 +k=0.9999 +x_0=250000 +y_0=0 +ellps=GRS80 +units=m +no_defs',
  );
  static final Projection _wgs84Proj = Projection.WGS84;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialPosition;
    print("MapScreen initState: Current Position = $_currentPosition");
    _addMarker(_currentPosition, widget.searchAddress ?? "搜尋的位置");

    _addCircle(
      _currentPosition,
      250.0,
      'circle_250m',
      Colors.green.withOpacity(0.1),
      Colors.greenAccent,
    );
    _addCircle(
      _currentPosition,
      500.0,
      'circle_500m',
      Colors.blue.withOpacity(0.1),
      Colors.blueAccent,
    );
    _addCircle(
      _currentPosition,
      750.0,
      'circle_750m',
      Colors.orange.withOpacity(0.1),
      Colors.orangeAccent,
    );

    _loadAndDisplayMrtStations();
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

  void _addCircle(
    LatLng center,
    double radius,
    String circleId,
    Color fillColor,
    Color strokeColor,
  ) {
    setState(() {
      _circles.add(
        Circle(
          circleId: CircleId(circleId),
          center: center,
          radius: radius,
          fillColor: fillColor,
          strokeColor: strokeColor,
          strokeWidth: 1,
        ),
      );
    });
  }

  LatLng _twd97ToWgs84(double twd97x, double twd97y) {
    final pointSrc = Point(x: twd97x, y: twd97y);
    final pointDest = _twd97Proj.transform(_wgs84Proj, pointSrc);
    if (pointDest.x != null && pointDest.y != null) {
      return LatLng(pointDest.y!, pointDest.x!);
    } else {
      print("Error: Coordinate transformation resulted in null values.");
      return const LatLng(0, 0);
    }
  }

  Marker? _processMrtFeature(
    Map<String, dynamic> feature,
    int index,
    LatLng currentPosition,
    double radiusInMeters,
  ) {
    final properties = feature['properties'] as Map<String, dynamic>?;
    final geometry = feature['geometry'] as Map<String, dynamic>?;
    final stationName = properties?['NAME'] as String? ?? '未知捷運站 $index';

    if (geometry == null ||
        geometry['type'] != 'Point' ||
        geometry['coordinates'] == null) {
      return null;
    }

    final coordsList = geometry['coordinates'] as List<dynamic>?;
    if (coordsList == null ||
        coordsList.length != 2 ||
        coordsList[0] == null ||
        coordsList[1] == null) {
      print(
        "Station $stationName has missing, null, or invalid TWD97 coordinate data structure.",
      );
      return null;
    }

    double twd97x, twd97y;
    if (coordsList[0] is num && coordsList[1] is num) {
      twd97x = coordsList[0].toDouble();
      twd97y = coordsList[1].toDouble();
    } else {
      print(
        "Invalid coordinate types for $stationName: ${coordsList[0].runtimeType}, ${coordsList[1].runtimeType}",
      );
      return null;
    }

    final LatLng stationWgs84Position = _twd97ToWgs84(twd97x, twd97y);
    if (stationWgs84Position.latitude == 0 &&
        stationWgs84Position.longitude == 0) {
      return null;
    }

    final double distance = LocationUtils.calculateDistanceInMeters(
      currentPosition,
      stationWgs84Position,
    );

    if (distance <= radiusInMeters) {
      return Marker(
        markerId: MarkerId('mrt_${stationName}_$index'),
        position: stationWgs84Position,
        infoWindow: InfoWindow(
          title: stationName,
          snippet: '距離 ${distance.toStringAsFixed(0)} 公尺',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    }
    return null;
  }

  Future<void> _loadAndDisplayMrtStations() async {
    print("_loadAndDisplayMrtStations: Started");
    try {
      final String assetPath = 'assets/TpeMrtStations_TWD97_FIDCODE.json';
      final String jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> features =
          jsonData['features'] as List<dynamic>? ?? [];

      final Set<Marker> newMrtMarkers = {};
      const double radiusInMeters = 750.0;
      int stationsInRadiusCount = 0;
      int invalidCoordCount = 0;

      for (var i = 0; i < features.length; i++) {
        final feature = features[i] as Map<String, dynamic>?;
        if (feature == null) {
          invalidCoordCount++;
          continue;
        }

        final Marker? marker = _processMrtFeature(
          feature,
          i,
          _currentPosition,
          radiusInMeters,
        );
        if (marker != null) {
          newMrtMarkers.add(marker);
          stationsInRadiusCount++;
        } else {
          invalidCoordCount++;
        }
      }

      print(
        "Processed all features. Stations within ${radiusInMeters}m radius: $stationsInRadiusCount. Invalid/Skipped stations: $invalidCoordCount.",
      );

      if (mounted) {
        setState(() {
          _mrtStationMarkers.addAll(newMrtMarkers);
        });
      }
    } catch (e, s) {
      print('Error loading or processing MRT station data: $e');
      print('Stack trace: $s');
    }
    print("_loadAndDisplayMrtStations: Finished");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.searchAddress ?? '地圖位置'),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 14.0, // Adjusted zoom to better see concentric circles
            ),
            markers: _markers.union(_mrtStationMarkers),
            circles: _circles,
            zoomControlsEnabled: true,
            padding: const EdgeInsets.only(bottom: 180.0),
          ),
        ],
      ),
    );
  }
}
