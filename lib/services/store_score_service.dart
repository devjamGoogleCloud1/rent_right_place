import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rent_right_place/utils/location_utils.dart';

class StoreScoreService {
  Future<Map<String, dynamic>> calculateStoreScore(
    LatLng currentPosition,
    String assetPath,
  ) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> storeData = json.decode(jsonString);

      double storeScore = 0.0;
      Set<Marker> storeMarkers = {};

      for (var store in storeData) {
        final double? lat = store['lat'];
        final double? lon = store['lon'];
        if (lat == null || lon == null) continue;

        final LatLng storePosition = LatLng(lat, lon);

        final double distance = LocationUtils.calculateDistanceInMeters(
          currentPosition,
          storePosition,
        );

        if (distance <= 500) {
          storeScore += 5;
        } else if (distance <= 1000) {
          storeScore += 3;
        } else if (distance <= 2000) {
          storeScore += 1;
        }

        storeMarkers.add(
          Marker(
            markerId: MarkerId(store['address'] ?? 'unknown'),
            position: storePosition,
            infoWindow: InfoWindow(
              title: '超商',
              snippet: '距離 ${distance.toStringAsFixed(0)} 公尺',
            ),
          ),
        );
      }

      return {'storeScore': storeScore, 'storeMarkers': storeMarkers};
    } catch (e) {
      print('Error calculating store score: $e');
      return {'storeScore': 0.0, 'storeMarkers': {}};
    }
  }
}
