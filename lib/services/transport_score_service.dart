import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rent_right_place/utils/location_utils.dart';

class TransportScoreService {
  Future<double> calculateTransportScore(
    LatLng currentPosition,
    String assetPath,
  ) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> geoJsonData = json.decode(jsonString);
      final List<dynamic> features = geoJsonData['features'];

      double transportScore = 0.0;

      for (var feature in features) {
        final properties = feature['properties'];
        final geometry = feature['geometry'];

        final double latitude = geometry['coordinates'][1];
        final double longitude = geometry['coordinates'][0];
        final String category = properties['category'];

        final LatLng stopPosition = LatLng(latitude, longitude);
        final double distance = LocationUtils.calculateDistanceInMeters(
          currentPosition,
          stopPosition,
        );

        double score = 0;
        if (distance <= 10) {
          score = 5;
        } else if (distance <= 50) {
          score = 4;
        } else if (distance <= 200) {
          score = 3;
        } else if (distance <= 500) {
          score = 2;
        } else if (distance <= 1000) {
          score = 1;
        }

        // Apply category weighting
        if (category == '高') {
          score *= 1.5;
        } else if (category == '中') {
          score *= 1.0;
        } else if (category == '低') {
          score *= 0.5;
        }

        transportScore += score;
      }

      // Normalize score to a range of 0 to 5
      return transportScore.clamp(0, 5);
    } catch (e) {
      print('Error calculating transport score: $e');
      return 0.0;
    }
  }
}
