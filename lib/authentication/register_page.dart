import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sprout/widgets/components/auth_button.dart';
import 'package:sprout/widgets/components/auth_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPsController = TextEditingController();

  void displayMessageToUser(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> saveUserData(String uid, String username, String email) async {
    // Save the user data in Firestore
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'username': username,
      'email': email,
      'profileImageUrl': null,
      'bio': null,
    });

    // Save additional user data in the Realtime Database
    // DatabaseReference dbRef = FirebaseDatabase.instance.ref("Moisture_Monitoring/$uid");
    // await dbRef.set({
    //   'email': email,
    //   'moisture_value': 0, // Default value
    //   'recommended_plants': ["No Data Available"], // Empty list initially
    //   'type': '', // Default type
    //   'watering_tips': ["No Data Available"], // Empty list initially
    // });
  }

  void registerUser() async {
    // Check if passwords match
    if (passwordController.text != confirmPsController.text) {
      displayMessageToUser("Passwords don't match!", context);
      return;
    }

    try {
      // Attempt to register the user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Store username and email in Firestore and Realtime Database
      await saveUserData(
        userCredential.user!.uid, // Firebase UID
        usernameController.text.trim(),
        emailController.text.trim(),
      );

      // Navigate to the homepage upon successful registration
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home'); // Replace '/home' with your actual homepage route
      }

      // Show success message
      displayMessageToUser("Registration Successful!", context);
    } on FirebaseAuthException catch (e) {
      // Display error message
      displayMessageToUser(e.message ?? "An error occurred", context);
    } catch (e) {
      // Display unexpected error message
      displayMessageToUser("An unexpected error occurred", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Sprout Logo
              Image.asset(
                "assets/sprout_widget.png",
                height: 150,
              ),
              const SizedBox(height: 30),

              // Heading Text
              Text(
                "Create Account",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Input Field Username
              MyTextField(
                hintText: "Username",
                obscureText: false,
                controller: usernameController,
              ),
              const SizedBox(height: 15),

              // Input Field Email
              MyTextField(
                hintText: "Email",
                obscureText: false,
                controller: emailController,
              ),
              const SizedBox(height: 15),

              // Input Field Password
              MyTextField(
                hintText: "Password",
                obscureText: true,
                controller: passwordController,
              ),
              const SizedBox(height: 15),

              // Confirm Password Field
              MyTextField(
                hintText: "Confirm Password",
                obscureText: true,
                controller: confirmPsController,
              ),
              const SizedBox(height: 30),

              // Register Button
              MyButton(
                text: "Register",
                onTap: registerUser,
              ),
              const SizedBox(height: 30),

              // Already have an account? Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      "  Login Here",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
