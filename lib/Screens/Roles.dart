// ignore_for_file: file_names, no_leading_underscores_for_local_identifiers, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:crisis_survivor/Admin/adminPage.dart';
import 'package:crisis_survivor/Donee/doneecreen.dart';
import 'package:crisis_survivor/Donor/donorscreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Roles extends StatefulWidget {
  const Roles({super.key});

  @override
  State<Roles> createState() => _RolesState();
}

class _RolesState extends State<Roles> {
  Future<void> updateUserRoleInCache(String? newRole) async {
    SharedPreferences _pref = await SharedPreferences.getInstance();

    // Step 1: Read the cache
    String? cachedData = _pref.getString('Data');

    if (cachedData != null && cachedData.isNotEmpty) {
      // Step 2: Decode the JSON
      Map<String, dynamic> userDetails = json.decode(cachedData);
      print("Cache: $userDetails");

      // Step 3: Update the role and time
      userDetails['role'] = newRole;
      userDetails['time'] = DateTime.now().toString();

      // Step 4: Save back to cache
      await _pref.setString('Data', json.encode(userDetails));

      print("Cache updated: $userDetails");
      switch (newRole) {
        case 'admin':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Admin()),
          );
        case 'donor':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DonorScreen()),
          );
        case 'donee':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DoneeScreen()),
          );
        default:
          return;
      }
    } else {
      print("No cache found to update.");
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            // width: width / 2.25,
            width: double.infinity,
            height: height / 4.1, // just enough to cover the top background
            child: Stack(
              children: [
                // Darker big circle (Ellipse 2)
                Positioned(
                  top: -20,
                  left: -100,
                  child: Container(
                    width: 200,
                    height: 180,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(
                        120,
                        125,
                        105,
                        108,
                      ), // #7B676A with 61% opacity
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Lighter overlapping circle (Ellipse 1)
                Positioned(
                  top: -100,
                  left: -5,
                  child: Container(
                    width: 180,
                    height: 200,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(
                        145,
                        109,
                        91,
                        91,
                      ), // #5B5B61 with 38% opacity
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Positioned(
                //   top: width / 4.15, //100,
                //   left: width / 2.6000000001,
                //   //160,
                //   child: Text(
                //     "SIGN IN",
                //     style: GoogleFonts.poppins(
                //       fontSize: (width / 19.5),
                //       color: Colors.black,
                //       fontWeight: FontWeight.w700,
                //     ),
                //   ),
                // ),
                // // SizedBox(height: (width / 69.55)),)
                // Positioned(
                //   top: width / 3.3,
                //   // 110,
                //   left: width / 4.2,
                //   child: CircleAvatar(
                //     maxRadius: (width / 4.1577777),
                //     backgroundColor: const Color(0xFFF2EDF6),

                //     backgroundImage: const AssetImage(
                //       "assets/Profilepic2.png",
                //     ),
                //   ),
                // ),
                Center(
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

          // SizedBox(height: (height / 350.22857142857)),
          // Center(
          //   child:
          // SizedBox(
          //   height: width / 2.1,
          //   child: Stack(
          //     children: [
          //       Positioned(
          //         left: 1.0,
          //         top: 2.0,
          //         child: Icon(
          //           Icons.circle,
          //           color: Colors.black54,
          //           size: (width / 1.955),
          //         ),
          //       ),
          //       Positioned(
          //         right: 1.0,
          //         top: 2.0,
          //         child: Icon(
          //           Icons.circle,
          //           color: Colors.black45,
          //           size: (width / 1.955),
          //         ),
          //       ),

          //     ],
          //   ),
          // ),
          // ),
          SizedBox(height: (width / 69.55)),
          ElevatedButton(
            onPressed: () {
              updateUserRoleInCache('admin');
            },
            child: Text("Update"),
          ),
        ],
      ),
      backgroundColor: Color(0xFFF2EDF6),
    );
  }
}
