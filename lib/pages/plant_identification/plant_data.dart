import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PlantDataDisplay extends StatelessWidget {
  final Map<String, dynamic> suggestion;
  final File selectedImage;
  final String userEmail;

  const PlantDataDisplay({
    Key? key,
    required this.suggestion,
    required this.selectedImage,
    required this.userEmail,
  }) : super(key: key);

  Future<void> savePlantToFirestore(BuildContext context) async {
    try {
      final String commonName =
          suggestion['details']?['common_names']?[0] ?? 'Unknown';
      final String scientificName =
          suggestion['details']?['taxonomy']?['genus'] ?? 'Unknown';
      final String description = suggestion['details']?['description']
              ?['value'] ??
          'No description available.';
      final String synonyms =
          suggestion['details']?['synonyms']?.sublist(0, 2).join(', ') ??
              'None';
      final String edibleParts =
          suggestion['details']?['edible_parts']?.join(', ') ?? 'Not specified';
      final String wateringNeeds =
          suggestion['details']?['best_watering'] ?? 'Not specified';
      final String lightConditions =
          suggestion['details']?['best_light_condition'] ?? 'Not specified';
      final String soilType =
          suggestion['details']?['best_soil_type'] ?? 'Not specified';
      final String toxicityType =
          suggestion['details']?['toxicity'] ?? 'Not specified';
      final String commonUses =
          suggestion['details']?['common_uses'] ?? 'Not specified';
      final String culturalSignificance =
          suggestion['details']?['cultural_significance'] ?? 'Not specified';

      final plantData = {
        'common_name': commonName,
        'scientific_name': scientificName,
        'description': description,
        'synonyms': synonyms,
        'edible_parts': edibleParts,
        'watering_needs': wateringNeeds,
        'light_conditions': lightConditions,
        'soil_type': soilType,
        'toxicity_type': toxicityType,
        'common_uses': commonUses,
        'cultural_significance': culturalSignificance,
        'timestamp': FieldValue.serverTimestamp(),
      };

      final collectionRef = FirebaseFirestore.instance
          .collection('plant_collections')
          .doc(userEmail)
          .collection('plants');

      // Check if a plant with the same common name or scientific name already exists
      final existingPlantQuery =
          await collectionRef.where('common_name', isEqualTo: commonName).get();

      if (existingPlantQuery.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$commonName is already in your collection!')),
        );
        return; // Exit early if the plant already exists
      }

      // Add the plant to the collection if it doesn't already exist
      await collectionRef.add(plantData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('$commonName has been added to your collection!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save plant: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Data'),
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
                suggestion['details']?['common_names']?[0] ?? 'Unknown',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                suggestion['details']?['taxonomy']?['genus'] ?? 'Unknown',
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
                suggestion['details']?['description']?['value'] ??
                    'No description available.',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              // Details card
              _buildDetailsCard(),
              const SizedBox(height: 20),
              // Cool Facts section
              _buildCoolFactsSection(),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => savePlantToFirestore(context),
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: const Text(
                    "Save to Collection",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 6,
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to display the plant image
  Widget _buildPlantImage(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _placeholderImage();
              },
            )
          : _placeholderImage(),
    );
  }

  // Placeholder for image loading failure
  Widget _placeholderImage() {
    return Container(
      height: 200,
      color: Colors.grey[300],
      child: const Center(child: Text('No image available')),
    );
  }

  // Card to display details with icons and dividers
  Widget _buildDetailsCard() {
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
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
                "Synonyms:",
                suggestion['details']?['synonyms']?.sublist(0, 2).join(', ') ??
                    'None',
                Icons.library_books),
            const Divider(
              color: Colors.grey,
              indent: 15,
              endIndent: 15,
            ),
            _buildDetailRow(
                "Edible Parts:",
                suggestion['details']?['edible_parts']?.join(', ') ??
                    'Not specified',
                Icons.fastfood),
            const Divider(
              color: Colors.grey,
              indent: 15,
              endIndent: 15,
            ),
            _buildDetailRow(
                "Watering Needs:",
                suggestion['details']?['best_watering'] ?? 'Not specified',
                Icons.water),
            const Divider(
              color: Colors.grey,
              indent: 15,
              endIndent: 15,
            ),
            _buildDetailRow(
                "Light Condition:",
                suggestion['details']?['best_light_condition'] ??
                    'Not specified',
                Icons.wb_sunny),
            const Divider(
              color: Colors.grey,
              indent: 15,
              endIndent: 15,
            ),
            _buildDetailRow(
                "Soil Type:",
                suggestion['details']?['best_soil_type'] ?? 'Not specified',
                Icons.landscape),
            const Divider(
              color: Colors.grey,
              indent: 15,
              endIndent: 15,
            ),
            _buildDetailRow(
                "Toxicity:",
                suggestion['details']?['toxicity'] ?? 'Not specified',
                Icons.warning),
          ],
        ),
      ),
    );
  }

  // Cool Facts section for Common Uses and Cultural Significance without trimming
  Widget _buildCoolFactsSection() {
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
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
                "Common Uses:",
                suggestion['details']?['common_uses'] ?? 'Not specified',
                Icons.business,
                trim: false),
            const Divider(
              color: Colors.grey,
              indent: 15,
              endIndent: 15,
            ),
            _buildDetailRow(
                "Cultural Significance:",
                suggestion['details']?['cultural_significance'] ??
                    'Not specified',
                Icons.group,
                trim: false),
          ],
        ),
      ),
    );
  }

  // Detail row with icon, title, and value with optional trimming
  Widget _buildDetailRow(String title, String value, IconData icon,
      {bool trim = true}) {
    String displayValue = trim ? (value.split('.').first + '.') : value;

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
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                displayValue,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
