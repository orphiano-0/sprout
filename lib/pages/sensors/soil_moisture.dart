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

  // Hardcoded email for simulation

  // use email logged in email here:
  final String email = "Gab@gmail.com";

  double soilMoistureLevel = 0;
  String description = "";
  List<String> wateringTips = [];
  List<String> recommendedPlants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMoistureData();
  }

  void _fetchMoistureData() {
    _databaseReference
        .orderByChild("email")//fetch data using child named "email"
        .equalTo(email)
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        final dataMap = Map<String, dynamic>.from(event.snapshot.value as Map);
        final data = dataMap.values.first;

        setState(() {
          soilMoistureLevel = double.parse(data['moisture_value'].toString());
          description = data['type'];
          wateringTips = List<String>.from(data['watering_tips']);
          recommendedPlants = List<String>.from(data['recommended_plants']);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          description = "No data available for this user.";
          wateringTips = [];
          recommendedPlants = [];
          soilMoistureLevel = 0;
        });
      }
    });
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
      title: const Text('Soil Moisture'),
        backgroundColor: const Color.fromARGB(255, 105, 173, 108),
        centerTitle: true,
        elevation: 4,
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.white),
          onPressed: _showInstructionsDialog,
        ),
      ],
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  child: Column(
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
                  ),
                ),
                const SizedBox(height: 20),
                _buildPlantAndWateringInfoCard(soilMoistureLevel),
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


  Widget _buildPlantAndWateringInfoCard(double soilMoistureLevel) {
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
              const SizedBox(height: 10),
              const Text(
                "Watering Tips:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              for (var tip in wateringTips)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• ", style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text(
                          tip,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              const Text(
                "Recommended Plants:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              for (var plant in recommendedPlants)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• ", style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text(
                          plant,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMoistureColor(double moistureLevel) {
    if (moistureLevel <= 20) {
      return Colors.redAccent;
    } else if (moistureLevel <= 40) {
      return Colors.orangeAccent;
    } else if (moistureLevel <= 60) {
      return Colors.yellowAccent;
    } else if (moistureLevel <= 80) {
      return Colors.lightGreenAccent;
    } else {
      return Colors.green;
    }
  }

  String _getMoistureDescription(double moistureLevel) {
    if (moistureLevel <= 20) {
      return '🌵 Very Dry';
    } else if (moistureLevel <= 40) {
      return '💧 Dry';
    } else if (moistureLevel <= 60) {
      return '🌱 Optimal';
    } else if (moistureLevel <= 80) {
      return '💦 Moist';
    } else {
      return '🌊 Very Wet';
    }
  }
}
