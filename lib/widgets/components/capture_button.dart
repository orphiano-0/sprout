import 'package:flutter/material.dart';

class BottomActionButtons extends StatelessWidget {
  final VoidCallback onCapturePressed;
  final VoidCallback onGalleryPressed;

  BottomActionButtons({
    required this.onCapturePressed,
    required this.onGalleryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Column(
        children: [
          FloatingActionButton(
            onPressed: onCapturePressed,
            backgroundColor: Colors.white,
            child: const Icon(
              Icons.camera_alt,
              size: 35,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Capture',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(
                Icons.image,
                size: 40,
                color: Colors.white,
              ),
              onPressed: onGalleryPressed,
              tooltip: 'Upload from Gallery',
            ),
          ),
        ],
      ),
    );
  }
}
