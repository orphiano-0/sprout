import 'package:flutter/material.dart';

class ProfileTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final bool enabled; // Added this to control whether the field is editable
  final int maxLines; // Added this to control the number of lines

  const ProfileTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    required this.enabled, // Passing enabled parameter to control editability
    this.maxLines = 1, // Default to 1 line
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled, // Enables or disables the text field based on the edit mode
      maxLines: maxLines, // Control the number of lines in the text field
      style: const TextStyle(
        color: Color.fromARGB(255, 36, 36, 36), // Sets the text color to black
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), // Rounded corners
          borderSide: BorderSide.none,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
          fontSize: 16, // Slightly bigger text for better readability
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        labelText: hintText, // Floating label
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 16,
        ),
      ),
    );
  }
}
