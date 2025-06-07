import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class RentalService {
  Future<Set<Marker>> getRentableMarkers(String assetPath) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> rentalData = json.decode(jsonString);

      Set<Marker> markers = {};

      for (var rental in rentalData) {
        final String? addressField = rental['address'];

        if (addressField != null) {
          final cleanedAddresses = addressField
              .replaceAll(RegExp(r'[\\/]+'), ' ') // Replace slashes with spaces
              .split(' '); // Split multiple addresses

          for (var address in cleanedAddresses) {
            if (address.trim().isNotEmpty) {
              try {
                final LatLng position = await _getLatLngFromAddress(address);
                markers.add(
                  Marker(
                    markerId: MarkerId(address),
                    position: position,
                    infoWindow: InfoWindow(title: '租屋', snippet: address),
                  ),
                );
              } catch (e) {
                print('Error geocoding address: $address, $e');
              }
            }
          }
        }
      }

      return markers;
    } catch (e) {
      print('Error loading rental data: $e');
      return {};
    }
  }

  // Enhanced _getLatLngFromAddress with detailed logging and fallback logic.
  Future<LatLng> _getLatLngFromAddress(String address) async {
    try {
      print("Geocoding address: $address");
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        print(
          "Geocoding successful: ${locations.first.latitude}, ${locations.first.longitude}",
        );
        return LatLng(locations.first.latitude, locations.first.longitude);
      } else {
        print("No results found for address: $address");
      }
    } catch (e) {
      print("Error geocoding address: $address, $e");
    }
    print("Fallback to default location for address: $address");
    return const LatLng(0, 0); // Default fallback
  }
}
