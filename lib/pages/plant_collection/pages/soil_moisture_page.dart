import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SoilMoisturePage extends StatefulWidget {
  final String selectedPlantName;

  const SoilMoisturePage({Key? key, required this.selectedPlantName})
      : super(key: key);

  @override
  State<SoilMoisturePage> createState() => _SoilMoisturePageState();
}

class _SoilMoisturePageState extends State<SoilMoisturePage> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref("Moisture_Monitoring");
  final String? email = FirebaseAuth.instance.currentUser?.email;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  double soilMoistureLevel = 0;
  String type = "No data available";
  String description = "No data available";
  String plantName = "No data available";
  bool isLoading = true;

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _initializeLocalNotifications();
    _fetchMoistureData();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  void _initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    _localNotificationsPlugin.initialize(initializationSettings);
  }

  void _fetchMoistureData() {
    _databaseReference.orderByChild("email").equalTo(email).onValue.listen((event) {
      if (event.snapshot.value != null) {
        final dataMap = Map<String, dynamic>.from(event.snapshot.value as Map);

        bool dataFound = false;

        dataMap.forEach((key, value) {
          // Check if both email and plant name match
          if (value['plant_name'] == widget.selectedPlantName && value['email'] == email) {
            setState(() {
              soilMoistureLevel = double.parse(value['moisture_value'].toString());
              description = value['description'] ?? "No type available";
              type = value['type'] ?? "No type available";
              plantName = value['plant_name'] ?? "Unknown Plant";

              isLoading = false;

              // Notify only if soil moisture is <= 20
              if (soilMoistureLevel <= 20) {
                _sendLocalNotification();
              }
            });
            dataFound = true;
          }
        });

        if (!dataFound) {
          setState(() {
            soilMoistureLevel = 0;
            type = "No type available";
            description = "No data available";
            plantName = "No data available";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          type = "No type available";
          description = "No data available";
          plantName = "No data available";
          soilMoistureLevel = 0;
          isLoading = false;
        });
      }
    });
  }


  Future<void> _sendLocalNotification() async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'soil_moisture_channel',
      'Soil Moisture Alerts',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    
    await flutterLocalNotificationsPlugin.show(
      0,
      'Soil Moisture Alert! 🌱💦',
      'The soil moisture level of $plantName is very low! Please water your plant 💦',
      notificationDetails,
    );
  }

  Color _getMoistureColor(double moisture) {
    if (moisture < 20) {
      return Colors.red.shade500;
    } else if (moisture < 40) {
      return Colors.orange.shade500;
    } else if (moisture < 60) {
      return Colors.yellow.shade500;
    } else if (moisture < 80) {
      return Colors.lightGreen.shade500;
    } else {
      return Colors.green.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soil Moisture'),
        backgroundColor: const Color.fromARGB(255, 105, 173, 108),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMoistureIndicator(),
                        const SizedBox(height: 30),
                        _buildDescriptionCard(),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoistureIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getMoistureColor(soilMoistureLevel).withOpacity(0.5),
                  spreadRadius: 10,
                  blurRadius: 15,
                ),
              ],
            ),
            child: CircularProgressIndicator(
              value: soilMoistureLevel / 100,
              strokeWidth: 16,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getMoistureColor(soilMoistureLevel),
              ),
            ),
          ),
          Text(
            '${soilMoistureLevel.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              plantName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              "Type: $type",
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
