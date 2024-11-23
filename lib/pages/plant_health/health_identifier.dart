import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sprout/pages/plant_health/health_api.dart';
import 'package:sprout/pages/plant_health/plant_health.dart';
import 'package:sprout/widgets/components/corner_outline.dart';
import 'package:sprout/widgets/components/health_not_identified.dart';

class PlantHealthIdentifier extends StatefulWidget {
  @override
  _PlantHealthIdentifierState createState() => _PlantHealthIdentifierState();
}

class _PlantHealthIdentifierState extends State<PlantHealthIdentifier> {
  final plantHealthService plantHealth = plantHealthService();
  File? _selectedImage;
  bool _isLoading = false;
  CameraController? _cameraController;
  Future<void>? _initializeCameraFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras.first, ResolutionPreset.high);
    _initializeCameraFuture = _cameraController!.initialize();
    setState(() {});
  }

  Future<void> _captureAndIdentify() async {
    try {
      await _initializeCameraFuture;
      final image = await _cameraController!.takePicture();
      setState(() {
        _selectedImage = File(image.path);
      });
      _identifyDisease();
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      _identifyDisease();
    }
  }

  Future<void> _identifyDisease() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    final result = await plantHealth.plantHealth(_selectedImage!);

    setState(() {
      _isLoading = false;
    });

    if (result != null && result['result'] != null) {
      final disease = result['result']['disease'];
      final isHealthy = result['result']['is_healthy']['probability'] ?? 0;

      if (isHealthy < 0.1) {
        _showNotIdentifiedDialog();
        return;
      }

      if (disease != null && disease['suggestions'] != null && disease['suggestions'].isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantHealthDisplay(
              suggestion: disease['suggestions'][0],
              selectedImage: _selectedImage!),
          ),
        ).then((_) {
          setState(() {
            _selectedImage = null;
          });
        });
      } else {
        _showNotIdentifiedDialog();
      }
    } else {
      _showNotIdentifiedDialog();
    }
  }

  void _showNotIdentifiedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PlantHealthDialog(
          onConfirm: () {
            setState(() {
              _selectedImage = null;
            });
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 17, 19, 17),
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeCameraFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox.expand(
                  child: CameraPreview(_cameraController!),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          // Overlay the CornerOutlinePainter above the camera preview
          Center(
            child: CustomPaint(
              size: Size(260, 260), // Adjust the size as needed
              painter: CornerOutlinePainter(),
            ),
          ),
          if (_selectedImage != null)
            Center(
              child: ClipRect(
                child: Align(
                  alignment: Alignment.center,
                  widthFactor: 240 / 250,
                  heightFactor: 240 / 250,
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          if (_isLoading)
            Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _captureAndIdentify,
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.health_and_safety,
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
                    onPressed: _pickImageFromGallery,
                    tooltip: 'Upload from Gallery',
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 60,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
