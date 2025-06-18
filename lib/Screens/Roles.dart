// ignore_for_file: file_names, no_leading_underscores_for_local_identifiers, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:crisis_survivor/Screens/roleBasedNavigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class Roles extends StatefulWidget {
  const Roles({super.key});

  @override
  State<Roles> createState() => _RolesState();
}

class _RolesState extends State<Roles> {
  Future<void> updateUserRoleInCache(String? newRole) async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Step 1: Get latest user data from API
      final response = await http.post(
        Uri.parse(
          "https://authbackend-production-d43e.up.railway.app/api/receive-data/",
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"uid": currentUser.uid}),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        Map<String, dynamic> userData = responseData['data'];

        // Step 2: Update role
        userData['role'] = newRole;
        userData['time'] = DateTime.now().toString();
        userData['uid'] = currentUser.uid;

        // Step 3: Save to cache
        await _pref.setString('Data', json.encode(userData));

        // Step 4: Push updated data back to Firestore using your API
        await http.post(
          Uri.parse(
            "https://authbackend-production-d43e.up.railway.app/api/send-data/",
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(userData),
        );

        // Step 5: Navigate
        if (newRole == null || newRole.toString().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to Select Role"),
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Roles()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RoleBasedHome(role: newRole.toString().toLowerCase()),
            ),
          );
        }
      } else {
        print("❌ Failed to fetch user data from backend");
      }
    } else {
      print("❌ No Firebase user logged in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: height / 5.2,
              child: Stack(
                children: [
                  Positioned(
                    top: -20,
                    left: -100,
                    child: Container(
                      width: 200,
                      height: 180,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(120, 125, 105, 108),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -100,
                    left: -5,
                    child: Container(
                      width: 180,
                      height: 200,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(145, 109, 91, 91),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: height / 10,
                    left: width / 3.5,
                    child: Text(
                      "SELECT YOUR ROLE",
                      style: GoogleFonts.poppins(
                        fontSize: (width / 19.5),
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: height / 3,
              width: width / 1.6,
              child: GestureDetector(
                onTap: () {
                  updateUserRoleInCache('donor');
                },
                child: Image.asset("assets/Donor.png"),
              ),
            ),
            SizedBox(
              height: height / 3,
              width: width / 1.6,
              child: GestureDetector(
                onTap: () {
                  updateUserRoleInCache('victim');
                },
                child: Image.asset("assets/Victim.png"),
              ),
            ),
            SizedBox(
              height: height / 3,
              width: width / 1.6,
              child: GestureDetector(
                onTap: () {
                  updateUserRoleInCache('consultant');
                },
                child: Image.asset("assets/Consultant.png"),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF2EDF6),
    );
  }
}
  