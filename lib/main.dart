import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nutriscan/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  bool hasCompletedOnboarding = await _checkOnboardingStatus();
  Widget initialScreen = hasCompletedOnboarding
      ? ScreenHandler()
      : OnboardingScreen1();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return initialScreen; // Authenticated user
          }
          return OnboardingScreen1();
        },
      ),
    ),
  );
}

Future<bool> _checkOnboardingStatus() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboardingCompleted') ?? false;
}