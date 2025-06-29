import 'package:flutter/material.dart';

class BinsScreen extends StatelessWidget {
  final List<Map<String, String>> data = [
    {
      'name': 'Tempat Sampah Lalamentik',
      'openTime': '15:00',
      'closeTime': '22:00',
      'pickupTime': '22:00',
      'image':
          'https://i0.wp.com/www.thecity.nyc/wp-content/uploads/2024/07/070824_sanitation_bins_1-scaled.jpg?resize=1200%2C800&ssl=1',
    },
    {
      'name': 'Tempat Sampah Jalan Merdeka',
      'openTime': '15:00',
      'closeTime': '22:00',
      'pickupTime': '22:00',
      'image':
          'https://i0.wp.com/www.thecity.nyc/wp-content/uploads/2024/07/070824_sanitation_bins_1-scaled.jpg?resize=1200%2C800&ssl=1',
    },
    {
      'name': 'Tempat Sampah Jalan Pahlawan',
      'openTime': '15:00',
      'closeTime': '22:00',
      'pickupTime': '22:00',
      'image':
          'https://i0.wp.com/www.thecity.nyc/wp-content/uploads/2024/07/070824_sanitation_bins_1-scaled.jpg?resize=1200%2C800&ssl=1',
    },
  ];
  BinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tempat Sampah"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF2F2F7), // Apple-like light gray
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item['image']!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                item['name']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "${item['openTime']!} - ${item['closeTime']!}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.local_shipping, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "Diangkut Pukul ${item['pickupTime']!}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
      ),
    );
  }
}
