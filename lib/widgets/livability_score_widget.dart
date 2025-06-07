import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LivabilityScoreWidget extends StatelessWidget {
  final ScrollController? scrollController;
  final LatLng position;
  final String? address;
  final double transportationScore; // Added transportationScore
  final double medicalScore;      // Added medicalScore

  const LivabilityScoreWidget({
    super.key,
    this.scrollController,
    required this.position,
    this.address,
    required this.transportationScore, // Made required
    required this.medicalScore,      // Made required
  });

  // Updated to use passed scores
  List<Map<String, dynamic>> get categories => [
        {
          'name': '交通友善',
          'score': (transportationScore / 20).round(), // Assuming max score 100, scale to 0-5
          'maxScore': 5,
          'icon': Icons.directions_bus,
          'details': '捷運站點親近性評分: ${transportationScore.toStringAsFixed(1)} / 100'
        },
        {'name': '生活便利', 'score': 4, 'maxScore': 5, 'icon': Icons.storefront, 'details': '此為範例資料'},
        {
          'name': '健康醫療',
          'score': medicalScore.round(), // Assuming medicalScore is already 0-5
          'maxScore': 5,
          'icon': Icons.local_hospital,
          'details': '鄰近醫療設施評分: ${medicalScore.toStringAsFixed(1)} / 5'
        },
        {'name': '風險安全', 'score': 4, 'maxScore': 5, 'icon': Icons.security, 'details': '此為範例資料'},
      ];

  // Placeholder data for nearby properties
  final List<Map<String, dynamic>> nearbyProperties = const [
    {
      'imagePlaceholder': Colors.blueGrey,
      'title': '花雕雞別墅',
      'features': ['電梯', '消防友善', '電視'],
    },
    {
      'imagePlaceholder': Colors.teal,
      'title': '溫馨小套房',
      'features': ['近捷運', '採光佳', '有陽台'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (address != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                address!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          Text(
            '緯度: ${position.latitude.toStringAsFixed(5)}, 經度: ${position.longitude.toStringAsFixed(5)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 15.0),
          const Text(
            '宜居評分',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 1.5, // Adjusted for better layout
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(category['icon'], color: Colors.green[700], size: 28),
                      const SizedBox(height: 8.0),
                      Text(
                        category['name'],
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        children: List.generate(category['maxScore'], (i) {
                          return Icon(
                            i < category['score']
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 18,
                          );
                        }),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        category['details'] ?? '', // Display details
                        style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20.0),
          const Text(
            '附近房源推薦',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: nearbyProperties.length,
            itemBuilder: (context, index) {
              final property = nearbyProperties[index];
              return Card(
                elevation: 2.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: property['imagePlaceholder'],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        // child: Icon(Icons.house_rounded, size: 40, color: Colors.white70),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              property['title'],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4.0),
                            Wrap(
                              spacing: 6.0,
                              runSpacing: 4.0,
                              children: (property['features'] as List<String>)
                                  .map((feature) => Chip(
                                        label: Text(feature, style: const TextStyle(fontSize: 10)),
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                                        backgroundColor: Colors.lightGreen[100],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                          side: BorderSide(color: Colors.green[200]!)
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
