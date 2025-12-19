import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/splash_screen.dart';
import 'screens/initial_screen.dart';
import 'screens/home_screen.dart';
// If you have FlutterFire configured, uncomment the next line
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with dummy options suitable for Emulator-only usage.
  final String appId = (!kIsWeb && Platform.isAndroid)
      ? '1:1234567890:android:demo-vrum-app'
      : '1:1234567890:ios:demo-vrum-app';
  const String apiKey = 'fake-api-key';
  const String projectId = 'demo-vrum';
  const String messagingSenderId = '1234567890';

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      projectId: projectId,
      messagingSenderId: messagingSenderId,
    ),
  );

  // Point SDKs to local emulators when available.
  const useEmulators = bool.fromEnvironment(
    'USE_EMULATORS',
    defaultValue: true,
  );
  if (useEmulators) {
    final host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
    // Auth Emulator
    FirebaseAuth.instance.useAuthEmulator(host, 9099);
    // Firestore Emulator
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8084);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter VRUM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/initial': (context) => const InitialScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
