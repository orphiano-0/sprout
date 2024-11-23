import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/components/bottom_navigation.dart';


class ShopDetailsScreen extends StatelessWidget {
  final DocumentSnapshot shop;

  const ShopDetailsScreen({Key? key, required this.shop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract the full details from the shop document
    String shopName = shop['name'] ?? 'Unknown Shop';
    String shopAddress = shop['address'] ?? 'No address provided';
    String shopContact = shop['contact'] ?? 'No contact information';
    String shopBusinessHours = shop['business_hours'] ?? 'No business hours provided';
    String shopPlantTypes = shop['plant_types'] ?? 'No plant types specified';
    String shopSpecialtyProducts = shop['specialty_products'] ?? 'No specialty products specified';
    String shopWebsite = shop['website'] ?? 'No website provided';
    String shopDescription = shop['short_description'] ?? 'No description available';
    List<dynamic> imageUrls = shop['image_urls'] ?? [];
    String shopImageUrl = imageUrls.isNotEmpty ? imageUrls[0] : '';

    // Set a default image if none is provided
    Widget shopImage = shopImageUrl.isNotEmpty
        ? Image.network(shopImageUrl, width: 200, height: 200, fit: BoxFit.cover)
        : const Icon(Icons.image, color: Color.fromARGB(255, 227, 230, 216));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Data'),
        backgroundColor: const Color.fromARGB(255, 105, 173, 108),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Centering the shop name
              Center(
                child: Text(
                  shopName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              const Divider(color: Colors.green, thickness: 1.5),
              const SizedBox(height: 20),

              // Shop Image (Larger size)
              Center(child: shopImage),
              const SizedBox(height: 20),

              // Address Section
              _buildInfoBox(
                context,
                Icons.location_on,
                'Address: $shopAddress',
                Colors.green.shade50,
                Colors.green,
              ),
              const SizedBox(height: 12),

              // Contact Section
              _buildInfoBox(
                context,
                Icons.phone,
                'Contact: $shopContact',
                Colors.blue.shade50,
                Color.fromARGB(255, 54, 118, 66),
              ),
              const SizedBox(height: 12),

              // Business Hours Section
              _buildInfoBox(
                context,
                Icons.access_time,
                'Business Hours: $shopBusinessHours',
                Colors.orange.shade50,
                Color.fromARGB(255, 94, 112, 20),
              ),
              const SizedBox(height: 12),

              // Plant Types Section with Green Theme and Plant Icon
              _buildInfoBox(
                context,
                Icons.nature,
                'Plant Types: $shopPlantTypes',
                Colors.green.shade100,
                Colors.green,
              ),
              const SizedBox(height: 12),

              // Specialty Products Section
              _buildInfoBox(
                context,
                Icons.local_offer,
                'Specialty Products: $shopSpecialtyProducts',
                Colors.amber.shade50,
                Color.fromARGB(255, 178, 223, 151),
              ),
              const SizedBox(height: 12),

              // Website Section
              _buildInfoBox(
                context,
                Icons.web,
                'Website: $shopWebsite',
                Colors.blueGrey.shade50,
                Colors.blueGrey,
              ),
              const SizedBox(height: 12),

              // Description Section
              const Text(
                'Description:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                shopDescription,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(selectedIndex: 1),
    );
  }

  // Helper method to create consistent info boxes
  Widget _buildInfoBox(
    BuildContext context,
    IconData icon,
    String infoText,
    Color boxColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              infoText,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
