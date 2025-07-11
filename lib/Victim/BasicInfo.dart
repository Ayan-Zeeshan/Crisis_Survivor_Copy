// ignore_for_file: unused_element, file_names, non_constant_identifier_names, avoid_print, no_leading_underscores_for_local_identifiers, unused_local_variable, unnecessary_null_comparison, unused_import, unused_field

import 'dart:convert';
import 'package:crisis_survivor/Victim/victimScreen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VictimBasicInfo extends StatefulWidget {
  const VictimBasicInfo({super.key});

  @override
  State<VictimBasicInfo> createState() => _VictimBasicInfoState();
}

class _VictimBasicInfoState extends State<VictimBasicInfo> {
  String? imageUrl;
  bool isButtonClicked = false;
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accNumController = TextEditingController();
  final TextEditingController _branchCodeController = TextEditingController();

  String? selectedGender;
  DateTime? _selectedDate;
  String? selectedStatus;

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _Permissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.mediaLibrary,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);
    if (!allGranted) {
      print('Permissions not granted');
      bool isPermanentlyDenied = statuses.values.any(
        (status) => status.isPermanentlyDenied,
      );
      if (isPermanentlyDenied) {
        print('Permissions permanently denied');
        openAppSettings();
      }
    } else {
      print('Permissions granted!');
    }
  }

  @override
  Widget build(BuildContext context) {
    void _showSnack(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: Duration(seconds: 2)),
      );
    }

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    setState(() {});
    return Scaffold(
      backgroundColor: const Color(0xFFF2EDF6),
      body: SingleChildScrollView(
        child: Column(
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
            // SizedBox(height: (width / 25.4285714286)),
            SizedBox(
              width: (width / 1.15081081081),
              height: (width / 8),
              child: TextField(
                controller: _nameController,
                style: GoogleFonts.poppins(
                  fontSize: width / 36,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(204, 0, 0, 0),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(
                    41,
                    217,
                    217,
                    217,
                  ), // Keep background transparent
                  labelText: _nameController.text.isEmpty && isButtonClicked
                      ? 'Victim Name  (required):'
                      : 'Victim Name:',
                  labelStyle: GoogleFonts.poppins(
                    color: _nameController.text.isEmpty && isButtonClicked
                        ? Colors.red
                        : Colors.black,
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  hintText: 'Enter your name',
                  hintStyle: GoogleFonts.poppins(
                    color: _nameController.text.isEmpty && isButtonClicked
                        ? Colors.red
                        : Colors.black,
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _nameController.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : Color.fromARGB(
                              41,
                              217,
                              217,
                              217,
                            ), //Color.fromARGB(255, 6, 117, 34),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _nameController.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : Color.fromARGB(
                              41,
                              217,
                              217,
                              217,
                            ), //Color.fromARGB(255, 6, 117, 34),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _nameController.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : Color.fromARGB(
                              41,
                              217,
                              217,
                              217,
                            ), //Color.fromARGB(255, 6, 117, 34),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _nameController.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : Color.fromARGB(
                              41,
                              217,
                              217,
                              217,
                            ), //Color.fromARGB(255, 6, 117, 34),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: (width / 30.4285714286)),
            SizedBox(
              width: (width / 1.15081081081),
              height: (width / 8),
              child: TextField(
                style: GoogleFonts.poppins(
                  fontSize: width / 36,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(204, 0, 0, 0),
                ),
                decoration: InputDecoration(
                  fillColor: Color.fromARGB(41, 217, 217, 217),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _contactNumberController.text.isEmpty &&
                              isButtonClicked
                          ? Colors.red
                          : Color.fromARGB(
                              41,
                              217,
                              217,
                              217,
                            ), //Color.fromARGB(255, 6, 117, 34),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _contactNumberController.text.isEmpty &&
                              isButtonClicked
                          ? Colors.red
                          : Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _contactNumberController.text.isEmpty &&
                              isButtonClicked
                          ? Colors.red
                          : Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _contactNumberController.text.isEmpty &&
                              isButtonClicked
                          ? Colors.red
                          : Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  enabled: true,
                  labelText:
                      _contactNumberController.text.isEmpty && isButtonClicked
                      ? 'Phone Number (Required):'
                      : 'Phone Number:',
                  labelStyle: GoogleFonts.poppins(
                    color:
                        _contactNumberController.text.isEmpty && isButtonClicked
                        ? Colors.red
                        : Colors.black,
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  hintText: 'Enter your contact number',
                  hintStyle: GoogleFonts.poppins(
                    color:
                        _contactNumberController.text.isEmpty && isButtonClicked
                        ? Colors.red
                        : Colors.black,
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                controller: _contactNumberController,
              ),
            ),
            SizedBox(height: (width / 30.4285714286)),
            SizedBox(
              width: (width / 1.15081081081),
              height: (width / 8),
              child: TextField(
                style: GoogleFonts.poppins(
                  fontSize: width / 36,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(204, 0, 0, 0),
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _emailController.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _emailController.text.isEmpty &&
                              isButtonClicked &&
                              isButtonClicked
                          ? Colors.red
                          : Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _emailController.text.isEmpty &&
                              isButtonClicked &&
                              isButtonClicked
                          ? Colors.red
                          : Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _emailController.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  filled: true,
                  fillColor: Color.fromARGB(41, 217, 217, 217),
                  enabled: true,
                  labelText: _emailController.text.isEmpty && isButtonClicked
                      ? 'Email (Required):'
                      : 'Email:',
                  labelStyle: GoogleFonts.poppins(
                    color: _emailController.text.isEmpty && isButtonClicked
                        ? Colors.red
                        : Colors.black,
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  hintText: 'Enter your email',
                  hintStyle: GoogleFonts.poppins(
                    color: _emailController.text.isEmpty && isButtonClicked
                        ? Colors.red
                        : Colors.black,
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                controller: _emailController,
              ),
            ),
            SizedBox(height: (width / 30.4285714286)),
            SizedBox(
              width: (width / 1.15081081081),
              height: (width / 9),
              child: DropdownButtonFormField<String>(
                value: selectedGender,
                style: GoogleFonts.poppins(
                  fontSize: width / 36,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromARGB(204, 0, 0, 0),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(41, 217, 217, 217),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: (selectedGender == null && isButtonClicked)
                          ? Colors.red
                          : const Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: (selectedGender == null && isButtonClicked)
                          ? Colors.red
                          : const Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: (selectedGender == null && isButtonClicked)
                          ? Colors.red
                          : const Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  labelText: (selectedGender == null && isButtonClicked)
                      ? 'Gender (Required):'
                      : 'Gender:',
                  labelStyle: GoogleFonts.poppins(
                    color: (selectedGender == null && isButtonClicked)
                        ? Colors.red
                        : Colors.black,
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                items: ['Male', 'Female'].map((gender) {
                  return DropdownMenuItem(value: gender, child: Text(gender));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
              ),
            ),

            SizedBox(height: (width / 30.4285714286)),

            SizedBox(
              width: (width / 1.15081081081),
              height: (width / 9),
              child: TextField(
                controller: _dobController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(
                  fontSize: width / 36,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromARGB(204, 0, 0, 0),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(41, 217, 217, 217),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: (_dobController.text.isEmpty && isButtonClicked)
                          ? Colors.red
                          : const Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: (_dobController.text.isEmpty && isButtonClicked)
                          ? Colors.red
                          : const Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: (_dobController.text.isEmpty && isButtonClicked)
                          ? Colors.red
                          : const Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  labelText: (_dobController.text.isEmpty && isButtonClicked)
                      ? 'Date of Birth (Required):'
                      : 'Date of Birth:',
                  labelStyle: GoogleFonts.poppins(
                    color: (_dobController.text.isEmpty && isButtonClicked)
                        ? Colors.red
                        : Colors.black,
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  hintText: 'DD/MM/YYYY',
                  hintStyle: GoogleFonts.poppins(
                    color: (_dobController.text.isEmpty && isButtonClicked)
                        ? Colors.red
                        : Colors.black,
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today, size: width / 20.55),
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(0),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        _selectedDate = pickedDate;
                        _dobController.text =
                            "${pickedDate.day.toString().padLeft(2, '0')}/"
                            "${pickedDate.month.toString().padLeft(2, '0')}/"
                            "${pickedDate.year}";

                        setState(() {}); // Just to trigger UI update, if needed
                      }
                    },
                  ),
                ),
                onChanged: (value) {
                  if (value.length == 2 || value.length == 5) {
                    if (!_dobController.text.endsWith('/')) {
                      _dobController.text += '/';
                      _dobController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _dobController.text.length),
                      );
                    }
                  }
                },
              ),
            ),
            SizedBox(height: (width / 30.4285714286)),
            SizedBox(
              width: (width / 1.15081081081),
              height: (width / 9),
              child: DropdownButtonFormField<String>(
                value: selectedStatus,
                style: GoogleFonts.poppins(
                  fontSize: width / 36,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromARGB(204, 0, 0, 0),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(41, 217, 217, 217),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: (selectedStatus == null && isButtonClicked)
                          ? Colors.red
                          : const Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: (selectedStatus == null && isButtonClicked)
                          ? Colors.red
                          : const Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: (selectedStatus == null && isButtonClicked)
                          ? Colors.red
                          : const Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  labelText: (selectedStatus == null && isButtonClicked)
                      ? 'Status (Required):'
                      : 'Status:',
                  labelStyle: GoogleFonts.poppins(
                    color: (selectedStatus == null && isButtonClicked)
                        ? Colors.red
                        : Colors.black,
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                items: ['Married', 'Single', 'Divorced'].map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                },
              ),
            ),
            SizedBox(height: (width / 30.4285714286)),
            SizedBox(
              width: (width / 1.15081081081),
              height: (width / 8),
              child: TextField(
                style: GoogleFonts.poppins(
                  fontSize: width / 36,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromARGB(204, 0, 0, 0),
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _bankNameController.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : const Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _bankNameController.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : const Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _bankNameController.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : const Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _bankNameController.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : const Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(41, 217, 217, 217),
                  enabled: true,
                  labelText: _bankNameController.text.isEmpty && isButtonClicked
                      ? 'Bank Name (Required):'
                      : 'Bank Name:',
                  labelStyle: GoogleFonts.poppins(
                    color: _bankNameController.text.isEmpty && isButtonClicked
                        ? Colors.red
                        : Colors.black,
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  hintText: 'Enter Bank Name',
                  hintStyle: GoogleFonts.poppins(
                    color: _bankNameController.text.isEmpty && isButtonClicked
                        ? Colors.red
                        : Colors.black,
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                controller: _bankNameController,
              ),
            ),
            SizedBox(height: (width / 30.4285714286)),
            SizedBox(
              width: (width / 1.15081081081),
              height: (width / 8),
              child: TextField(
                style: GoogleFonts.poppins(
                  fontSize: width / 36,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromARGB(204, 0, 0, 0),
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _accNumController.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : const Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _accNumController.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : const Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _accNumController.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : const Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _accNumController.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : const Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(41, 217, 217, 217),
                  enabled: true,
                  labelText: _accNumController.text.isEmpty && isButtonClicked
                      ? 'Bank Account Number (Required):'
                      : 'Bank Account Number:',
                  labelStyle: GoogleFonts.poppins(
                    color: _accNumController.text.isEmpty && isButtonClicked
                        ? Colors.red
                        : Colors.black,
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  hintText: 'Enter Account Number',
                  hintStyle: GoogleFonts.poppins(
                    color: _accNumController.text.isEmpty && isButtonClicked
                        ? Colors.red
                        : Colors.black,
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                controller: _accNumController,
              ),
            ),
            SizedBox(height: (width / 30.4285714286)),
            SizedBox(
              width: (width / 1.15081081081),
              height: (width / 8),
              child: TextField(
                style: GoogleFonts.poppins(
                  fontSize: width / 36,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromARGB(204, 0, 0, 0),
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _branchCodeController.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : const Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _branchCodeController.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : const Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _branchCodeController.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : const Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _branchCodeController.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : const Color.fromARGB(41, 217, 217, 217),
                    ),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(41, 217, 217, 217),
                  enabled: true,
                  labelText:
                      _branchCodeController.text.isEmpty && isButtonClicked
                      ? 'Branch Code (Required):'
                      : 'Branch Code:',
                  labelStyle: GoogleFonts.poppins(
                    color: _branchCodeController.text.isEmpty && isButtonClicked
                        ? Colors.red
                        : Colors.black,
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  hintText: 'Enter Branch Code',
                  hintStyle: GoogleFonts.poppins(
                    color: _branchCodeController.text.isEmpty && isButtonClicked
                        ? Colors.red
                        : Colors.black,
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                controller: _branchCodeController,
              ),
            ),

            SizedBox(height: (width / 15.4285714286)),
            Padding(
              padding: EdgeInsets.symmetric(vertical: width / 100.0),
              child: ElevatedButton(
                onPressed: () async {
                  setState(() => isButtonClicked = true);

                  final name = _nameController.text.trim();
                  final phone = _contactNumberController.text.trim();
                  final email = _emailController.text.trim();
                  final gender = selectedGender;
                  final dateOfBirth = _dobController.text;
                  final status = selectedStatus;
                  final bankName = _bankNameController.text;
                  final accNum = _accNumController.text;
                  final branchCode = _branchCodeController.text;
                  List details = [
                    name,
                    phone,
                    email,
                    gender,
                    dateOfBirth,
                    status,
                    bankName,
                    accNum,
                    branchCode,
                  ];
                  bool flag = true;
                  // 🟥 Empty fields
                  for (int i = 0; i < details.length; i++) {
                    if (details[i] == null || details[i].isEmpty) {
                      flag = false;
                      break;
                    } else {
                      flag = true;
                    }
                  }
                  if (flag) {
                    _showSnack("All fields are required!");
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => victimScreen()),
                    );
                    return;
                  }
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(width / 1.12, width / 7.5),
                  backgroundColor: const Color.fromARGB(194, 86, 61, 61),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(width / 50)),
                    side: const BorderSide(
                      color: Color.fromARGB(194, 86, 61, 61),
                    ),
                  ),
                ),
                child: Text(
                  "Save",
                  style: GoogleFonts.poppins(
                    color: const Color.fromARGB(253, 255, 255, 255),
                    fontSize: (width / 25.55),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: height * 0.025),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: width * 0.06),
                SizedBox(
                  child: GestureDetector(
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'jpeg', 'png'],
                      );
                      if (result != null) {
                        setState(() {
                          //imageUrl = result.files.first.path;
                        });
                      }
                    },
                    child: CameraIconWidget(size: width * 0.12),
                  ),
                ),

                SizedBox(width: width * 0.05),
                GestureDetector(
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['jpg', 'jpeg', 'png'],
                    );
                    if (result != null) {
                      setState(() {
                        // imageUrl = result.files.first.path;
                      });
                    }
                  },
                  child: Text(
                    "CLICK TO UPLOAD REAL \nTIME PICTURE",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: width * 0.055,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.05),
          ],
        ),
      ),
    );
  }
}

class CameraIconWidget extends StatelessWidget {
  final double size;
  const CameraIconWidget({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/camera.png",
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
