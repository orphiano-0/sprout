import 'package:flutter/material.dart';
import 'package:sprout/pages/plant_collection/plant_collection.dart';
import 'package:sprout/pages/plant_health/health_identifier.dart';
import 'package:sprout/pages/plant_identification/plant_identifier.dart';
import 'package:sprout/pages/sensors/light_sensor.dart';

import '../widgets/components/bottom_navigation.dart';

class SproutHome extends StatelessWidget {
  const SproutHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Aligns content to the left.
          children: [
            Image.asset(
              'assets/sprout_image.png',
              height: 40, // Adjust to your desired size.
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 105, 173, 108)
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _buildFullWidthCard('Plant Identifier', 'assets/dashboard/img_plant_identifier.jpg', PlantIdentifierScreen(), context),
          ),
          Expanded(
            child: _buildFullWidthCard('Health Identifier', 'assets/dashboard/img_soil_moisture.jpg', PlantHealthIdentifier(), context),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildGridCard('Plant Care', 'assets/dashboard/img_reminder.jpg', const PlantCollection(), context),
                ),
                Expanded(
                  child: _buildGridCard('Light Meter', 'assets/dashboard/img_light_meter.jpg', const LightSensorWidget(), context),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigationBar(selectedIndex: 2),
    );
  }

  Widget _buildFullWidthCard(String title, String imagePath, Widget destination, BuildContext context) {
  return InkWell(
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
    },
    child: Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(19),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(0, 176, 209, 115),
                  Color.fromARGB(255, 99, 135, 35), // Green color
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 0, 0, 0)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildGridCard(String title, String imagePath, Widget destination, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(19),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Image.asset(imagePath, fit: BoxFit.cover),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(0, 176, 209, 115),
                    Color.fromARGB(255, 85, 120, 26), // Green color
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 0, 0, 0)),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
