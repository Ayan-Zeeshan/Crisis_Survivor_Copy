// ignore_for_file: camel_case_types, unused_local_variable, avoid_print, prefer_typing_uninitialized_variables, unnecessary_set_literal, no_leading_underscores_for_local_identifiers, unused_element, use_build_context_synchronously, file_names, sized_box_for_whitespace, deprecated_member_use, await_only_futures, strict_top_level_inference
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crisis_survivor/Screens/PrivacyPolicy.dart';
import 'package:crisis_survivor/Screens/Roles.dart';
import 'package:crisis_survivor/Screens/TermsandConditions.dart';
import 'package:crisis_survivor/Screens/Login.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Sign_Up extends StatefulWidget {
  const Sign_Up({super.key});

  @override
  State<Sign_Up> createState() => _Sign_UpState();
}

class _Sign_UpState extends State<Sign_Up> {
  final TextEditingController _myController = TextEditingController();
  final TextEditingController _myController2 = TextEditingController();
  final TextEditingController _myController3 = TextEditingController();
  final TextEditingController _myController4 = TextEditingController();

  bool isButtonClicked = false;
  bool visibility = true;
  bool visibility1 = true;
  Color bordercolor1 = Colors.white;
  Color bordercolor2 = Colors.white;
  Color bordercolor3 = Colors.white;
  Color bordercolor4 = Colors.white;
  Color color1 = Color.fromARGB(204, 0, 0, 0);
  Color color2 = Color.fromARGB(204, 0, 0, 0);
  Color color3 = Color.fromARGB(204, 0, 0, 0);
  Color color4 = Color.fromARGB(204, 0, 0, 0);
  User? user;
  bool emailExists = false;
  String? error;

  Future checkEmail(String email) async {
    setState(() => error = null);
    try {
      // Check if the email exists
      final checkResponse = await http.post(
        Uri.parse(
          "https://authbackend-production-ed7f.up.railway.app/api/check-email/",
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final checkJson = jsonDecode(checkResponse.body);
      if (checkResponse.statusCode != 200 || checkJson['exists'] != true) {
        setState(() => error = "No account found for this email.");
        return;
      } else {
        setState(() {
          emailExists = true;
        });
      }
    } catch (e) {
      setState(() => error = "Network error. Try again.");
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    setState(() {
      user = null;
    });
  }

  Future<void> checkIfAccountExistsAndRedirect(
    BuildContext context,
    String email,
  ) async {
    try {
      await checkEmail(email);

      if (emailExists) {
        // An account with this email exists, redirect to Login()
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account already exists. Redirecting to login...'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Login(
              prefillEmail: _myController2.text,
              prefillPassword: _myController3.text,
            ),
          ),
        );
      } else {
        // No account exists, continue with signup
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No account found. You can sign up.')),
        );
        signUpWithFirebase();
        sendDatatoFireStore();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error checking account: $e')));
    }
  }

