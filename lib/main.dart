// ignore_for_file: unnecessary_null_comparison, avoid_print, no_leading_underscores_for_local_identifiers, unrelated_type_equality_checks, non_constant_identifier_names, unused_import

import 'dart:convert';
import 'dart:developer';
import 'package:crisis_survivor/Consultant/BasicInfo.dart';
import 'package:crisis_survivor/Donor/BasicInfo.dart';
import 'package:crisis_survivor/Screens/Roles.dart';
import 'package:crisis_survivor/Screens/splash_signup.dart';
import 'package:crisis_survivor/Screens/Splash_Screen.dart';
import 'package:crisis_survivor/Victim/BasicInfo.dart';
import 'package:crisis_survivor/Victim/request.dart';
import 'package:crisis_survivor/Victim/victimScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:crisis_survivor/firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';
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
  late Widget Screen;

  Future<void> _checkPermissionsAndPrefs() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    String? dataString = _pref.getString('Data');
    if (dataString != null && dataString.isNotEmpty) {
      try {
        Map<String, dynamic> cache = json.decode(dataString);
        log("Cached Data: $cache");

        // ✅ Call Django API using UID to verify user
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
              log("Navigation = true");
              Screen = Splash_Screen(); // Navigate to splash screen
              return;
            }
          }
        }

        log("Navigation = false");
        Screen = SplashSignUp();
        await _pref.clear();
      } catch (e) {
        log("Error during user validation: $e");
        Screen = Splash_Screen(); // fallback screen on error
      }
    } else {
      log("No cached data found.");
      Screen = victimScreen();
      //SplashSignUp(); // fallback if no cache
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crisis Survivor',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<void>(
        future: _checkPermissionsAndPrefs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: AssetImage('assets/splash.png'),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text(
                  'Error requesting permissions: Permission Required!',
                ),
              ),
            );
          } else {
            return Scaffold(body: Screen);
          }
        },
      ),
      color: Colors.black, //const Color(0xFFF2EDF6),
    );
  }
}
