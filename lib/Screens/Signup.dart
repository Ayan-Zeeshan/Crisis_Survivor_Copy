// ignore_for_file: camel_case_types, unused_local_variable, avoid_print, prefer_typing_uninitialized_variables, unnecessary_set_literal, no_leading_underscores_for_local_identifiers, unused_element, use_build_context_synchronously, file_names, sized_box_for_whitespace, deprecated_member_use, await_only_futures, strict_top_level_inference
import 'dart:convert';
import 'dart:developer';
import 'package:crisis_survivor/Screens/Roles.dart';
import 'package:crisis_survivor/Widget/customtextfield.dart';
import 'package:crisis_survivor/Widget/signup_footer.dart';
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
  final _myController = TextEditingController();
  final _myController2 = TextEditingController();
  final _myController3 = TextEditingController();
  final _myController4 = TextEditingController();

  bool isButtonClicked = false;
  bool visibility = true;
  bool visibility1 = true;

  Color bordercolor1 = Colors.white;
  Color bordercolor2 = Colors.white;
  Color bordercolor3 = Colors.white;
  Color bordercolor4 = Colors.white;

  Color color1 = const Color.fromARGB(204, 0, 0, 0);
  Color color2 = const Color.fromARGB(204, 0, 0, 0);
  Color color3 = const Color.fromARGB(204, 0, 0, 0);
  Color color4 = const Color.fromARGB(204, 0, 0, 0);

  User? user;
  bool emailExists = false;
  String? error;

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> storeFirebaseToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final idToken = await user.getIdToken(true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("idToken", idToken!);
      log("✅ ID token cached successfully.");
    } catch (e) {
      log("❌ Failed to store ID token: $e");
    }
  }

  void _setErrorColors({
    bool all = false,
    bool emailOnly = false,
    bool passOnly = false,
  }) {
    setState(() {
      if (all || emailOnly) {
        color2 = bordercolor2 = Colors.red;
      }
      if (all || passOnly) {
        color3 = bordercolor3 = color4 = bordercolor4 = Colors.red;
      }
      if (all) {
        color1 = bordercolor1 = Colors.red;
      }
    });
  }

  void _resetColors() {
    setState(() {
      color1 = color2 = color3 = color4 = const Color.fromARGB(204, 0, 0, 0);
      bordercolor1 = bordercolor2 = bordercolor3 = bordercolor4 = Colors.white;
    });
  }

  Future<void> checkEmail(String email) async {
    setState(() => error = null);
    try {
      final res = await http.post(
        Uri.parse(
          "https://authbackend-production-d43e.up.railway.app/api/check-email/",
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode != 200 || data['exists'] != true) {
        error = "No account found for this email.";
      } else {
        emailExists = true;
      }
    } catch (e) {
      error = "Network error. Try again.";
    }
    setState(() {});
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    setState(() => user = null);
  }

  Future<void> checkIfAccountExistsAndRedirect(
    BuildContext context,
    String email,
  ) async {
    signUpWithFirebase();
  }

  void signUpWithFirebase() async {
    try {
      final email = _myController2.text;
      final password = _myController4.text;

      final value = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account Created Successfully!'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Roles()),
      );

      // Send data and store token *after* navigation — do it silently
      Future.wait([sendDatatoFireStore(), storeFirebaseToken()]);
    } on FirebaseAuthException catch (e) {
      String msg = "Sign-up failed: ";
      switch (e.code) {
        case 'weak-password':
          msg += "The password provided is too weak.";
          break;
        case 'email-already-in-use':
          msg += "Email is already in use.";
          break;
        case 'invalid-email':
          msg += "The email address is not valid.";
          break;
        default:
          msg += "An error occurred (${e.code}).";
          break;
      }
      _showSnack(msg);
    } catch (e) {
      _showSnack("Unexpected error: $e");
    }
  }

  Future<void> sendDatatoFireStore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final fullData = {
      "username": _myController.text,
      "email": _myController2.text,
      "role": null,
      "time": DateTime.now().toString(),
      "uid": user.uid,
    };

    final cacheData = Map.of(fullData)..remove("uid");

    final prefs = await SharedPreferences.getInstance();
    await http.post(
      Uri.parse(
        "https://authbackend-production-d43e.up.railway.app/api/send-data/",
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(fullData),
    );
    await prefs.setString('Data', jsonEncode(cacheData));
    setState(() {});
  }

  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user == null) {
        _showSnack("Google Sign-In failed.");
        return;
      }

      // Navigate immediately
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Roles()),
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in as ${user.displayName}')),
      );

      // Run backend work silently after navigation
      final fullData = {
        "username": user.displayName,
        "email": user.email,
        "role": null,
        "time": DateTime.now().toString(),
        "uid": user.uid,
      };
      final cacheData = Map.of(fullData)..remove("uid");

      final prefs = await SharedPreferences.getInstance();

      Future.wait([
        http.post(
          Uri.parse(
            "https://authbackend-production-d43e.up.railway.app/api/send-data/",
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(fullData),
        ),
        prefs.setString('Data', jsonEncode(cacheData)),
        storeFirebaseToken(),
      ]);
    } catch (e) {
      if (kDebugMode) print('Error signing in with Google: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google Sign-In failed')));
    }
  }

  // Future<void> signInWithGoogle() async {
  //   try {
  //     final googleUser = await GoogleSignIn().signIn();
  //     if (googleUser == null) return;

  //     final googleAuth = await googleUser.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     final userCredential = await FirebaseAuth.instance.signInWithCredential(
  //       credential,
  //     );
  //     await storeFirebaseToken();
  //     final user = userCredential.user;
  //     if (user != null) {
  //       final fullData = {
  //         "username": user.displayName,
  //         "email": user.email,
  //         "role": null,
  //         "time": DateTime.now().toString(),
  //         "uid": user.uid,
  //       };
  //       final cacheData = Map.of(fullData)..remove("uid");
  //       final prefs = await SharedPreferences.getInstance();
  //       await http.post(
  //         Uri.parse(
  //           "https://authbackend-production-d43e.up.railway.app/api/send-data/",
  //         ),
  //         headers: {'Content-Type': 'application/json'},
  //         body: jsonEncode(fullData),
  //       );
  //       await prefs.setString('Data', jsonEncode(cacheData));
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (_) => const Roles()),
  //       );
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Signed in as ${user.displayName}')),
  //       );
  //     }
  //   } catch (e) {
  //     if (kDebugMode) print('Error signing in with Google: $e');
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Google Sign-In failed')));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFF2EDF6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 180,
              child: Stack(
                children: [
                  Positioned(
                    top: width / -22,
                    left: width / -4.15,
                    child: Container(
                      width: 200,
                      height: 180,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(120, 125, 105, 108),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: width / -4.15,
                    left: width / -90,
                    child: Container(
                      width: 180,
                      height: 200,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(145, 109, 91, 91),
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
                SizedBox(
                  height: (width / 1.8285714286),
                  child: Image.asset("assets/CS1.png"),
                ),
              ],
            ),
            SizedBox(height: (width / 30.4285714286)),
            CustomTextField(
              controller: _myController,
              width: width,
              height: width / 8,
              label: 'Full Name',
              hint: 'Enter your full name',
              labelColor: color1,
              borderColor: bordercolor1,
              isButtonClicked: isButtonClicked,
            ),
            SizedBox(height: width / 30.4285714286),
            CustomTextField(
              controller: _myController2,
              width: width,
              height: width / 8,
              label: 'Create Email Address',
              hint: 'Enter your email address',
              labelColor: color2,
              borderColor: bordercolor2,
              isButtonClicked: isButtonClicked,
            ),
            SizedBox(height: width / 30.4285714286),
            CustomTextField(
              controller: _myController3,
              width: width,
              height: width / 8,
              label: 'Create Password',
              hint: 'Create a password',
              labelColor: color3,
              borderColor: bordercolor3,
              isButtonClicked: isButtonClicked,
              isPassword: true,
              isObscure: visibility,
              isVisible: visibility,
              toggleVisibility: () => setState(() => visibility = !visibility),
            ),
            SizedBox(height: width / 30.4285714286),
            CustomTextField(
              controller: _myController4,
              width: width,
              height: width / 9,
              label: 'Confirm Password',
              hint: 'Confirm your password',
              labelColor: color4,
              borderColor: bordercolor4,
              isButtonClicked: isButtonClicked,
              isPassword: true,
              isObscure: visibility1,
              isVisible: visibility1,
              toggleVisibility: () =>
                  setState(() => visibility1 = !visibility1),
            ),
            SizedBox(height: width / 10.4285714286),
            buildSignupFooterSection(
              width: width,
              isButtonClicked: isButtonClicked,
              nameController: _myController,
              emailController: _myController2,
              passController: _myController3,
              confirmPassController: _myController4,
              bordercolor1: bordercolor1,
              bordercolor2: bordercolor2,
              bordercolor3: bordercolor3,
              bordercolor4: bordercolor4,
              color1: color1,
              color2: color2,
              color3: color3,
              color4: color4,
              context: context,
              signInWithGoogle: signInWithGoogle,
              signOut: signOut,
              user: user,
              showSnack: _showSnack,
              setErrorColors: _setErrorColors,
              resetColors: _resetColors,
              checkIfAccountExistsAndRedirect: checkIfAccountExistsAndRedirect,
            ),
          ],
        ),
      ),
    );
  }
}
