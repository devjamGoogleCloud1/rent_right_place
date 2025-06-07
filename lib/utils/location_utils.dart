import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationUtils {
  // 計算兩個 WGS84 經緯度點之間的距離（單位：公尺），使用 Haversine 公式
  static double calculateDistanceInMeters(LatLng pos1, LatLng pos2) {
    const double earthRadius = 6371000; // 地球半徑，單位：公尺

    double lat1Rad = pos1.latitude * (pi / 180);
    double lon1Rad = pos1.longitude * (pi / 180);
    double lat2Rad = pos2.latitude * (pi / 180);
    double lon2Rad = pos2.longitude * (pi / 180);

    double dLat = lat2Rad - lat1Rad;
    double dLon = lon2Rad - lon1Rad;

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }
}
