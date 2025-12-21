import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
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
  }
}
