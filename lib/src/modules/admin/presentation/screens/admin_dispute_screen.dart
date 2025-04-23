import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminDisputeScreen extends StatefulWidget {
  const AdminDisputeScreen({super.key});

  @override
  State<AdminDisputeScreen> createState() => _AdminDisputeScreenState();
}

class _AdminDisputeScreenState extends State<AdminDisputeScreen> {
  List<Map<String, dynamic>> disputes = [];

  @override
  void initState() {
    super.initState();
    fetchDisputes();
  }

  Future<void> fetchDisputes() async {
    try {
      final response = await http.get(Uri.parse('https://your-api-url.com/disputes'));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          disputes = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print("Error fetching disputes");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dispute Panel')),
      body: disputes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: disputes.length,
              itemBuilder: (context, index) {
                final dispute = disputes[index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Dispute Generated', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                        const SizedBox(height: 10),
                        Text('Campaign: ${dispute['campaignName']}'),
                        Text('Brand: ${dispute['brandName']}'),
                        Text('Influencer: ${dispute['influencerName']}'),
                        Text('Reported By: ${dispute['reportedBy']}'),
                        const SizedBox(height: 8),
                        Text('Report: ${dispute['reportText']}'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to campaign view screen
                            Navigator.pushNamed(context, '/campaign/${dispute['campaignId']}');
                          },
                          child: const Text('View Campaign'),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
