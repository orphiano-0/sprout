import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:light_sensor/light_sensor.dart';
import 'lux_data.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; 

class LightSensorWidget extends StatefulWidget {
  const LightSensorWidget({Key? key}) : super(key: key);

  @override
  State<LightSensorWidget> createState() => _LightSensorWidgetState();
}

class _LightSensorWidgetState extends State<LightSensorWidget> {
  int? luxValue;
  final Map<String, dynamic> luxData = jsonDecode(luxDataJson);

  @override
  void initState() {
    super.initState();
    _initLightSensor();
  }

  Future<void> _initLightSensor() async {
    final bool hasSensor = await LightSensor.hasSensor();
    if (hasSensor) {
      LightSensor.luxStream().listen((value) {
        setState(() {
          luxValue = value;
        });
      });
    } else {
        setState(() {
        luxValue = -1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This device does not have a light sensor.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Light Sensor'),
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
                  if (luxValue != null)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeInOut,
                      child: Column(
                        children: [
                          // Circular progress indicator to display lux value visually
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
                                  value: (luxValue! / 100000).clamp(0.0, 1.0),
                                  strokeWidth: 16,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(_getLightColor(luxValue!)),
                                ),
                              ),
                              Text(
                                '$luxValue Lux',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _getLightDescription(luxValue!),
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
                  if (luxValue != null)
                    _buildPlantAndLightInfoCard(luxValue!),
                  if (luxValue == null)
                    const SpinKitCircle(
                      color: Colors.green,
                      size: 50.0,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlantAndLightInfoCard(int luxValue) {
    final luxCategory = _getLuxCategory(luxValue);
    final plantData = luxData['lux_data'].firstWhere(
      (data) => data['lux_range'] == luxCategory,
      orElse: () => null,
    );

    if (plantData == null) return const SizedBox.shrink();

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
                "Plant and Light Info 🌱",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const Divider(color: Colors.green),
              const SizedBox(height: 10),
              // Displaying recommended plants
              const Text(
                "Recommended Plants:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              for (var plant in plantData['plants'])
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
              const SizedBox(height: 20),
              // Displaying description and benefits
              const Text(
                "Description:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                plantData['description'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "Benefits:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                plantData['benefits'],
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLuxCategory(int lux) {
    if (lux <= 500) {
      return '0-500';
    } else if (lux <= 2000) {
      return '501-2000';
    } else if (lux <= 10000) {
      return '2001-10000';
    } else if (lux <= 20000) {
      return '10001-20000';
    } else if (lux <= 50000) {
      return '20001-50000';
    } else if (lux <= 100000) {
      return '50001-100000';
    } else {
      return '100000+';
    }
  }

  Color _getLightColor(int lux) {
    if (lux <= 500) {
      return Colors.blueGrey;
    } else if (lux <= 2000) {
      return Colors.green.shade700;
    } else if (lux <= 10000) {
      return Colors.green;
    } else if (lux <= 20000) {
      return Colors.lightGreen;
    } else if (lux <= 50000) {
      return Colors.yellow;
    } else if (lux <= 100000) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getLightDescription(int lux) {
    if (lux <= 500) {
      return '☀️ Low Light';
    } else if (lux <= 2000) {
      return '☀️ Medium/Indirect Light';
    } else if (lux <= 10000) {
      return '☀️ Bright Indirect Light';
    } else if (lux <= 20000) {
      return '☀️ Partial Sun/Filtered Sunlight';
    } else if (lux <= 50000) {
      return '☀️ Full Sun';
    } else if (lux <= 100000) {
      return '☀️ High-Intensity Direct Sunlight';
    } else {
      return '☀️ Extremely High Light';
    }
  }
}