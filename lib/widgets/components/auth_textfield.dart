import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {

    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Color.fromARGB(255, 36, 36, 36), // Sets the text color to black
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.tertiary),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      ),
      obscureText: obscureText,
    );
  }
}
