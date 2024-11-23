import 'package:flutter/material.dart';
import 'dart:io';


class PlantHealthDisplay extends StatelessWidget {
  final Map<String, dynamic> suggestion;
  final File selectedImage;

  static List<Map<String, dynamic>> plantCollection = [];

  const PlantHealthDisplay({
    Key? key,
    required this.suggestion,
    required this.selectedImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Assessment'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the plant image from API
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  selectedImage,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              // Plant common and scientific name
              Text(
                suggestion['details']?['local_name'] ?? 'Unknown',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                "Probability",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                suggestion['probability']?.toStringAsFixed(2) ?? 'Unknown',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20,),
              // About section
              const Text(
                "About",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                suggestion['details']?['description'] ?? 'No description available.',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              // Treatments card
              _buildTreatmentsCard(suggestion),
            ],
          ),
        ),
      ),
    );
    
  }

  // Card to display only treatments
  Widget _buildTreatmentsCard(Map<String, dynamic> suggestion) {
    final treatmentData = suggestion['details']?['treatment'] ?? {};

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
              "Treatments: 🌱",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 12),
            ...treatmentData.entries.map((entry) => _buildTreatmentSection(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  // Method to create a section for each treatment category
  Widget _buildTreatmentSection(String title, dynamic treatmentList) {
    if (treatmentList is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title[0].toUpperCase() + title.substring(1) + ':',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 4),
          ...treatmentList.map<Widget>((treatment) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(
                  treatment,
                  style: const TextStyle(fontSize: 14),
                ),
              )),
          const Divider(color: Colors.grey, indent: 15, endIndent: 15),
        ],
      );
    }
    return const SizedBox.shrink(); // In case treatmentList is not a List
  }
}
