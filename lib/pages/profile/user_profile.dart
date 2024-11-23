import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sprout/authentication/auth/auth.dart';
import 'package:sprout/pages/plant_collection/plant_collection.dart';
import 'package:sprout/widgets/components/bottom_navigation.dart';
import 'package:sprout/widgets/components/profile_textfield.dart';
import 'package:sprout/widgets/components/profile_button.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  String profileImageUrl = '';
  File? _image;
  bool isEditing = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        usernameController.text = userDoc['username'] ?? '';
        emailController.text = user.email ?? '';
        bioController.text = userDoc['bio'] ?? '';

        setState(() {
          profileImageUrl = userDoc['profileImageUrl'] ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'username': usernameController.text,
        'bio': bioController.text,
        'profileImageUrl': profileImageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        isEditing = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        profileImageUrl = _image!.path;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        profileImageUrl = _image!.path;
      });
    }
  }


  void logout() async {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthPage()),
      (route) => false,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color.fromARGB(255, 105, 173, 108),
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _saveChanges();
              } else {
                setState(() {
                  isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: isEditing ? () => _showImagePickerOptions(context) : null,
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? AssetImage(profileImageUrl)
                      : const AssetImage('assets/sprout_leaf.png'),
                  child: isEditing
                      ? const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),

            ProfileTextField(
              hintText: 'Username',
              obscureText: false,
              controller: usernameController,
              enabled: isEditing,
            ),
            const SizedBox(height: 20),

            ProfileTextField(
              hintText: 'Email',
              obscureText: false,
              controller: emailController,
              enabled: false,
            ),
            const SizedBox(height: 20),

            ProfileTextField(
              hintText: 'Bio',
              obscureText: false,
              controller: bioController,
              enabled: isEditing,
              maxLines: 5,
            ),
            const SizedBox(height: 40),

            ProfileButton(
              text: 'My Plants',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PlantCollection()),);
              },
            ),
            const SizedBox(height: 20),

            ProfileButton(
              text: 'Logout',
              color: Colors.grey,
              onPressed: logout
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(selectedIndex: 4),
    );
  }

  void _showImagePickerOptions(BuildContext context) {
  // Predefined list of image names available in the system
    final List<String> availableImages = [
      'user_icon_boysprout.png',
      'user_icon_flowerboy.png',
      'user_icon_flowerhead.png',
      'user_icon_flowersgirl.png',
      'user_icon_headflower.png',
      'user_icon_manflowers.png',
      'user_icon_manfairy.png',
      'user_icon_roseman.png',
      'user_icon_girlglasses.png',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select a Profile Picture',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                // GridView for displaying images
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Number of columns
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: availableImages.length,
                  itemBuilder: (context, index) {
                    final imageName = availableImages[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          profileImageUrl = 'assets/profile/$imageName'; // Save asset path
                        });
                        Navigator.pop(context); // Close the dialog
                      },
                        child: Image.asset(
                          'assets/profile/$imageName',
                          fit: BoxFit.cover,
                        ),
                    );
                  },
                ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
