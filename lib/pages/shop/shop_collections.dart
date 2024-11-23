import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/components/bottom_navigation.dart';
import 'shop.dart'; 

class ShopCollections extends StatelessWidget {
  const ShopCollections({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Collections'),
        backgroundColor: const Color.fromARGB(255, 105, 173, 108),
        centerTitle: true,
        elevation: 4,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('shops').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No plant shops available'));
          }

          // Create a list of plant shops
          final plantShops = snapshot.data!.docs;

          return ListView.builder(
            itemCount: plantShops.length,
            itemBuilder: (context, index) {
              final shop = plantShops[index];

              // Handle the new fields
              String shopName = shop['name'] ?? 'Unknown Shop';
              String shopAddress = shop['address'] ?? 'No address provided';
              String shopContact = shop['contact'] ?? 'No contact information';
              String shopPlantTypes = shop['plant_types'] ?? 'No plant types specified';
              List<dynamic> imageUrls = shop['image_urls'] ?? [];
              String shopImageUrl = imageUrls.isNotEmpty ? imageUrls[0] : '';

              // Set a default image if none is provided
              Widget shopImage = shopImageUrl.isNotEmpty
                  ? Image.network(shopImageUrl, width: 100, height: 100, fit: BoxFit.cover)
                  : const Icon(Icons.image, color: Colors.grey);

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: shopImage,
                  ),
                  title: Text(
                    shopName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shopAddress, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(shopContact, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(shopPlantTypes, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Colors.green),
                    onPressed: () {
                      // Navigate to ShopDetailsScreen when clicked
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShopDetailsScreen(shop: shop),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavigationBar(selectedIndex: 1),
    );
  }
}
