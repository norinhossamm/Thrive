import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'WelcomeScreen.dart';
import 'YieldandPriceDataEntryScreen.dart';
import 'SignupScreen.dart';
import 'UserSelection.dart';
import 'splash_screen.dart';
import 'crop_health.dart';

import 'homescreendataentry.dart';
import 'Ripeness_level_detection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug, // Use debug provider for development, use playIntegrity or safetyNet for production
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SelectedFarm()),
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
      home: UploadAndTake2(),
    );
  }
}
