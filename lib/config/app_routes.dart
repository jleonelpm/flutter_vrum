import 'package:flutter/material.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/auth/initial_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
    '/initial': (context) => const InitialScreen(),
    '/home': (context) => const HomeScreen(),
  };
}
