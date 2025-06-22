// ignore_for_file: non_constant_identifier_names, file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget BuildTextField({
  required double width,
  required double height,
  required bool isEditing,
  required String label,
  required TextEditingController controller,
  required String defaultValue,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Stack(
    alignment: Alignment.centerLeft,
    children: [
      SizedBox(
        width: width / 1.15081081081,
        height: height / 15,
        child: TextField(
          controller: controller,
          readOnly: !isEditing,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(
            fontSize: width / 36,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666), //Color.fromARGB(41, 217, 217, 217),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Color.fromARGB(41, 217, 217, 217),
            // contentPadding: EdgeInsets.symmetric(
            //   // horizontal: width / 3,
            //   vertical: height / 50,
            // ),
            labelText: isEditing ? "$label: " : null,
            labelStyle: isEditing
                ? GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: width / 28,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(width / 1.9),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      if (!isEditing)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width / 32),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "$label: ",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: width / 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: defaultValue,
                  style: GoogleFonts.poppins(
                    color: Color.fromARGB(41, 217, 217, 217),
                    fontWeight: FontWeight.w600,
                    fontSize: width / 28,
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}
