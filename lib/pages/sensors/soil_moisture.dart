import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sprout/widgets/components/bottom_navigation.dart';

class SoilMoisturePage extends StatefulWidget {
  const SoilMoisturePage({super.key});

  @override
  State<SoilMoisturePage> createState() => _SoilMoisturePageState();
}

class _SoilMoisturePageState extends State<SoilMoisturePage> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref("Moisture_Monitoring");
  String? email = FirebaseAuth.instance.currentUser?.email;

  double soilMoistureLevel = 0;
  List<String> description = [];
  List<String> wateringTips = [];
  String plants = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMoistureData();
  }

  void _fetchMoistureData() {
    _databaseReference.orderByChild("email").equalTo(email).onValue.listen((event) {
      if (event.snapshot.value != null) {
        final dataMap = Map<String, dynamic>.from(event.snapshot.value as Map);
        final data = dataMap.values.first;

        setState(() {
          soilMoistureLevel = double.parse(data['moisture_value'].toString());
          description = List<String>.from(data['description'] ?? []);
          wateringTips = List<String>.from(data['tips'] ?? []);
          plants = data['plant_name'] ?? "No plant name available";
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          description = ["No description available for this user."];
          wateringTips = ["No tips available for this user."];
          plants = "No plant name available";
          soilMoistureLevel = 0;
        });
      }
    });
  }

  Future<void> _resetSoilMoisture() async {
    try {
      await _databaseReference.orderByChild("email").equalTo(email).once().then((snapshot) {
        final dataMap = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        if (dataMap.isNotEmpty) {
          final userKey = dataMap.keys.first;

          _databaseReference.child(userKey).update({
            'moisture_value': 0,
            'description': [],
            'tips': [],
          }).then((_) {
            setState(() {
              soilMoistureLevel = 0;
              description = ["No description available."];
              wateringTips = [];
              plants = "";
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Soil moisture reset successfully')),
            );
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error resetting soil moisture: $error')),
            );
          });
        }
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  void _showInstructionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("How to Use the Sensor"),
          content: const Text(
            "1. Turn on the sensor\n\n"
            "2. Access the sensor via WIFI with the name 'Sprout_IOT_Setup'\n\n"
            "3. Go to your browser and type 192.168.4.1 to access IoT website.\n\n"
            "4. Enter the needed information, THE USERNAME MUST MATCH WITH THE USERNAME OF YOUR ACCOUNT.\n\n"
            "5. Put the IoT sensor in the plant for monitoring and then wait for analysis",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soil Moisture: Reader'),
        backgroundColor: const Color.fromARGB(255, 105, 173, 108),
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showInstructionsDialog,
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _resetSoilMoisture,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.green.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMoistureDisplay(),
                  const SizedBox(height: 20),
                  _buildPlantAndWateringInfoCard(),
                  if (isLoading) const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(selectedIndex: 0),
    );
  }

  Widget _buildMoistureDisplay() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    spreadRadius: 6,
                    blurRadius: 10,
                  ),
                ],
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                value: soilMoistureLevel / 100,
                strokeWidth: 16,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getMoistureColor(soilMoistureLevel),
                ),
              ),
            ),
            Text(
              '${soilMoistureLevel.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          _getMoistureDescription(soilMoistureLevel),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPlantAndWateringInfoCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        shadowColor: Colors.green.shade400,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Plant and Watering Info",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const Divider(color: Colors.green),
              // const SizedBox(height: 10),
              // Text(
              //   "Plant Name: $plants",
              //   style: const TextStyle(
              //     fontSize: 16,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              const SizedBox(height: 10),
              const Text(
                "Description:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              ...description.map((desc) => Text(
                    "• $desc",
                    style: const TextStyle(fontSize: 16),
                  )),
              const SizedBox(height: 20),
              const Text(
                "Tips:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              ...wateringTips.map((tip) => Text(
                    "• $tip",
                    style: const TextStyle(fontSize: 16),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  String _getMoistureDescription(double moisture) {
    if (moisture <= 20) {
      return 'Very Dry Soil';
    } else if (moisture <= 40) {
      return 'Moderately Dry Soil';
    } else if (moisture <= 60) {
      return 'Moist Soil';
    } else if (moisture <= 80) {
      return 'Wet Soil';
    } else {
      return 'Waterlogged Soil';
    }
  }

  Color _getMoistureColor(double moisture) {
    if (moisture <= 20) {
      return Colors.red.shade300;
    } else if (moisture <= 40) {
      return Colors.orange.shade300;
    } else if (moisture <= 60) {
      return Colors.yellow.shade300;
    } else if (moisture <= 80) {
      return Colors.lightGreen.shade300;
    } else {
      return Colors.green.shade700;
    }
  }
}
