import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PlantDetailsPage extends StatelessWidget {
  final String plantId;
  final String userEmail;

  const PlantDetailsPage({
    Key? key,
    required this.plantId,
    required this.userEmail,
  }) : super(key: key);

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchPlantDetails() async {
    final document = await FirebaseFirestore.instance
        .collection('plant_collections')
        .doc(userEmail)
        .collection('plants')
        .doc(plantId)
        .get();
    return document;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Details'),
        backgroundColor: const Color.fromARGB(255, 105, 173, 108),
        centerTitle: true,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: fetchPlantDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load plant details.'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Plant details not found.'));
          }

          final plantData = snapshot.data!.data()!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plant common and scientific name
                  Text(
                    plantData['common_name'] ?? 'Unknown',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    plantData['scientific_name'] ?? 'Unknown',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 20),
                  // About section
                  const Text(
                    "About",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    plantData['description'] ?? 'No description available.',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  // Details card
                  _buildDetailsCard(plantData),
                  const SizedBox(height: 20),
                  // Cool Facts section
                  _buildCoolFactsSection(plantData),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailsCard(Map<String, dynamic> plantData) {
    return Card(
      color: Colors.green[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Details: 🌱",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 12),
            _buildDetailRow("Synonyms:", plantData['synonyms'] ?? 'None', Icons.library_books),
            const Divider(color: Colors.grey, indent: 15, endIndent: 15),
            _buildDetailRow("Edible Parts:", plantData['edible_parts'] ?? 'Not specified', Icons.fastfood),
            const Divider(color: Colors.grey, indent: 15, endIndent: 15),
            _buildDetailRow("Watering Needs:", plantData['watering_needs'] ?? 'Not specified', Icons.water),
            const Divider(color: Colors.grey, indent: 15, endIndent: 15),
            _buildDetailRow("Light Condition:", plantData['light_conditions'] ?? 'Not specified', Icons.wb_sunny),
            const Divider(color: Colors.grey, indent: 15, endIndent: 15),
            _buildDetailRow("Soil Type:", plantData['soil_type'] ?? 'Not specified', Icons.landscape),
            const Divider(color: Colors.grey, indent: 15, endIndent: 15),
            _buildDetailRow("Toxicity:", plantData['toxicity_type'] ?? 'Not specified', Icons.warning),
          ],
        ),
      ),
    );
  }

  Widget _buildCoolFactsSection(Map<String, dynamic> plantData) {
    return Card(
      color: Colors.lightGreen[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Cool Facts!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 10),
            _buildDetailRow("Common Uses:", plantData['common_uses'] ?? 'Not specified', Icons.business, trim: false),
            const Divider(color: Colors.grey, indent: 15, endIndent: 15),
            _buildDetailRow(
              "Cultural Significance:",
              plantData['cultural_significance'] ?? 'Not specified',
              Icons.group,
              trim: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, IconData icon, {bool trim = true}) {
    // String displayValue = trim ? (value.split('.').first + '.') : value;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
