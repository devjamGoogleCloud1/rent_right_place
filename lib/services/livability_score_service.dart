import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rent_right_place/services/medical_facility_service.dart';
import 'package:rent_right_place/services/store_score_service.dart';
import 'package:rent_right_place/services/transport_score_service.dart';

class LivabilityScoreService {
  final MedicalFacilityService medicalFacilityService;
  final StoreScoreService storeScoreService;
  final TransportScoreService transportScoreService;

  LivabilityScoreService({
    required this.medicalFacilityService,
    required this.storeScoreService,
    required this.transportScoreService,
  });
  Future<double> calculateLivabilityScore(LatLng currentPosition) async {
    try {
      // Calculate individual scores
      final medicalData = await medicalFacilityService
          .loadAndProcessFacilities();
      final medicalScore = medicalData['medicalScore']?.toDouble() ?? 0.0;

      final storeData = await storeScoreService.calculateStoreScore(
        currentPosition,
        'assets/family_store.json',
      );
      final storeScore = storeData['storeScore']?.toDouble() ?? 0.0;

      final transportScore = await transportScoreService
          .calculateTransportScore(currentPosition, 'assets/見車率.json');

      // Apply weights
      const medicalWeight = 0.2;
      const storeWeight = 0.3;
      const transportWeight = 0.4;
      const disasterWeight = 0.1;

      //4 category weighting for disaster preparedness

      // Calculate weighted score (normalize each to 0-100 scale)
      final livabilityScore =
          (medicalScore *
              medicalWeight *
              20) + // Medical score is 0-5, multiply by 20 to get 0-100
          (storeScore *
              storeWeight *
              20) + // Store score is 0-5, multiply by 20 to get 0-100
          (transportScore *
              transportWeight *
              20) + // Store score is 0-5, multiply by 20 to get 0-100
          (4 * // default score for disaster
              disasterWeight *
              20); // Transport score is 0-5, multiply by 20 to get 0-100

      // Normalize to 100
      return livabilityScore.clamp(0, 100);
    } catch (e) {
      print('Error calculating livability score: $e');
      return 0.0;
    }
  }
}
