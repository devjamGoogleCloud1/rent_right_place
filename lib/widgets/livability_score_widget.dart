import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // 匯入 LatLng

class LivabilityScoreWidget extends StatelessWidget {
  final ScrollController? scrollController; // Added scrollController
  final LatLng position; // 新增 position 參數
  final String? address; // 新增 address 參數

  const LivabilityScoreWidget({
    super.key,
    this.scrollController, // Updated constructor
    required this.position, // 將 position 設為必要參數
    this.address, // address 為可選參數
  });

  // Placeholder data for categories
  final List<Map<String, dynamic>> categories = const [
    {'name': '交通友善', 'score': 4, 'maxScore': 5, 'icon': Icons.directions_bus},
    {'name': '生活便利', 'score': 4, 'maxScore': 5, 'icon': Icons.storefront},
    {'name': '健康醫療', 'score': 4, 'maxScore': 5, 'icon': Icons.local_hospital},
    {'name': '風險安全', 'score': 4, 'maxScore': 5, 'icon': Icons.security},
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
    // You can now use widget.position and widget.address here
    // For example, to display the address:
    // Text(address ?? 'N/A', style: TextStyle(fontSize: 12, color: Colors.grey)),
    // const SizedBox(height: 10.0),

    // This is the core UI from LivabilityScoreScreen, without Scaffold/AppBar
    return SingleChildScrollView(
      controller: scrollController, // Use the passed scrollController
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Drag Handle ---
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(
                bottom: 10.0,
              ), // Add some space below the handle
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // --- Score Section ---
          Center(
            child: Column(
              children: [
                Text(
                  '88/100', // Placeholder, will be dynamic
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    // Changed from headlineSmall
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const Text(
                  '綜合宜居分數',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // --- Categories Section ---
          Text('評分詳情', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8.0),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.2, // Adjusted for potentially smaller space
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            category['icon'] as IconData,
                            color: Theme.of(context).primaryColor,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              category['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4), // 將高度從 6 調整為 4
                      Text(
                        '${category['score']}/${category['maxScore']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ), // Increased font size from 13 to 14
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20.0),

          // --- Nearby Properties Section ---
          Text('附近物件', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8.0),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: nearbyProperties.length,
            itemBuilder: (context, index) {
              final property = nearbyProperties[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: property['imagePlaceholder'] as Color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.house_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              property['title'] as String,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4.0),
                            ...(property['features'] as List<String>)
                                .map(
                                  (feature) => Padding(
                                    padding: const EdgeInsets.only(bottom: 1.0),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle_outline,
                                          size: 12,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 3),
                                        Expanded(
                                          child: Text(
                                            feature,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                            const SizedBox(height: 6.0),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  print('View property: ${property['title']}');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  textStyle: const TextStyle(fontSize: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: const Text('查看'),
                              ),
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
