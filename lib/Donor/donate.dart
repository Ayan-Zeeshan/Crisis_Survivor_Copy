// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DonatePage extends StatelessWidget {
  const DonatePage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 180, // just enough to cover the top background
            child: Stack(
              children: [
                // Darker big circle (Ellipse 2)
                Positioned(
                  top: //-20,
                      width / -22,
                  left: //-100,
                      width / -4.15,
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
                  top: width / -4.15, //-100,
                  left:
                      //-5,
                      width / -90,
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
              ],
            ),
          ),
          SizedBox(height: (width / 7.4285714286)),

          Text(
            "BASIC INFORMATION",
            style: GoogleFonts.poppins(
              fontSize: (width / 21.5),
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: (width / 7.4285714286)),
        ],
      ),
    );
  }
}
