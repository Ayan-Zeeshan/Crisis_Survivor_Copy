// ignore_for_file: camel_case_types, use_build_context_synchronously, file_names

import 'package:crisis_survivor/Victim/request.dart';
import 'package:crisis_survivor/Victim/safety.dart';
import 'package:crisis_survivor/Victim/sheltermap.dart';
import 'package:crisis_survivor/auth_guard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class victimScreen extends StatefulWidget {
  const victimScreen({super.key});

  @override
  State<victimScreen> createState() => _victimScreenState();
}

class _victimScreenState extends State<victimScreen> {
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: height * 0.23, // just enough to cover the top background
              child: Stack(
                children: [
                  // Darker big circle (Ellipse 2)
                  Positioned(
                    top: //-20,
                        width / -22,
                    left: //-100,
                        width / -4.15,
                    child: Container(
                      width: height / 4.3,
                      height: width / 2.3,
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
                    top: width / -4.15, //-100,
                    left:
                        //-5,
                        width / -90,
                    child: Container(
                      width: //98,
                          // 180,
                          width / 2.3,
                      height: //98,
                          // 200,
                          height / 4.3,
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
                ],
              ),
            ),
            SizedBox(height: (width / 17.4285714286)),

            Text(
              "EMERGENCY HELP SERVICES",
              style: GoogleFonts.poppins(
                fontSize: (width / 21.5),
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: height / 22),
            SizedBox(
              width: width / 1.4,
              height: height / 12,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC2B6BD),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MapPage()),
                  );
                },
                child: Text(
                  "Nearest Relief Camps",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: width / 21,
                  ),
                ),
              ),
            ),
            SizedBox(height: height / 45),
            SizedBox(
              width: width / 1.4,
              height: height / 12,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC2B6BD),
                ),
                onPressed: () async {
                  final Uri phoneUri = Uri(scheme: 'tel', path: '112');
                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  } else {
                    // log('❌ Could not launch dialer');
                  }
                },
                child: Text(
                  "Emergency Helpline",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: width / 21,
                  ),
                ),
              ),
            ),
            SizedBox(height: height / 45),
            SizedBox(
              width: width / 1.4,
              height: height / 12,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC2B6BD),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RequestPage()),
                  );
                },
                child: Text(
                  "Request for Donations",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: width / 21,
                  ),
                ),
              ),
            ),
            SizedBox(height: height / 45),
            SizedBox(
              width: width / 1.4,
              height: height / 12,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC2B6BD),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Safety()),
                  );
                },
                child: Text(
                  "Safety Tips and Guides",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: width / 21,
                  ),
                ),
              ),
            ),
            SizedBox(height: height / 45),
            SizedBox(
              width: width / 1.4,
              height: height / 12,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC2B6BD),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MapPage()),
                  );
                },
                child: Text(
                  "Medical Assess",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: width / 21,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF2EDF6),
    );
  }
}
