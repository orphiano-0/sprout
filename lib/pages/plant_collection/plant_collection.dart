import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'plant_reminder.dart'; // Import the PlantReminder page

class PlantCollection extends StatelessWidget {
  const PlantCollection({super.key});

  Future<List<Map<String, dynamic>>> _fetchPlantCollections() async {
    final String? userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) {
      throw Exception("No user is logged in");
    }

    // Fetch the plants collection for the logged-in user
    final collectionRef = FirebaseFirestore.instance
        .collection('plant_collections')
        .doc(userEmail)
        .collection('plants');

    final querySnapshot = await collectionRef.get();

    // Extract and return plant data
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Collection'),
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPlantCollections(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No plants found in your collection.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          }

          final plants = snapshot.data!;

          return ListView.builder(
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              final plantName = plant['common_name'] ?? 'Unknown';
              final scientificName = plant['scientific_name'] ?? 'Unknown';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4, // Adds a shadow effect
                child: InkWell(
                  onTap: () {
                    // Navigate to PlantReminder page with required data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlantReminder(
                          plantId: plantName, // Replace with the correct ID if available
                          collectionId: 'placeholder', // Adjust if needed
                          plantName: plantName,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12), // Matches card border radius
                  child: Padding(
                    padding: const EdgeInsets.all(12), // Adds padding inside the card
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Leading icon or image
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.eco, color: Colors.green, size: 32),
                        ),
                        const SizedBox(width: 12),
                        // Plant details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plantName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18, // Larger font for the name
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Scientific name: $scientificName',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14, // Slightly smaller font for the scientific name
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Action icon
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).colorScheme.inverseSurface,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
