import 'package:flutter/material.dart';

class PlantHealthDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  PlantHealthDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text(
        'No Disease Detected',
        style: TextStyle(color: Color.fromARGB(255, 30, 202, 55), fontWeight: FontWeight.bold),
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'We couldn\'t identify the disease of your plant. There\'s seems no problem with your plant.',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Icon(Icons.local_florist, size: 50, color: Colors.green),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
        ),
      ],
    );
  }
}
