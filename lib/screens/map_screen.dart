import 'dart:convert'; // Keep for potential future use, though direct JSON processing is moved
import 'package:flutter/services.dart'
    show rootBundle; // Keep for potential future use
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rent_right_place/services/medical_facility_service.dart';
import 'package:rent_right_place/services/store_score_service.dart'; // Import StoreScoreService
import 'package:rent_right_place/widgets/livability_score_widget.dart';

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
  final Set<Marker> _markers = {}; // For the main searched location marker
  Set<Marker> _hospitalMarkers = {}; // Added for hospital markers
  Set<Marker> _storeMarkers = {}; // Added for store markers

  // Scores
  double _medicalScore = 0.0;
  double _storeScore = 0.0; // Added for store score

  // Services
  late final MedicalFacilityService _medicalFacilityService;
  late final StoreScoreService _storeScoreService; // Added StoreScoreService

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialPosition;
    _medicalFacilityService = MedicalFacilityService(
      currentPosition: _currentPosition,
    );
    _storeScoreService = StoreScoreService();
    print("MapScreen initState: Current Position = $_currentPosition");
    _addMarker(_currentPosition, widget.searchAddress ?? "搜尋的位置");
    _loadMedicalFacilities();
    _loadStoreData(); // Load store data
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

  Future<void> _loadMedicalFacilities() async {
    print("_loadMedicalFacilities: Started for $_currentPosition");

    try {
      final medicalData = await _medicalFacilityService
          .loadAndProcessFacilities();
      if (mounted) {
        setState(() {
          _hospitalMarkers = medicalData['hospitalMarkers'] ?? {};
          _medicalScore = medicalData['medicalScore']?.toDouble() ?? 0.0;
          print(
            "Medical Score: $_medicalScore, Hospital Markers: ${_hospitalMarkers.length}",
          );
        });
      }
    } catch (e, s) {
      print('Error loading medical facility data in MapScreen: $e');
      print('Stack trace: $s');
      if (mounted) {
        setState(() {
          _medicalScore = 0.0; // Reset score on error
        });
      }
    }
    print("_loadMedicalFacilities: Finished. Med Score: $_medicalScore");
  }

  Future<void> _loadStoreData() async {
    try {
      final storeData = await _storeScoreService.calculateStoreScore(
        _currentPosition,
        'assets/family_store.json',
      );
      if (mounted) {
        setState(() {
          _storeMarkers = storeData['storeMarkers'] ?? {};
          _storeScore = storeData['storeScore']?.toDouble() ?? 0.0;
        });
      }
    } catch (e, s) {
      print('Error loading store data in MapScreen: $e');
      print('Stack trace: $s');
      if (mounted) {
        setState(() {
          _storeScore = 0.0; // Reset score on error
        });
      }
    }
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
              zoom: 14.0,
            ),
            markers: _markers
                .union(_hospitalMarkers)
                .union(_storeMarkers), // Combined all markers
            zoomControlsEnabled: true,
            padding: const EdgeInsets.only(
              bottom: 180.0,
            ), // To avoid overlap with DraggableScrollableSheet
          ),
          DraggableScrollableSheet(
            initialChildSize:
                0.3, // Adjusted initial size to 30% of screen height
            minChildSize: 0.2, // Adjusted minimum size to 20%
            maxChildSize: 0.6, // Adjusted maximum size to 60%
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: LivabilityScoreWidget(
                  scrollController: scrollController,
                  position: _currentPosition,
                  address: widget.searchAddress,
                  medicalScore: _medicalScore, // Pass medical score
                  transportationScore:
                      _storeScore, // Updated to pass store score
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
