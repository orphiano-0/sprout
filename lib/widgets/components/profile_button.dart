import 'package:flutter/material.dart';

class ProfileButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const ProfileButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = Colors.green, // Default color matching the app theme
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Full width
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: color,
          elevation: 2,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
