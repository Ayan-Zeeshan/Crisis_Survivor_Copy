import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool isObscure;
  final bool isPassword;
  final bool isVisible;
  final double width;
  final double height;
  final bool isButtonClicked;
  final String label;
  final String hint;
  final Color labelColor;
  final Color borderColor;
  final VoidCallback? toggleVisibility;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.width,
    required this.height,
    required this.label,
    required this.hint,
    required this.labelColor,
    required this.borderColor,
    this.isObscure = false,
    this.isPassword = false,
    this.isVisible = true,
    required this.isButtonClicked,
    this.toggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = controller.text.isEmpty;
    final bool isError = isEmpty && isButtonClicked;

    return SizedBox(
      width: width / 1.15081081081,
      height: height,
      child: TextField(
        controller: controller,
        obscureText: isPassword ? isObscure : false,
        style: GoogleFonts.poppins(
          fontSize: width / 36,
          fontWeight: FontWeight.w400,
          color: const Color.fromARGB(204, 0, 0, 0),
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: isError ? '$label (Required)' : label,
          labelStyle: GoogleFonts.poppins(
            color: isError ? Colors.red : labelColor,
            fontSize: width / 36,
            fontWeight: FontWeight.w400,
          ),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: isError ? Colors.red : labelColor,
            fontSize: width / 36,
            fontWeight: FontWeight.w400,
          ),
          border: _buildBorder(isError ? Colors.red : borderColor),
          enabledBorder: _buildBorder(isError ? Colors.red : borderColor),
          focusedBorder: _buildBorder(isError ? Colors.red : borderColor),
          errorBorder: _buildBorder(Colors.red),
          suffixIcon: isPassword
              ? GestureDetector(
                  onTap: toggleVisibility,
                  child: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    size: width / 20.55,
                    color: Colors.black,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(width / 1.9)),
      borderSide: BorderSide(color: color),
    );
  }
}
