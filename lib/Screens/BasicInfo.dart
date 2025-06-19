// ignore_for_file: unused_element, file_names, non_constant_identifier_names, avoid_print, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class BasicInfo extends StatefulWidget {
  final String role;
  const BasicInfo({super.key, required this.role});
  @override
  State<BasicInfo> createState() => _BasicInfoState();
}

class _BasicInfoState extends State<BasicInfo> {
  bool isButtonClicked = false;
  String? labelText;

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
    double width = MediaQuery.of(context).size.width;
    TextEditingController _myController = TextEditingController();
    TextEditingController _myController2 = TextEditingController();
    TextEditingController _myController3 = TextEditingController();
    TextEditingController _myController4 = TextEditingController();
    TextEditingController _myController5 = TextEditingController();
    setState(() {
      if (widget.role == "donor") {
        labelText = "Donor";
      }
      if (widget.role == "consultant") {
        labelText = "Consultant";
      }
      if (widget.role == "victim") {
        labelText = "Victim";
      }
      // labelText = widget.role;
    });
    return Scaffold(
      backgroundColor: const Color(0xFFF2EDF6),
      body: SingleChildScrollView(
        child: Column(
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
            // SizedBox(height: (width / 25.4285714286)),
            SizedBox(
              width: (width / 1.15081081081),
              height: (width / 8),
              child: TextField(
                controller: _myController,
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
                  labelText: _myController.text.isEmpty && isButtonClicked
                      ? '$labelText Name (Required)'
                      : '$labelText Name',
                  labelStyle: GoogleFonts.poppins(
                    color: _myController.text.isEmpty && isButtonClicked
                        ? Colors.red
                        : Colors.black,
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  hintText: 'Enter $labelText name',
                  hintStyle: GoogleFonts.poppins(
                    color: _myController.text.isEmpty && isButtonClicked
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
                      color: _myController.text.isEmpty && isButtonClicked
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
                      color: _myController.text.isEmpty && isButtonClicked
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
                      color: _myController.text.isEmpty && isButtonClicked
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
                      color: _myController.text.isEmpty && isButtonClicked
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
                      color: _myController2.text.isEmpty && isButtonClicked
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
                      color: _myController2.text.isEmpty && isButtonClicked
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
                      color: _myController2.text.isEmpty && isButtonClicked
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
                      color: _myController2.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : Color.fromARGB(
                              41,
                              217,
                              217,
                              217,
                            ), //Color.fromARGB(255, 6, 117, 34),
                    ),
                  ),
                  enabled: true,
                  labelText: _myController2.text.isEmpty && isButtonClicked
                      ? 'Create Email Address (Required)'
                      : 'Create Email Address',
                  labelStyle: GoogleFonts.poppins(
                    color: _myController2.text.isEmpty && isButtonClicked
                        ? Colors.red
                        : Colors.black, //Color.fromARGB(255, 6, 117, 34),
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  hintText: 'Enter your email address',
                  hintStyle: GoogleFonts.poppins(
                    color: _myController2.text.isEmpty && isButtonClicked
                        ? Colors.red
                        : Colors.black, //Color.fromARGB(255, 6, 117, 34),
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                controller: _myController2,
              ),
            ),
            SizedBox(height: (width / 30.4285714286)),
            SizedBox(
              width: (width / 1.15081081081),
              height: (width / 8),
              child: TextField(
                // obscureText: visibility,
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
                      color:
                          _myController3.text.isEmpty &&
                              isButtonClicked &&
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
                          _myController3.text.isEmpty &&
                              isButtonClicked &&
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
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _myController3.text.isEmpty &&
                              isButtonClicked &&
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
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _myController3.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : Color.fromARGB(
                              41,
                              217,
                              217,
                              217,
                            ), //Color.fromARGB(255, 6, 117, 34),
                    ),
                  ),
                  filled: true,
                  fillColor: Color.fromARGB(41, 217, 217, 217),
                  enabled: true,
                  labelText:
                      _myController3.text.isEmpty &&
                          isButtonClicked &&
                          isButtonClicked
                      ? 'Create Password (Required)'
                      : 'Create Password',
                  labelStyle: GoogleFonts.poppins(
                    color:
                        _myController3.text.isEmpty &&
                            isButtonClicked &&
                            isButtonClicked
                        ? Colors.red
                        : Colors.black, //Color.fromARGB(255, 6, 117, 34),
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  hintText: 'Create a password',
                  hintStyle: GoogleFonts.poppins(
                    color:
                        _myController3.text.isEmpty &&
                            isButtonClicked &&
                            isButtonClicked
                        ? Colors.red
                        : Colors.black, //Color.fromARGB(255, 6, 117, 34),
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  // suffixIcon: GestureDetector(
                  //   child: Icon(
                  //     visibility ? Icons.visibility : Icons.visibility_off,
                  //     size: width / 20.55,
                  //   ),
                  //   onTap: () {
                  //     setState(() {
                  //       visibility = !visibility;
                  //     });
                  //   },
                  // ),
                  // suffixIconColor: Colors.black,
                ),
                controller: _myController3,
              ),
            ),
            SizedBox(height: (width / 30.4285714286)),
            SizedBox(
              width: (width / 1.15081081081),
              height: (width / 9),
              child: TextField(
                // obscureText: visibility1,
                style: GoogleFonts.poppins(
                  fontSize: width / 36,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(204, 0, 0, 0),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(41, 217, 217, 217),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _myController4.text.isEmpty &&
                              isButtonClicked &&
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
                          _myController4.text.isEmpty &&
                              isButtonClicked &&
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
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _myController4.text.isEmpty &&
                              isButtonClicked &&
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
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _myController4.text.isEmpty &&
                              isButtonClicked &&
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
                  enabled: true,
                  labelText:
                      _myController4.text.isEmpty &&
                          isButtonClicked &&
                          isButtonClicked
                      ? 'Confirm Password (Required)'
                      : 'Confirm Password',
                  labelStyle: GoogleFonts.poppins(
                    color:
                        _myController4.text.isEmpty &&
                            isButtonClicked &&
                            isButtonClicked
                        ? Colors.red
                        : Colors.black, //Color.fromARGB(255, 6, 117, 34),
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  hintText: 'Confirm your password',
                  hintStyle: GoogleFonts.poppins(
                    color:
                        _myController4.text.isEmpty &&
                            isButtonClicked &&
                            isButtonClicked
                        ? Colors.red
                        : Colors.black, //Color.fromARGB(255, 6, 117, 34),
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  // suffixIcon: GestureDetector(
                  //   child: Icon(
                  //     visibility1 ? Icons.visibility : Icons.visibility_off,
                  //     size: width / 20.55,
                  //   ),
                  //   onTap: () {
                  //     setState(() {
                  //       visibility1 = !visibility1;
                  //     });
                  //   },
                  // ),
                  // suffixIconColor: Colors.black,
                ),
                controller: _myController4,
              ),
            ),

            // SizedBox(height: (width / 10.4285714286)),
            SizedBox(height: (width / 30.4285714286)),
            SizedBox(
              width: (width / 1.15081081081),
              height: (width / 9),
              child: TextField(
                // obscureText: visibility1,
                style: GoogleFonts.poppins(
                  fontSize: width / 36,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(204, 0, 0, 0),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(41, 217, 217, 217),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _myController5.text.isEmpty &&
                              isButtonClicked &&
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
                          _myController4.text.isEmpty &&
                              isButtonClicked &&
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
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _myController4.text.isEmpty &&
                              isButtonClicked &&
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
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _myController4.text.isEmpty &&
                              isButtonClicked &&
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
                  enabled: true,
                  labelText:
                      _myController4.text.isEmpty &&
                          isButtonClicked &&
                          isButtonClicked
                      ? 'Confirm Password (Required)'
                      : 'Confirm Password',
                  labelStyle: GoogleFonts.poppins(
                    color:
                        _myController4.text.isEmpty &&
                            isButtonClicked &&
                            isButtonClicked
                        ? Colors.red
                        : Colors.black, //Color.fromARGB(255, 6, 117, 34),
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  hintText: 'Confirm your password',
                  hintStyle: GoogleFonts.poppins(
                    color:
                        _myController4.text.isEmpty &&
                            isButtonClicked &&
                            isButtonClicked
                        ? Colors.red
                        : Colors.black, //Color.fromARGB(255, 6, 117, 34),
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  // suffixIcon: GestureDetector(
                  //   child: Icon(
                  //     visibility1 ? Icons.visibility : Icons.visibility_off,
                  //     size: width / 20.55,
                  //   ),
                  //   onTap: () {
                  //     setState(() {
                  //       visibility1 = !visibility1;
                  //     });
                  //   },
                  // ),
                  // suffixIconColor: Colors.black,
                ),
                controller: _myController4,
              ),
            ),

            SizedBox(height: (width / 10.4285714286)),
          ],
        ),
      ),
    );
  }
}