  void signUpWithFirebase() {
    try {
      final credentials = FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _myController2.text,
            password: _myController4.text,
          )
          .then((value) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account Created Successfully!'),
                duration: Duration(seconds: 2),
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Roles()),
            );
          });
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Sign-up failed: ";
      switch (e.code) {
        case 'weak-password':
          errorMessage += "The password provided is too weak.";
          break;
        case 'email-already-in-use':
          errorMessage += "Email is already in use.";
          break;
        case 'invalid-email':
          errorMessage += "The email address is not valid.";
          break;
        case 'operation-not-allowed':
          errorMessage += "Account creation is not allowed.";
          break;
        case 'user-disabled':
          errorMessage += "The user account has been disabled.";
          break;
        case 'missing-email':
          errorMessage += "Email address is missing.";
          break;
        case 'missing-password':
          errorMessage += "Password is missing.";
          break;
        case 'too-many-requests':
          errorMessage +=
              "Too many unsuccessful attempts. Please try again later.";
          break;
        default:
          errorMessage += "An error occurred (${e.code}).";
          break;
      }
      print(errorMessage);
    } catch (e) {
      print("exception caught: $e");
    }
  }

  sendDatatoFireStore() async {
    final _db = FirebaseFirestore.instance;

    final dataList = {
      "username": _myController.text,
      "email": _myController2.text,
      "role": null,
      "time": DateTime.now().toString(),
    };

    SharedPreferences _pref = await SharedPreferences.getInstance();
    await _db.collection("users").add(dataList).whenComplete(() async {
      final Map<String, dynamic> userDetails = {
        'username': dataList['username'],
        'email': dataList['email'],
        'role': null,
        'time': DateTime.now().toString(),
      };
      await _pref.setString('Data', json.encode(userDetails));
    });
    setState() {}
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        final String? username = user.displayName;
        final String? email = user.email;

        final userData = {
          'username': username,
          'email': email,
          'role': null,
          'time': DateTime.now().toString(),
        };

        print(userData);

        final SharedPreferences _prefs = await SharedPreferences.getInstance();
        await _prefs.setString('Data', json.encode(userData));

        // Save to Firestore if needed
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userData);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Roles()),
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Signed in as $username')));
      }
    } catch (e) {
      if (kDebugMode) print('Error signing in with Google: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google Sign-In failed')));
    }
  }

  // Future<void> signInWithGoogleAndCacheUserData() async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     if (googleUser == null) return; // User canceled the sign-in

  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;

  //     final OAuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     final userCredential = await FirebaseAuth.instance.signInWithCredential(
  //       credential,
  //     );

  //     final User? signedInUser = userCredential.user;

  //     if (signedInUser != null) {
  //       final String? username = signedInUser.displayName;
  //       final String? email = signedInUser.email;

  //       final userData = {
  //         'username': username,
  //         'email': email,
  //         'role': null,
  //         'time': DateTime.now().toString(),
  //       };

  //       final SharedPreferences prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('Data', json.encode(userData));
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Google Sign-In or caching failed: $e');
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // SizedBox(
            //   height: (width / 9.22857142857),
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Center(
            //       child: SizedBox(
            //         height: width / 2.1,
            //         child: Stack(
            //           children: [
            //             Positioned(
            //               left: 1.0,
            //               top: 2.0,
            //               child: Icon(
            //                 Icons.circle,
            //                 color: Colors.black,
            //                 size: (width / 1.955),
            //               ),
            //             ),
            //             Positioned(
            //               right: 1.0,
            //               top: 2.0,
            //               child: Icon(
            //                 Icons.circle,
            //                 color: Colors.black,
            //                 size: (width / 1.955),
            //               ),
            //             ),
            //             CircleAvatar(
            //               maxRadius: (width / 4.1577777),
            //               backgroundColor: Colors.white,
            //               backgroundImage:
            //                   const AssetImage("assets/forestech.png"),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
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

            Stack(
              children: [
                Positioned(
                  left: width / 6.5,
                  child: Text(
                    "SIGN UP",
                    style: GoogleFonts.poppins(
                      fontSize: (width / 21.5),
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                //   ],
                // ),
                //SizedBox(
                //height: (width / 45.4285714286),
                //),
                SizedBox(
                  height: (width / 1.8285714286),
                  child: Image.asset("assets/CS1.png"),
                ),
              ],
            ),
            SizedBox(height: (width / 30.4285714286)),
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
                  fillColor: Colors.white, // Keep background transparent
                  labelText: _myController.text.isEmpty && isButtonClicked
                      ? 'Full Name (Required)'
                      : 'Full Name',
                  labelStyle: GoogleFonts.poppins(
                    color: _myController.text.isEmpty && isButtonClicked
                        ? Colors.red
                        : color1,
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  hintText: 'Enter your full name',
                  hintStyle: GoogleFonts.poppins(
                    color: _myController.text.isEmpty && isButtonClicked
                        ? Colors.red
                        : color1,
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
                          : bordercolor1, //Color.fromARGB(255, 6, 117, 34),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _myController.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : bordercolor1, //Color.fromARGB(255, 6, 117, 34),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _myController.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : bordercolor1, //Color.fromARGB(255, 6, 117, 34),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _myController.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : bordercolor1, //Color.fromARGB(255, 6, 117, 34),
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
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _myController2.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : bordercolor2, //Color.fromARGB(255, 6, 117, 34),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _myController2.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : bordercolor2, //Color.fromARGB(255, 6, 117, 34),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _myController2.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : bordercolor2, //Color.fromARGB(255, 6, 117, 34),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _myController2.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : bordercolor2, //Color.fromARGB(255, 6, 117, 34),
                    ),
                  ),
                  enabled: true,
                  labelText: _myController2.text.isEmpty && isButtonClicked
                      ? 'Create Email Address (Required)'
                      : 'Create Email Address',
                  labelStyle: GoogleFonts.poppins(
                    color: _myController2.text.isEmpty && isButtonClicked
                        ? Colors.red
                        : color2, //Color.fromARGB(255, 6, 117, 34),
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  hintText: 'Enter your email address',
                  hintStyle: GoogleFonts.poppins(
                    color: _myController2.text.isEmpty && isButtonClicked
                        ? Colors.red
                        : color2, //Color.fromARGB(255, 6, 117, 34),
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
                obscureText: visibility,
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
                          _myController3.text.isEmpty && isButtonClicked ||
                              _myController4.text != _myController3.text &&
                                  isButtonClicked
                          ? Colors.red
                          : bordercolor3, //Color.fromARGB(255, 6, 117, 34),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _myController3.text.isEmpty && isButtonClicked ||
                              _myController4.text != _myController3.text &&
                                  isButtonClicked
                          ? Colors.red
                          : bordercolor3, //Color.fromARGB(255, 6, 117, 34),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _myController3.text.isEmpty && isButtonClicked ||
                              _myController4.text != _myController3.text &&
                                  isButtonClicked
                          ? Colors.red
                          : bordercolor3, //Color.fromARGB(255, 6, 117, 34),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color: _myController3.text.isEmpty && isButtonClicked
                          ? Colors.red
                          : bordercolor3, //Color.fromARGB(255, 6, 117, 34),
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabled: true,
                  labelText:
                      _myController3.text.isEmpty && isButtonClicked ||
                          _myController4.text != _myController3.text &&
                              isButtonClicked
                      ? 'Create Password (Required)'
                      : 'Create Password',
                  labelStyle: GoogleFonts.poppins(
                    color:
                        _myController3.text.isEmpty && isButtonClicked ||
                            _myController4.text != _myController3.text &&
                                isButtonClicked
                        ? Colors.red
                        : color3, //Color.fromARGB(255, 6, 117, 34),
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  hintText: 'Create a password',
                  hintStyle: GoogleFonts.poppins(
                    color:
                        _myController3.text.isEmpty && isButtonClicked ||
                            _myController4.text != _myController3.text &&
                                isButtonClicked
                        ? Colors.red
                        : color3, //Color.fromARGB(255, 6, 117, 34),
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  suffixIcon: GestureDetector(
                    child: Icon(
                      visibility ? Icons.visibility : Icons.visibility_off,
                      size: width / 20.55,
                    ),
                    onTap: () {
                      setState(() {
                        visibility = !visibility;
                      });
                    },
                  ),
                  suffixIconColor: Colors.black,
                ),
                controller: _myController3,
              ),
            ),
            SizedBox(height: (width / 30.4285714286)),
            SizedBox(
              width: (width / 1.15081081081),
              height: (width / 9),
              child: TextField(
                obscureText: visibility1,
                style: GoogleFonts.poppins(
                  fontSize: width / 36,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(204, 0, 0, 0),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _myController4.text.isEmpty && isButtonClicked ||
                              _myController4.text != _myController3.text &&
                                  isButtonClicked
                          ? Colors.red
                          : bordercolor4, //Color.fromARGB(255, 6, 117, 34),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _myController4.text.isEmpty && isButtonClicked ||
                              _myController4.text != _myController3.text &&
                                  isButtonClicked
                          ? Colors.red
                          : bordercolor4, //Color.fromARGB(255, 6, 117, 34),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _myController4.text.isEmpty && isButtonClicked ||
                              _myController4.text != _myController3.text &&
                                  isButtonClicked
                          ? Colors.red
                          : bordercolor4, //Color.fromARGB(255, 6, 117, 34),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(width / 1.9),
                    ),
                    borderSide: BorderSide(
                      color:
                          _myController4.text.isEmpty && isButtonClicked ||
                              _myController4.text != _myController3.text &&
                                  isButtonClicked
                          ? Colors.red
                          : bordercolor4, //Color.fromARGB(255, 6, 117, 34),
                    ),
                  ),
                  enabled: true,
                  labelText:
                      _myController4.text.isEmpty && isButtonClicked ||
                          _myController4.text != _myController3.text &&
                              isButtonClicked
                      ? 'Confirm Password (Required)'
                      : 'Confirm Password',
                  labelStyle: GoogleFonts.poppins(
                    color:
                        _myController4.text.isEmpty && isButtonClicked ||
                            _myController4.text != _myController3.text &&
                                isButtonClicked
                        ? Colors.red
                        : color4, //Color.fromARGB(255, 6, 117, 34),
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  hintText: 'Confirm your password',
                  hintStyle: GoogleFonts.poppins(
                    color:
                        _myController4.text.isEmpty && isButtonClicked ||
                            _myController4.text != _myController3.text &&
                                isButtonClicked
                        ? Colors.red
                        : color4, //Color.fromARGB(255, 6, 117, 34),
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  suffixIcon: GestureDetector(
                    child: Icon(
                      visibility1 ? Icons.visibility : Icons.visibility_off,
                      size: width / 20.55,
                    ),
                    onTap: () {
                      setState(() {
                        visibility1 = !visibility1;
                      });
                    },
                  ),
                  suffixIconColor: Colors.black,
                ),
                controller: _myController4,
              ),
            ),

            SizedBox(height: (width / 10.4285714286)),
            //             Center(
            //               child: Container(
            //                 height: width / 10,
            //                 width: width / 1.2,
            //                 child: Text(
            //                   """By signing up you’re agree to our Terms & Condition
            // and Privacy Policy.""",
            //                   style: GoogleFonts.poppins(
            //                     fontSize: width / 33,
            //                     fontWeight: FontWeight.w500,
            //                   ),
            //                   textAlign: TextAlign.justify,
            //                 ),
            //               ),
            //             ),
            Container(
              width: width / 1.2,
              height: width / 8,
              child: RichText(
                text: TextSpan(
                  text: "By signing up you agree to our ",
                  style: GoogleFonts.poppins(
                    color: Color.fromARGB(204, 0, 0, 0),
                    fontSize: width / 30,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: 'Terms & Condition',
                      style: GoogleFonts.poppins(
                        color: Colors.blue,
                        fontSize: width / 30,
                        fontWeight: FontWeight.w500,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TermsAndConditionsPage(), // Your terms screen
                            ),
                          );
                        },
                    ),
                    TextSpan(
                      text: ''' 
                      and ''',
                      style: TextStyle(
                        color: Color.fromARGB(204, 0, 0, 0),
                        fontSize: width / 30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: 'Privacy Policy.',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: width / 30,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PrivacyPolicyPage(), // Your privacy screen
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: (width / 30.4285714286)),
            Padding(
              padding: EdgeInsets.symmetric(vertical: width / 100.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isButtonClicked = true;
                    if (_myController.text.isEmpty ||
                        _myController2.text.isEmpty ||
                        _myController3.text.isEmpty ||
                        _myController4.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fields Empty!'),
                          duration: Duration(seconds: 2),
                        ),
                      );

                      color1 = Colors.red;
                      color2 = Colors.red;
                      color3 = Colors.red;
                      color4 = Colors.red;
                      bordercolor1 = Colors.red;
                      bordercolor2 = Colors.red;
                      bordercolor3 = Colors.red;
                      bordercolor4 = Colors.red;
                    } else if (_myController3.text.length < 8) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Passwords should be minimum 8 characters long!',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      color1 = Color.fromARGB(204, 0, 0, 0);
                      color2 = Color.fromARGB(204, 0, 0, 0);
                      color3 = Colors.red;
                      color4 = Colors.red;
                      bordercolor1 = Colors.white;
                      bordercolor2 = Colors.white;
                      bordercolor3 = Colors.red;
                      bordercolor4 = Colors.red;
                    } else if (_myController3.text != _myController4.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Passwords do not Match!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      color1 = Color.fromARGB(204, 0, 0, 0);
                      color2 = Color.fromARGB(204, 0, 0, 0);
                      color3 = Colors.red;
                      color4 = Colors.red;
                      bordercolor1 = Colors.white;
                      bordercolor2 = Colors.white;
                      bordercolor3 = Colors.red;
                      bordercolor4 = Colors.red;
                    } else if (!_myController2.text.endsWith("@gmail.com")) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Emails should only end with @gmail.com',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      color1 = Color.fromARGB(204, 0, 0, 0);
                      color2 = Colors.red;
                      color3 = Color.fromARGB(204, 0, 0, 0);
                      color4 = Color.fromARGB(204, 0, 0, 0);
                      bordercolor1 = Colors.white;
                      bordercolor2 = Colors.red;
                      bordercolor3 = Colors.white;
                      bordercolor4 = Colors.white;
                    } else if (_myController4.text.isNotEmpty &&
                        _myController2.text.isNotEmpty &&
                        _myController3.text.isNotEmpty &&
                        _myController4.text == _myController3.text &&
                        isButtonClicked &&
                        _myController2.text.endsWith("@gmail.com") &&
                        _myController3.text.length >= 8) {
                      bordercolor1 = Colors.white;
                      bordercolor2 = Colors.white;
                      bordercolor3 = Colors.white;
                      bordercolor4 = Colors.white;
                      color1 = Color.fromARGB(204, 0, 0, 0);
                      color2 = Color.fromARGB(204, 0, 0, 0);
                      color3 = Color.fromARGB(204, 0, 0, 0);
                      color4 = Color.fromARGB(204, 0, 0, 0);
                      checkIfAccountExistsAndRedirect(
                        context,
                        _myController2.text,
                      );
                      // signUpWithFirebase();
                      // sendDatatoFireStore();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(width / 1.12, width / 7.5),
                  backgroundColor: Color.fromARGB(194, 86, 61, 61),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(width / 50)),
                    side: const BorderSide(
                      color: Color.fromARGB(194, 86, 61, 61),
                    ),
                  ),
                  // shadowColor: Color.fromARGB(194, 86, 61, 61),
                  // surfaceTintColor: Color.fromARGB(194, 86, 61, 61),
                ),
                child: Text(
                  "Continue",
                  style: GoogleFonts.poppins(
                    color: const Color.fromARGB(253, 255, 255, 255),
                    fontSize: (width / 25.55),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: width / 28),

            SizedBox(
              width: width / 1.2,
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Color.fromARGB(204, 0, 0, 0),
                      thickness: width / 250,
                      endIndent: width / 69,
                    ),
                  ),
                  Center(
                    child: Text(
                      "OR",
                      style: GoogleFonts.poppins(
                        color: Color.fromARGB(204, 0, 0, 0),
                        fontWeight: FontWeight.bold,
                        fontSize: width / 22,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Color.fromARGB(204, 0, 0, 0),
                      thickness: width / 250,
                      indent: width / 69,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: width / 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: user == null
                      ? ElevatedButton(
                          onPressed: signInWithGoogle,
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(width / 1.12, width / 7.5),
                            backgroundColor: Color.fromARGB(253, 230, 230, 230),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(width / 50),
                              ),
                              side: const BorderSide(
                                color: Color.fromARGB(253, 230, 230, 230),
                              ),
                            ),
                            // shadowColor: Color.fromARGB(194, 86, 61, 61),
                            // surfaceTintColor: Color.fromARGB(194, 86, 61, 61),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/Google.png",
                                height: width / 15,
                              ),
                              SizedBox(width: width / 25),
                              Text(
                                'Continue with Google',
                                style: GoogleFonts.poppins(
                                  fontSize: width / 25,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(253, 0, 0, 0),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                user!.photoURL ?? '',
                              ),
                              radius: 40,
                            ),
                            SizedBox(height: 10),
                            Text('Hello, ${user!.displayName ?? 'User'}'),
                            SizedBox(height: 10),
                            Text('Email: ${user!.email}'),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: signOut,
                              child: Text('Sign Out'),
                            ),
                          ],
                        ),
                ),
              ],
            ),
            SizedBox(height: width / 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Join us Before?",
                  style: GoogleFonts.poppins(
                    color: const Color.fromARGB(253, 0, 0, 0),
                    fontSize: (width / 25.5714285714),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: width / 65),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  child: Text(
                    "Login",
                    style: GoogleFonts.poppins(
                      fontSize: (width / 25.5714285714),
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(253, 80, 194, 201),
                    ),
                  ),
                ),
              ],
            ),

            // SizedBox(height: width / 45),
            SizedBox(height: width / 45),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            // SizedBox(
            //   width: (width / 41.1),
            // ),
            //     Text(
            //       "\"",
            //       style: GoogleFonts.pacifico(
            //         fontSize: (width / 22.55),
            //         fontWeight: FontWeight.w500,
            //         fontStyle: FontStyle.italic,
            //         color: const Color.fromARGB(255, 22, 116, 22),
            //       ),
            //     ),
            //     Text(
            //       "Empowering",
            //       style: GoogleFonts.pacifico(
            //         color: const Color.fromARGB(255, 22, 116, 22),
            //         fontSize: (width / 22.55),
            //         fontStyle: FontStyle.italic,
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //     // Text(
            //     //   " The",
            //     //   style: GoogleFonts.pacifico(
            //     //     color: const Color.fromARGB(255, 121, 57, 5),
            //     //     fontSize: (width / 20.55),
            //     //     fontStyle: FontStyle.italic,
            //     //     fontWeight: FontWeight.w500,
            //     //   ),
            //     // ),
            //     Text(
            //       " Nature's",
            //       style: GoogleFonts.pacifico(
            //         color: const Color.fromARGB(255, 121, 57, 5),
            //         fontSize: (width / 22.55),
            //         fontStyle: FontStyle.italic,
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //   ],
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     // SizedBox(
            //     //   width: (width / 10.27500),
            //     // ),
            //     Text(
            //       " Future",
            //       style: GoogleFonts.pacifico(
            //         color: const Color.fromARGB(255, 22, 116, 22),
            //         fontSize: (width / 22.55),
            //         fontStyle: FontStyle.italic,
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //     Text(
            //       "\"",
            //       style: GoogleFonts.pacifico(
            //         color: const Color.fromARGB(255, 22, 116, 22),
            //         fontSize: (width / 22.55),
            //         fontStyle: FontStyle.italic,
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
      backgroundColor: Color(0xFFF2EDF6),
    );
  }
}
