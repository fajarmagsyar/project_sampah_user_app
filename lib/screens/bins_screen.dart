import 'package:flutter/material.dart';
import 'package:trash_user_app/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BinsScreen extends StatefulWidget {
  const BinsScreen({super.key});

  @override
  State<BinsScreen> createState() => _BinsScreenState();
}

class _BinsScreenState extends State<BinsScreen> {
  List data = [];

  @override
  void initState() {
    super.initState();
    fetchBins();
  }

  Future<void> fetchBins() async {
    final res = await http.get(Uri.parse('${backendGlobalUrl}public/bins'));
    if (res.statusCode == 200) {
      setState(() {
        data = json.decode(res.body);
      });
    } else {
      throw Exception('Failed to load bins');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tempat Sampah"), elevation: 0),
      backgroundColor: const Color(0xFFF2F2F7), // Apple-like light gray
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchBins();
        },
        child: ListView.builder(
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
                        Icon(
                          Icons.local_shipping,
                          color: Colors.grey,
                          size: 16,
                        ),
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
      ),
    );
  }
}
