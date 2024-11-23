import 'package:flutter/material.dart';
import 'package:sprout/pages/plant_collection/reminder_plan.dart';

class PlantReminder extends StatelessWidget {
  final String plantId;
  final String collectionId;
  final String plantName;

  const PlantReminder({
    required this.plantId,
    required this.collectionId,
    required this.plantName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Reminder'),
        backgroundColor: const Color.fromARGB(255, 105, 173, 108),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ReminderPlanWidget(
          plantId: plantId,
          collectionId: collectionId,
          plantName: plantName,
        ),
      ),
    );
  }
}
