// ignore_for_file: unused_field, unused_local_variable, no_leading_underscores_for_local_identifiers, unnecessary_import, unused_import, duplicate_ignore

// ignore: unused_import
import 'dart:io';

import 'package:crisis_survivor/Victim/victimScreen.dart';
import 'package:crisis_survivor/Victim/UploadPage.dart';
import 'package:crisis_survivor/Widget/textField.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  bool isEditing = false;
  // final TextEditingController _nameController = TextEditingController();
  // final TextEditingController _contactNumberController =
  //     TextEditingController();
  // final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _bankNameController = TextEditingController();
  // final TextEditingController _bankAccountController = TextEditingController();
  // final TextEditingController _branchCodeController = TextEditingController();
  // final FocusNode _nameFocusNode = FocusNode();
  // final bool _isNameFocused = false;
  // String? selectedGender;

  // readcache() async {
  //   SharedPreferences _pref = await SharedPreferences.getInstance();
  //   // _pref.getString('');
  //   final cacheDir = await getTemporaryDirectory();
  //   final cnicCard = File('${cacheDir.path}/cnic_card.png');
  //   // await _pref;
  // }

  bool isButtonClicked = false;
  bool isEditMode = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  // Place these at the top of your widget class (e.g., inside _YourState)
  final TextEditingController _bankName = TextEditingController();
  final TextEditingController _accountNumber = TextEditingController();
  final TextEditingController _branchCode = TextEditingController();

  String savedBankName = '';
  String savedAccountNumber = '';
  String savedBranchCode = '';
  String? selectedGender;
  String victimName = "John Doe";
  String phoneNumber = "03123456789";
  // String email = "john@example.com";

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
              height: height * 0.33, // just enough to cover the top background
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
                  Positioned(
                    top: height / 10,
                    left: width / 3.7,
                    child: CircleAvatar(
                      maxRadius: (width / 4.1577777),
                      backgroundColor: const Color(0xFFF2EDF6),

                      backgroundImage: const AssetImage(
                        "assets/Profilepic2.png",
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: width / 16.428),
            BuildTextField(
              width: width,
              height: height,
              isEditing: isEditing,
              label: 'Victim Name',
              controller: _nameController,
              defaultValue: victimName,
            ),
            SizedBox(height: width / 30.42),
            BuildTextField(
              width: width,
              height: height,
              isEditing: isEditing,
              label: 'Phone Number',
              controller: _contactNumberController,
              defaultValue: phoneNumber,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: width / 30.42),

            // BuildTextField(
            //   width: width,
            //   height: height,
            //   isEditing: isEditing,
            //   label: 'Email',
            //   controller: _emailController,
            //   defaultValue: email,
            // ),
            // SizedBox(height: width / 30.42),
            SizedBox(
              width: (width / 1.15081081081),
              height: (height / 15),
              child: DropdownButtonFormField<String>(
                value: selectedGender,
                style: GoogleFonts.poppins(
                  fontSize: width / 36,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(41, 217, 217, 217),
                  labelText: 'Gender:',
                  labelStyle: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: width / 28,
                    fontWeight: FontWeight.w600,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: ['Male', 'Female'].map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(
                      gender,
                      style: GoogleFonts.poppins(
                        fontSize: width / 36,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (isEditing) {
                    setState(() => selectedGender = value!);
                  }
                },
              ),
            ),
            SizedBox(height: width / 30.42),

            ElevatedButton(
              onPressed: () {
                // showDialog(
                //   context: context,
                //   builder: (_) => AlertDialog(
                //     title: Text("All Documents"),
                //     content: Column(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         Image.asset("assets/doc1.png"),
                //         Image.asset("assets/doc2.png"),
                //       ],
                //     ),
                //     actions: isEditing
                //         ? [
                //             TextButton(onPressed: () {}, child: Text("Edit")),
                //             TextButton(onPressed: () {}, child: Text("Delete")),
                //           ]
                //         : [],
                //   ),
                // );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UploadPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 238, 234, 241),
                shadowColor: Colors.transparent,
                fixedSize: Size(width / 1.15, height * 0.06),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.black,
                    size: width / 15,
                  ),
                  SizedBox(width: width / 65),
                  Text(
                    "All Documents Here",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: width / 28,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: width / 30.42),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: Size(width / 1.15, height * 0.06),
                backgroundColor: const Color.fromARGB(255, 238, 234, 241),
                shadowColor: Colors.transparent,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(
                      "Bank Details",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: width / 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _bankName,
                          style: GoogleFonts.poppins(
                            fontSize: width / 25,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            labelText: "Bank Name",
                            labelStyle: GoogleFonts.poppins(
                              fontSize: width / 25,
                              fontWeight: FontWeight.w500,
                            ),
                            hintText: "Enter your Bank Name",
                            hintStyle: GoogleFonts.poppins(
                              fontSize: width / 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextField(
                          controller: _accountNumber,
                          style: GoogleFonts.poppins(
                            fontSize: width / 25,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            labelText: "Account Number",
                            labelStyle: GoogleFonts.poppins(
                              fontSize: width / 25,
                              fontWeight: FontWeight.w500,
                            ),
                            hintText: "Enter your Account Number",
                            hintStyle: GoogleFonts.poppins(
                              fontSize: width / 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextField(
                          controller: _branchCode,
                          style: GoogleFonts.poppins(
                            fontSize: width / 25,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            labelText: "Branch Code",
                            labelStyle: GoogleFonts.poppins(
                              fontSize: width / 25,
                              fontWeight: FontWeight.w500,
                            ),
                            hintText: "Enter your Bank Branch Code",
                            hintStyle: GoogleFonts.poppins(
                              fontSize: width / 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          if (_bankName.text.isEmpty ||
                              _accountNumber.text.isEmpty ||
                              _branchCode.text.isEmpty) {
                            Navigator.pop(context);
                            _showSnack("All fields are required!");
                          } else {
                            // Save values
                            setState(() {
                              savedBankName = _bankName.text;
                              savedAccountNumber = _accountNumber.text;
                              savedBranchCode = _branchCode.text;
                            });
                            Navigator.pop(context); // Just close the dialog
                          }
                        },
                        child: Text("Save"),
                      ),
                    ],
                  ),
                );
              },
              child:
                  //  Row(
                  //   children: [
                  //     Icon(
                  //       Icons.camera_alt_outlined,
                  //       color: Colors.black,
                  //       size: width / 15,
                  //     ),
                  //     SizedBox(width: width / 65),
                  Text(
                    "Bank Details",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: width / 28,
                    ),
                  ),
              //   ],
              // ),
            ),
            SizedBox(height: width / 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: width / 15),
                ElevatedButton(
                  onPressed: () {
                    setState(() => isEditing = true);
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(width / 2.5, height * 0.063),
                    backgroundColor: const Color.fromARGB(194, 86, 61, 61),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(width / 10),
                      ),
                      side: const BorderSide(
                        color: Color.fromARGB(194, 86, 61, 61),
                      ),
                    ),
                  ),
                  child: Text(
                    "Edit",
                    style: GoogleFonts.poppins(
                      color: const Color.fromARGB(253, 255, 255, 255),
                      fontSize: (width / 18.55),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: width / 15),
                ElevatedButton(
                  onPressed: () async {
                    setState(() => isButtonClicked = true);

                    final name = _nameController.text.trim();
                    final phone = _contactNumberController.text.trim();
                    // final email = _emailController.text.trim();
                    final gender = selectedGender;
                    List details = [name, phone, gender];
                    bool flag = true;
                    for (int i = 0; i < details.length; i++) {
                      if (details[i] == null || details[i].isEmpty) {
                        flag = false;
                        break;
                      }
                    }
                    if (flag) {
                      _showSnack("All fields are required!");
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => victimScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(width / 2.5, height * 0.063),
                    backgroundColor: const Color.fromARGB(194, 86, 61, 61),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(width / 10),
                      ),
                      side: const BorderSide(
                        color: Color.fromARGB(194, 86, 61, 61),
                      ),
                    ),
                  ),
                  child: Text(
                    "Save",
                    style: GoogleFonts.poppins(
                      color: const Color.fromARGB(253, 255, 255, 255),
                      fontSize: (width / 18.55),
                      fontWeight: FontWeight.bold,
                    ),
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
