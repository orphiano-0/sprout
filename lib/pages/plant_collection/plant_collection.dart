import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sprout/pages/plant_collection/pages/soil_moisture_page.dart';
import 'plant_reminder.dart'; // Import the PlantReminder page
import 'pages/plant_details.dart'; // Import the PlantDetails page

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
    return querySnapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  Future<void> _deletePlant(String plantId, BuildContext context) async {
    final String? userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) {
      throw Exception("No user is logged in");
    }

    try {
      // Delete the plant from Firestore
      await FirebaseFirestore.instance
          .collection('plant_collections')
          .doc(userEmail)
          .collection('plants')
          .doc(plantId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plant deleted successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting plant: $error')),
      );
    }
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
              final plantId = plant['id'];

              return Dismissible(
                key: ValueKey(plantId),
                direction: DismissDirection.endToStart, // Allow swipe to the left
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Plant'),
                        content: const Text(
                            'Are you sure you want to delete this plant from your collection?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false); // Cancel deletion
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true); // Confirm deletion
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) {
                  _deletePlant(plantId, context);
                },
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 50, 90, 48), // Red gradient start
                        Color.fromARGB(255, 115, 98, 98), // Dark red gradient end
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Leading icon or image
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(12),
                              child:
                                  const Icon(Icons.eco, color: Colors.green, size: 40),
                            ),
                            const SizedBox(width: 16),
                            // Plant details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plantName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Scientific name: $scientificName',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Buttons for navigation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Button for setting a reminder
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlantReminder(
                                      plantId: plantId,
                                      collectionId: 'placeholder',
                                      plantName: plantName,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.alarm, color: Colors.green),
                              tooltip: 'Set Reminder',
                            ),
                            // Button for viewing plant details
                            IconButton(
                              onPressed: () {
                                final userEmail = FirebaseAuth.instance.currentUser?.email;
                                if (userEmail != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlantDetailsPage(
                                        plantId: plantId,
                                        userEmail: userEmail,
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.info_outline, color: Colors.blue),
                              tooltip: 'View Details',
                            ),
                            // Button for soil moisture monitoring
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SoilMoisturePage(selectedPlantName: plantName,),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.water_drop_outlined, color: Colors.teal),
                              tooltip: 'Moisture Monitoring',
                            ),
                          ],
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
