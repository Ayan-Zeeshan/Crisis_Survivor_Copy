// ignore_for_file: unused_element, file_names, non_constant_identifier_names, avoid_print, no_leading_underscores_for_local_identifiers, unused_local_variable, unnecessary_null_comparison, unused_import, unused_field, use_build_context_synchronously

import 'dart:convert';
import 'dart:typed_data';
import 'package:crisis_survivor/Consultant/consultantscreen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class ConsultantBasicInfo extends StatefulWidget {
  const ConsultantBasicInfo({super.key});

  @override
  State<ConsultantBasicInfo> createState() => _ConsultantBasicInfoState();
}

class _ConsultantBasicInfoState extends State<ConsultantBasicInfo> {
  String? imageUrl;
  bool isButtonClicked = false;
  bool isFileUploaded = false;
  // Add this variable at the top of your State class:
  PlatformFile? _uploadedFile;
  Uint8List? _uploadedImageBytes;

  // String? labelText;
  final TextEditingController _dobController = TextEditingController();
  DateTime? _selectedDate;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  // TextEditingController _nameController5 = TextEditingController();
  // Add these controllers and variables to your class:
  String? selectedGender;

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

            buildCustomTextField(
              width: width,
              controller: _nameController,
              isButtonClicked: isButtonClicked,
              label: "Consultant Name",
              hint: "Enter your name",
            ),
            SizedBox(height: width / 30.4285714286),

            buildCustomTextField(
              width: width,
              controller: _contactNumberController,
              isButtonClicked: isButtonClicked,
              label: "Phone Number",
              hint: "Enter your contact number",
            ),
            SizedBox(height: width / 30.4285714286),

            buildCustomTextField(
              width: width,
              controller: _emailController,
              isButtonClicked: isButtonClicked,
              label: "Email",
              hint: "Enter your email",
            ),
            SizedBox(height: width / 30.4285714286),

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

            SizedBox(height: (width / 15.4285714286)),
            // SizedBox(height: (width / 30.4285714286)),
            Padding(
              padding: EdgeInsets.symmetric(vertical: width / 100.0),
              child: ElevatedButton(
                onPressed: () async {
                  setState(() => isButtonClicked = true);

                  SharedPreferences _cachedData;
                  String? dataString;
                  Map<String, dynamic>? data;

                  final name = _nameController.text.trim();
                  final phone = _contactNumberController.text.trim();
                  final email = _emailController.text.trim();
                  final gender = selectedGender;
                  final dateOfBirth = _dobController.text.trim();

                  if (name.isEmpty ||
                      phone.isEmpty ||
                      email.isEmpty ||
                      gender == null ||
                      dateOfBirth.isEmpty) {
                    _showSnack("All fields are required!");
                    return;
                  }

                  try {
                    final user = FirebaseAuth.instance.currentUser;

                    if (user == null) {
                      _showSnack("Not logged in!");
                      _cachedData = await SharedPreferences.getInstance();
                      dataString = _cachedData.getString('Data');

                      if (dataString != null) {
                        data = json.decode(dataString);
                        log("$data");
                      }
                      return;
                    }

                    final uid = user.uid;

                    _cachedData = await SharedPreferences.getInstance();
                    dataString = _cachedData.getString('Data');

                    if (dataString == null) {
                      _showSnack("User role not found in local storage.");
                      return;
                    }

                    data = json.decode(dataString);
                    final role = data!['role'];

                    final body = {
                      "uid": uid,
                      "role": role,
                      "name": name,
                      "phone_number": phone,
                      "email": email,
                      "gender": gender,
                      "date_of_birth": dateOfBirth,
                    };

                    final response = await http.post(
                      Uri.parse(
                        "https://authbackend-production-d43e.up.railway.app/api/send-info/",
                      ),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode(body),
                    );

                    if (response.statusCode == 200) {
                      _showSnack("Information saved!");
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConsultantScreen(),
                        ),
                      );
                    } else {
                      _showSnack("Server error: ${response.body}");
                    }
                  } catch (e) {
                    _showSnack("Error: $e");
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(width: width * 0.06),
                if (_uploadedImageBytes == null) ...[
                  SizedBox(
                    child: GestureDetector(
                      onTap: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['jpg', 'jpeg', 'png'],
                          withData: true,
                        );
                        if (result != null) {
                          setState(() {
                            _uploadedFile = result.files.first;
                            _uploadedImageBytes = result.files.first.bytes;
                          });
                        }
                      },
                      child: CameraIconWidget(size: width * 0.12),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'jpeg', 'png'],
                        withData: true,
                      );
                      if (result != null) {
                        setState(() {
                          _uploadedFile = result.files.first;
                          _uploadedImageBytes = result.files.first.bytes;
                        });
                      }
                    },
                    child: Text(
                      "CLICK TO UPLOAD \n DEGREE AND LICENSE",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: width * 0.06,
                      ),
                    ),
                  ),
                ] else ...[
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['jpg', 'jpeg', 'png'],
                            withData: true,
                          );
                          if (result != null) {
                            setState(() {
                              _uploadedFile = result.files.first;
                              _uploadedImageBytes = result.files.first.bytes;
                            });
                          }
                        },
                        child: Container(
                          width: width * 0.35,
                          height: width * 0.35,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              _uploadedImageBytes!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['jpg', 'jpeg', 'png'],
                            withData: true,
                          );
                          if (result != null) {
                            setState(() {
                              _uploadedFile = result.files.first;
                              _uploadedImageBytes = result.files.first.bytes;
                            });
                          }
                        },
                        child: Text(
                          _uploadedFile!.name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: width * 0.035,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(width: width * 0.07),
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

Widget buildCustomTextField({
  required double width,
  required TextEditingController controller,
  required bool isButtonClicked,
  required String label,
  required String hint,
}) {
  final bool isEmpty = controller.text.isEmpty && isButtonClicked;
  final borderColor = isEmpty
      ? Colors.red
      : const Color.fromARGB(41, 217, 217, 217);

  return SizedBox(
    width: width / 1.15081081081,
    height: width / 8,
    child: TextField(
      controller: controller,
      style: GoogleFonts.poppins(
        fontSize: width / 36,
        fontWeight: FontWeight.w400,
        color: const Color.fromARGB(204, 0, 0, 0),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(41, 217, 217, 217),
        labelText: isEmpty ? "$label (Required):" : "$label:",
        labelStyle: GoogleFonts.poppins(
          color: isEmpty ? Colors.red : Colors.black,
          fontSize: width / 36,
          fontWeight: FontWeight.w400,
        ),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: isEmpty ? Colors.red : Colors.black,
          fontSize: width / 36,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(width / 1.9)),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(width / 1.9)),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(width / 1.9)),
          borderSide: BorderSide(color: borderColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(width / 1.9)),
          borderSide: BorderSide(color: borderColor),
        ),
      ),
    ),
  );
}
