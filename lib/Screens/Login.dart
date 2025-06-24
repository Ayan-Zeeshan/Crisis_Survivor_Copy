// ignore_for_file: unused_local_variable, non_constant_identifier_names, avoid_print, no_leading_underscores_for_local_identifiers, use_build_context_synchronously, await_only_futures, unused_import, unnecessary_null_comparison, deprecated_member_use, file_names

import 'dart:convert';
import 'dart:developer';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crisis_survivor/Admin/adminPage.dart';
import 'package:crisis_survivor/Consultant/BasicInfo.dart';
import 'package:crisis_survivor/Consultant/consultantscreen.dart';
import 'package:crisis_survivor/Donor/BasicInfo.dart';
import 'package:crisis_survivor/Victim/BasicInfo.dart';
import 'package:crisis_survivor/Victim/victimScreen.dart';
import 'package:crisis_survivor/Donor/donorscreen.dart';
import 'package:crisis_survivor/Screens/ForgotPassword.dart';
import 'package:crisis_survivor/Screens/Roles.dart';
import 'package:crisis_survivor/Screens/Signup.dart';
import 'package:crisis_survivor/Screens/roleBasedNavigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  final String? prefillEmail;
  final String? prefillPassword;

  const Login({super.key, this.prefillEmail, this.prefillPassword});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
    if (widget.prefillEmail != null && widget.prefillPassword != null) {
      retrieveLoginCredentials(widget.prefillEmail!, widget.prefillPassword!);
    }
  }

  Future<void> storeFirebaseToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final idToken = await user.getIdToken(true); // Force refresh for security
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("idToken", "$idToken");
      log("✅ ID token cached successfully.");
    } catch (e) {
      log("❌ Failed to store ID token: $e");
    }
  }

  final TextEditingController _myController = TextEditingController();
  final TextEditingController _myController1 = TextEditingController();
  bool visibility = true;
  bool isButtonClicked = false;
  Map? userData;
  Map? responseData;
  User? user;

  bool emailExistsOnGoogle = false;
  String? error;
  void retrieveLoginCredentials([String? email, String? password]) {
    if (email != null &&
        password != null &&
        email.isNotEmpty &&
        password.isNotEmpty) {
      setState(() {
        _myController.text = email;
        _myController1.text = password;
      });
    } else {
      return;
    }
  }

  Future<void> fetchAndCacheUserData(User? user) async {
    if (user == null) return;

    try {
      final response = await http.post(
        Uri.parse(
          "https://authbackend-production-d43e.up.railway.app/api/receive-data/",
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"uid": user.uid}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final userData = responseData['data'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('Data', json.encode(userData));
      } else {
        print("❌ Failed to fetch user data from backend");
      }
    } catch (e) {
      print("❌ Exception during fetch: $e");
    }
  }

  Future checkEmail(String email, [String? provider]) async {
    setState(() => error = null);
    try {
      final checkResponse = await http.post(
        Uri.parse(
          "https://authbackend-production-d43e.up.railway.app/api/check-email/",
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          if (provider != null) 'provider': provider,
        }),
      );

      final checkJson = jsonDecode(checkResponse.body);

      if (checkResponse.statusCode != 200 || checkJson['exists'] != true) {
        setState(() => error = "No account found for this email.");
        return;
      } else {
        if (checkJson['provider'] == provider) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please sign in using Google'),
              duration: Duration(seconds: 3),
            ),
          );
          setState(() {
            emailExistsOnGoogle = true;
          });
          await signInWithGoogle();
          return;
        }
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

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // user cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Google Sign-In failed')));
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in as ${user.displayName}')),
      );

      _redirectBasedOnRole(user);
      Future.wait([storeFirebaseToken(), fetchAndCacheUserData(user)]);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Google Sign-In failed: $e")));
    }
  }

  void loginWithFirebase() async {
    try {
      final email = _myController.text.trim();
      final password = _myController1.text.trim();

      final signin = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Successful!'),
          duration: Duration(seconds: 2),
        ),
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _redirectBasedOnRole(user);
        Future.wait([storeFirebaseToken(), fetchAndCacheUserData(user)]);
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Login failed")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Unexpected error: $e")));
    }
  }

  void _redirectBasedOnRole(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('Data');
    if (raw == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => const Roles()),
      );
      return;
    }

    final data = json.decode(raw);
    final role = data['role']?.toString().toLowerCase();
    final uid = user.uid;

    try {
      final response = await http.post(
        Uri.parse(
          "https://authbackend-production-d43e.up.railway.app/api/receive-info/",
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"uid": uid, "role": role}),
      );

      if (response.statusCode == 200) {
        if (role == 'victim') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => victimScreen()),
          );
        } else if (role == 'consultant') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ConsultantScreen()),
          );
        } else if (role == 'donor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => DonorScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (c) => const Roles()),
          );
        }
        return;
      }
    } catch (e) {
      // silent fail, continue below
    }

    Widget target;
    if (role == 'victim') {
      target = VictimBasicInfo();
    } else if (role == 'consultant') {
      target = ConsultantBasicInfo();
    } else if (role == 'donor') {
      target = DonorBasicInfo();
    } else {
      target = Roles();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => target),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    Color color1 = Color.fromARGB(204, 0, 0, 0);
    Color color2 = Color.fromARGB(204, 0, 0, 0);
    Color bordercolor1 = Colors.white;
    Color bordercolor2 = Colors.white;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              // width: width / 2.25,
              width: double.infinity,
              height: height / 4.1, // just enough to cover the top background
              child: Stack(
                children: [
                  // Darker big circle (Ellipse 2)
                  Positioned(
                    top: -20,
                    left: -100,
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
                    top: -100,
                    left: -5,
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

            Center(
              child: Text(
                "SIGN IN",
                style: GoogleFonts.poppins(
                  fontSize: (width / 19.5),
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: (width / 69.55)),
            Center(
              child: CircleAvatar(
                maxRadius: (width / 4.1577777),
                backgroundColor: const Color(0xFFF2EDF6),

                backgroundImage: const AssetImage("assets/Profilepic2.png"),
              ),
            ),
            SizedBox(height: (width / 20.55)),
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
                  enabled: true,
                  labelText: _myController.text.isEmpty && isButtonClicked
                      ? 'Enter Email Address (Required)'
                      : 'Enter Email Address',
                  labelStyle: GoogleFonts.poppins(
                    color: _myController.text.isEmpty && isButtonClicked
                        ? Colors.red
                        : color1,
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                  hintText: 'Enter your email address',
                  hintStyle: GoogleFonts.poppins(
                    color: _myController.text.isEmpty && isButtonClicked
                        ? Colors.red
                        : color1,
                    fontSize: width / 36,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                controller: _myController,
              ),
            ),
            SizedBox(height: (width / 30.4285714286)),
            Stack(
              children: [
                SizedBox(
                  width: (width / 1.15081081081),
                  height: (width / 5),
                  child: TextField(
                    style: GoogleFonts.poppins(
                      fontSize: width / 36,
                      fontWeight: FontWeight.w400,
                      color: Color.fromARGB(204, 0, 0, 0),
                    ),
                    obscureText: visibility,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
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
                      enabled: true,
                      labelText: _myController1.text.isEmpty && isButtonClicked
                          ? 'Enter Password (Required)'
                          : 'Enter Password',
                      labelStyle: GoogleFonts.poppins(
                        color: _myController1.text.isEmpty && isButtonClicked
                            ? Colors.red
                            : color2,
                        fontSize: width / 36,
                        fontWeight: FontWeight.w400,
                      ),
                      hintText: 'Enter your password',
                      hintStyle: GoogleFonts.poppins(
                        color: _myController1.text.isEmpty && isButtonClicked
                            ? Colors.red
                            : color2,
                        fontSize: width / 36,
                        fontWeight: FontWeight.w400,
                      ),
                      suffixIcon: GestureDetector(
                        child: Icon(
                          visibility ? Icons.visibility_off : Icons.visibility,
                        ),
                        onTap: () {
                          setState(() {
                            visibility = !visibility;
                          });
                        },
                      ),
                      suffixIconColor: Colors.black,
                    ),
                    controller: _myController1,
                  ),
                ),
                Positioned(
                  top: width / 7,
                  right: width / 25,
                  child: GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => ForgotPasswordDialog(),
                    ),
                    child: Text(
                      "Forgot Password?",
                      style: GoogleFonts.poppins(
                        fontSize: width / 36,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(253, 80, 194, 201),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // SizedBox(height: (width / 20.55)),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isButtonClicked = true;
                  if (_myController.text.isNotEmpty &&
                      _myController1.text.isNotEmpty) {
                    color1 = Color.fromARGB(204, 0, 0, 0);
                    color2 = Color.fromARGB(204, 0, 0, 0);
                    bordercolor1 = Colors.white;
                    bordercolor2 = Colors.white;
                    loginWithFirebase();
                  } else if (_myController.text.isEmpty &&
                      _myController1.text.isEmpty) {
                    color1 = Colors.red;
                    color2 = Colors.red;
                    bordercolor1 = Colors.red;
                    bordercolor2 = Colors.red;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fields Empty!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
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
                "Sign in",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: (width / 25.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: (width / 20.55)),
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
                                'Sign in with Google',
                                style: GoogleFonts.poppins(
                                  fontSize: width / 25,
                                  fontWeight: FontWeight.w600,
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
            SizedBox(height: height / 25),
            RichText(
              text: TextSpan(
                text: "New Here?",
                style: GoogleFonts.poppins(
                  color: Color.fromARGB(204, 0, 0, 0),
                  fontSize: width / 28,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: ' Register Now',
                    style: GoogleFonts.poppins(
                      color: Color.fromARGB(253, 80, 194, 201),
                      fontWeight: FontWeight.w600,
                      fontSize: width / 28,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Sign_Up(), // Your privacy screen
                          ),
                        );
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFFF2EDF6),
    );
  }
}
