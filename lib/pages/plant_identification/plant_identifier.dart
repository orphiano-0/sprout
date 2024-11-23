import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For authentication
import 'package:sprout/pages/plant_identification/api_service.dart';
import 'package:sprout/pages/plant_identification/plant_data.dart';
import 'package:sprout/widgets/components/corner_outline.dart';
import 'package:sprout/widgets/components/plant_not_identified.dart';

class PlantIdentifierScreen extends StatefulWidget {
  @override
  _PlantIdentifierScreenState createState() => _PlantIdentifierScreenState();
}

class _PlantIdentifierScreenState extends State<PlantIdentifierScreen> {
  final PlantIDService plantIDService = PlantIDService();
  File? _selectedImage;
  bool _isLoading = false;
  CameraController? _cameraController;
  Future<void>? _initializeCameraFuture;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _fetchUserEmail();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras.first, ResolutionPreset.high);
    _initializeCameraFuture = _cameraController!.initialize();
    setState(() {});
  }

  Future<void> _fetchUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      userEmail = user?.email; // Fetch the current user's email
    });
  }

  Future<void> _captureAndIdentify() async {
    try {
      await _initializeCameraFuture;
      final image = await _cameraController!.takePicture();
      setState(() {
        _selectedImage = File(image.path);
      });
      _identifyPlant();
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
      _identifyPlant();
    }
  }

  Future<void> _identifyPlant() async {
    if (_selectedImage == null || userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User email or image is missing.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await plantIDService.identifyPlant(_selectedImage!);

    setState(() {
      _isLoading = false;
    });

    if (result != null && result['result'] != null) {
      final classification = result['result']['classification'];
      final isPlantProbability = result['result']['is_plant']['probability'] ?? 0;

      if (isPlantProbability < 0.5) {
        _showNotIdentifiedDialog();
        return;
      }

      if (classification != null && classification['suggestions'] != null && classification['suggestions'].isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDataDisplay(
              suggestion: classification['suggestions'][0],
              selectedImage: _selectedImage!,
              userEmail: userEmail!, // Pass userEmail here
            ),
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
        return PlantNotIdentifiedDialog(
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
