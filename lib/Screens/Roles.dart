// ignore_for_file: file_names, no_leading_underscores_for_local_identifiers, avoid_print, use_build_context_synchronously, unused_import

import 'dart:convert';
import 'dart:developer';
import 'package:crisis_survivor/Consultant/BasicInfo.dart';
import 'package:crisis_survivor/Donor/BasicInfo.dart';
import 'package:crisis_survivor/Victim/BasicInfo.dart';
import 'package:crisis_survivor/auth_guard.dart';
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
  @override
  void initState() {
    super.initState();
    Future.microtask(() => AuthGuard.startMonitoring(context));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF2EDF6),
      body: SingleChildScrollView(
        child: Column(
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
                ],
              ),
            ),

            Text(
              "Would You Like to...",
              style: GoogleFonts.poppins(
                fontSize: width / 19.5,
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: height * 0.04),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SizedBox(width: width / 9),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => DonorBasicInfo()),
                    );
                  },
                  // style: ElevatedButton.styleFrom(
                  //   backgroundColor: Color(0xFFd2bab0),
                  // ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: width * 0.3,
                        height: height * 0.13,
                        child: Image.asset(
                          "assets/Donor.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(width: width * 0.05),
                      SizedBox(
                        height: height * 0.13,
                        child: Center(
                          child: Text(
                            "Become a Donor",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: width / 21,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(194, 86, 61, 61),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.05),

            // Victim Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SizedBox(width: width * 0.1),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VictimBasicInfo(),
                      ),
                    );
                  },
                  // style: ElevatedButton.styleFrom(
                  //   backgroundColor: Color(0xFFd2bab0),
                  // ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: width * 0.3,
                        height: height * 0.13,
                        child: Image.asset(
                          "assets/Victim.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      // SizedBox(width: width * 0.05),
                      SizedBox(
                        height: height * 0.13,
                        child: Center(
                          child: Text(
                            "Request for                 \nDonations                 ",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: width / 21,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(194, 86, 61, 61),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.07),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConsultantBasicInfo(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: width * 0.3,
                        height: height * 0.13,
                        child: Image.asset(
                          "assets/Consultant.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(width: width * 0.05),
                      SizedBox(
                        height: height * 0.13,
                        child: Center(
                          child: Text(
                            "Apply for        \nConsultance        ",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: width / 21,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(194, 86, 61, 61),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
