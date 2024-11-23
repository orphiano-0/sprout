import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sprout/authentication/auth/auth.dart';
import 'package:sprout/firebase_options.dart';
import 'package:sprout/pages/splash_screen.dart';
import 'package:sprout/widgets/theme/dark_mode.dart';
import 'package:sprout/widgets/theme/light_mode.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'pages/chatbot/change_notifier.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  // Initialization settings for both platforms
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  tz.initializeTimeZones();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,

      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/authentication': (context) => const AuthPage(),
      },
    );
    
  }
}