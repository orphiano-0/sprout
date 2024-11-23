import 'package:flutter/material.dart';

class PlantNotIdentifiedDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  PlantNotIdentifiedDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text(
        'Plant Not Identified',
        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'We couldn\'t identify the plant. Please try again with a clearer image or check your network connection.',
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
