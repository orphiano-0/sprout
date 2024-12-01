import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:light_sensor/light_sensor.dart';
import 'lux_levels_plantcare.dart';
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
    final luxInfo = luxData['lux_levels'].firstWhere(
      (data) => data['range'] == luxCategory,
      orElse: () => null,
    );

    if (luxInfo == null) return const SizedBox.shrink();

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
              Text(
                "Lux Range: ${luxInfo['range']}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 10),
              Text(
                luxInfo['description'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text("Care Tips:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              for (var tip in luxInfo['tips'])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Text("• ", style: TextStyle(fontSize: 16)),
                      Expanded(child: Text(tip, style: const TextStyle(fontSize: 16))),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              const Text("Suitable Plants:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              for (var plant in luxInfo['suitable_plants'])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Text("• ", style: TextStyle(fontSize: 16)),
                      Expanded(child: Text(plant, style: const TextStyle(fontSize: 16))),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLuxCategory(int lux) {
    if (lux <= 50) return '0-50';
    if (lux <= 200) return '50-200';
    if (lux <= 500) return '200-500';
    if (lux <= 1000) return '500-1000';
    if (lux <= 10000) return '1000-10000';
    if (lux <= 100000) return '10000-100000';
    return '100000+';
  }

  Color _getLightColor(int lux) {
    if (lux <= 50) return Colors.blueGrey;
    if (lux <= 200) return Colors.green.shade700;
    if (lux <= 500) return Colors.green;
    if (lux <= 1000) return Colors.lightGreen;
    if (lux <= 10000) return Colors.yellow;
    if (lux <= 100000) return Colors.orange;
    return Colors.orange;
  }

  String _getLightDescription(int lux) {
    if (lux <= 50) return '☀️ Very Low Light';
    if (lux <= 200) return '☀️ Low Light';
    if (lux <= 500) return '☀️ Moderate Light';
    if (lux <= 1000) return '☀️ Bright Indirect Light';
    if (lux <= 10000) return '☀️ Full Sunlight';
    if (lux <= 100000) return '☀️ Full Sunlight';
    return '☀️ Extreme Sunlight';
  }
}