import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rent_right_place/utils/location_utils.dart'; // Assuming you have this for distance calculation

class MedicalFacilityService {
  final LatLng currentPosition;

  MedicalFacilityService({required this.currentPosition});

  // Assumed structure for a facility from JSON
  // {
  //   "type": "Feature",
  //   "properties": {"NAME": "Hospital Name"}, // Or similar property for name
  //   "geometry": {"type": "Point", "coordinates": [longitude, latitude]}
  // }
  // Or a simpler list of objects:
  // [ {"name": "Hospital Name", "latitude": 25.0, "longitude": 121.0} ]

  Future<Map<String, dynamic>> loadAndProcessFacilities() async {
    print("MedicalFacilityService: Loading medical facilities...");
    Set<Marker> hospitalMarkers = {};
    double minDistance = double.infinity;
    int medicalScore = 0;
    const double maxDisplayRadius =
        2000.0; // Max radius to display hospital markers

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/taipei_medical_facilities.json',
      );
      final dynamic jsonData = json.decode(jsonString);

      List<dynamic> facilities = [];

      if (jsonData is Map &&
          jsonData.containsKey('features') &&
          jsonData['features'] is List) {
        // Assuming GeoJSON FeatureCollection structure
        facilities = jsonData['features'];
      } else if (jsonData is List) {
        // Assuming a simple list of facility objects
        facilities = jsonData;
      } else {
        print(
          "MedicalFacilityService: Unknown JSON structure for medical facilities.",
        );
        return {'medicalScore': 0, 'hospitalMarkers': <Marker>{}};
      }

      if (facilities.isEmpty) {
        print(
          "MedicalFacilityService: No medical facilities found in the JSON data.",
        );
      }

      for (var i = 0; i < facilities.length; i++) {
        final facilityData = facilities[i] as Map<String, dynamic>?;
        if (facilityData == null) continue;

        String? facilityName;
        LatLng? facilityPosition;

        // Attempt to parse based on GeoJSON-like structure first
        if (facilityData.containsKey('properties') &&
            facilityData.containsKey('geometry')) {
          final properties =
              facilityData['properties'] as Map<String, dynamic>?;
          // Common possible name fields, add more as needed
          facilityName =
              properties?['NAME'] as String? ??
              properties?['name'] as String? ??
              properties?['FACILITY_NAME'] as String? ??
              '醫療機構 ${i + 1}';

          final geometry = facilityData['geometry'] as Map<String, dynamic>?;
          if (geometry?['type'] == 'Point' &&
              geometry?['coordinates'] is List) {
            final coords = geometry!['coordinates'] as List<dynamic>;
            if (coords.length == 2 && coords[0] is num && coords[1] is num) {
              // Assuming WGS84: [longitude, latitude]
              facilityPosition = LatLng(
                coords[1].toDouble(),
                coords[0].toDouble(),
              );
            }
          }
        }
        // Attempt to parse based on simpler {name, latitude, longitude} structure
        else if (facilityData.containsKey('latitude') &&
            facilityData.containsKey('longitude')) {
          facilityName =
              facilityData['name'] as String? ??
              facilityData['NAME'] as String? ??
              '醫療機構 ${i + 1}';
          final lat = facilityData['latitude'];
          final lon = facilityData['longitude'];
          if (lat is num && lon is num) {
            facilityPosition = LatLng(lat.toDouble(), lon.toDouble());
          }
        }

        if (facilityPosition == null) {
          print(
            "MedicalFacilityService: Could not parse coordinates for facility: $facilityName",
          );
          continue;
        }

        // Validate WGS84 coordinates (basic check)
        if (facilityPosition.latitude < -90 ||
            facilityPosition.latitude > 90 ||
            facilityPosition.longitude < -180 ||
            facilityPosition.longitude > 180) {
          print(
            "MedicalFacilityService: Invalid WGS84 coordinates for $facilityName: $facilityPosition. Skipping.",
          );
          continue;
        }

        double distance = LocationUtils.calculateDistanceInMeters(
          currentPosition,
          facilityPosition,
        );

        if (distance < minDistance) {
          minDistance = distance;
        }

        if (distance <= maxDisplayRadius) {
          hospitalMarkers.add(
            Marker(
              markerId: MarkerId('hospital_$i'),
              position: facilityPosition,
              infoWindow: InfoWindow(
                title: facilityName,
                snippet: '距離: ${distance.toStringAsFixed(0)} 公尺',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRose,
              ), // Different color for hospitals
            ),
          );
        }
      }

      if (minDistance == double.infinity && hospitalMarkers.isEmpty) {
        print(
          "MedicalFacilityService: No hospitals found within display radius or in data.",
        );
        medicalScore = 0;
      } else if (minDistance <= 500) {
        medicalScore = 5;
      } else if (minDistance <= 1000) {
        medicalScore = 3;
      } else if (minDistance <= 2000) {
        medicalScore = 1;
      } else {
        medicalScore = 0; // Closest hospital is > 2000m
      }
      print(
        "MedicalFacilityService: Closest hospital at ${minDistance.toStringAsFixed(0)}m. Score: $medicalScore. Markers: ${hospitalMarkers.length}",
      );
    } catch (e, s) {
      print(
        'MedicalFacilityService: Error loading or processing medical facility data: $e',
      );
      print('Stack trace: $s');
      return {
        'medicalScore': 0,
        'hospitalMarkers': <Marker>{},
      }; // Return default on error
    }

    return {'medicalScore': medicalScore, 'hospitalMarkers': hospitalMarkers};
  }
}
