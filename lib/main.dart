// ignore_for_file: unnecessary_null_comparison, avoid_print, no_leading_underscores_for_local_identifiers, unrelated_type_equality_checks, non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'package:crisis_survivor/Consultant/BasicInfo.dart';
import 'package:crisis_survivor/Screens/splash_signup.dart';
import 'package:crisis_survivor/Screens/Splash_Screen.dart';
import 'package:crisis_survivor/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Widget screen = const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );

  Future<void> _checkPermissionsAndPrefs() async {
    try {
      SharedPreferences _pref = await SharedPreferences.getInstance();
      String? dataString = _pref.getString('Data');

      if (dataString != null && dataString.isNotEmpty) {
        Map<String, dynamic> cache = json.decode(dataString);
        log("Cached Data: $cache");

        final currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          final response = await http.post(
            Uri.parse(
              "https://authbackend-production-d43e.up.railway.app/api/receive-data/",
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({"uid": currentUser.uid}),
          );

          if (response.statusCode == 200) {
            final decoded = json.decode(response.body);
            if (decoded['data'] != null) {
              log("✅ Navigation: Splash_Screen()");
              screen = const ConsultantBasicInfo(); //Splash_Screen();
              return;
            }
          }
        }

        log("❌ Invalid or expired user. Clearing prefs.");
        await _pref.clear();
      } else {
        log("📭 No cached data found.");
      }

      screen = const SplashSignUp();
    } catch (e) {
      log("⚠️ Error during user validation: $e");
      screen = const SplashSignUp();
    }
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkPermissionsAndPrefs();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crisis Survivor',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: screen,
      color: Colors.black,
    );
  }
}
