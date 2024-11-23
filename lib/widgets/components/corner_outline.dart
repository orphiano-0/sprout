import 'package:flutter/material.dart';

class CornerOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    final radius = 30.0; // Radius for the rounded corners

    // Draw top-left corner
    canvas.drawArc(
      Rect.fromCircle(center: Offset(radius, radius), radius: radius),
      3.14, // Start angle (180 degrees in radians)
      1.57, // Sweep angle (90 degrees in radians)
      false,
      paint,
    );

    // Draw top-right corner
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width - radius, radius), radius: radius),
      4.71, // Start angle (270 degrees in radians)
      1.57, // Sweep angle (90 degrees in radians)
      false,
      paint,
    );

    // Draw bottom-right corner
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width - radius, size.height - radius), radius: radius),
      0, // Start angle (0 degrees in radians)
      1.57, // Sweep angle (90 degrees in radians)
      false,
      paint,
    );

    // Draw bottom-left corner
    canvas.drawArc(
      Rect.fromCircle(center: Offset(radius, size.height - radius), radius: radius),
      1.57, // Start angle (90 degrees in radians)
      1.57, // Sweep angle (90 degrees in radians)
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
