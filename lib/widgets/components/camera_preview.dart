import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController cameraController;
  final Future<void> initializeCameraFuture;

  CameraPreviewWidget({
    required this.cameraController,
    required this.initializeCameraFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: initializeCameraFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SizedBox.expand(
            child: CameraPreview(cameraController),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
