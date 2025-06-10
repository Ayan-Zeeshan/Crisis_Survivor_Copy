// ignore_for_file: unused_local_variable, non_constant_identifier_names, avoid_print, no_leading_underscores_for_local_identifiers, use_build_context_synchronously, await_only_futures, unused_import, unnecessary_null_comparison, deprecated_member_use

import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crisis_survivor/Consultant/consultantscreen.dart';
import 'package:crisis_survivor/Donee/doneecreen.dart';
import 'package:crisis_survivor/Donor/donorscreen.dart';
import 'package:crisis_survivor/Screens/ForgotPassword.dart';
import 'package:crisis_survivor/Screens/Roles.dart';
import 'package:crisis_survivor/Screens/Signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _myController = TextEditingController();
  final TextEditingController _myController1 = TextEditingController();
  bool visibility = true;
  bool isButtonClicked = false;
  // bool user = true;
  User? user;
  // bool emailExists = false;
  // String? error;

  // Future checkEmail(String email) async {
  //   setState(() => error = null);
  //   try {
  //     // Check if the email exists
  //     final checkResponse = await http.post(
  //       Uri.parse(
  //         "https://authbackend-production-ed7f.up.railway.app/api/check-email/",
  //       ),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'email': email}),
  //     );

  //     final checkJson = jsonDecode(checkResponse.body);
  //     if (checkResponse.statusCode != 200 || checkJson['exists'] != true) {
  //       setState(() => error = "No account found for this email.");
  //       return;
  //     } else {
  //       setState(() {
  //         emailExists = true;
  //       });
  //     }
  //   } catch (e) {
  //     setState(() => error = "Network error. Try again.");
  //   }
  // }
  bool emailExists = false;
  String? error;

  Future checkEmail(String email, {String? provider}) async {
    setState(() => error = null);
    try {
      final checkResponse = await http.post(
        Uri.parse(
          "https://authbackend-production-ed7f.up.railway.app/api/check-email/",
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
        setState(() {
          emailExists = true;
        });

        if (checkJson['provider'] == 'google.com') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please sign in using Google'),
              duration: Duration(seconds: 3),
            ),
          );
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

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User? user = userCredential.user;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signed in with Google'),
          duration: Duration(seconds: 2),
        ),
      );

      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user?.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final userDetails = {
          'username': userData['username'],
          'email': userData['email'],
          'role': userData['role'],
          'time': DateTime.now().toString(),
        };

        SharedPreferences _Pref = await SharedPreferences.getInstance();
        await _Pref.setString('Data', json.encode(userDetails));

        setState(() {
          // user = userData['role'] == 'User';
        });
        if (userDetails['role'] == "" || userDetails['role'] == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Roles()),
          );
        } else if (userDetails['role'] == "Consultant") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ConsultantScreen()),
          );
        } else if (userDetails['role'] == "Donor") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DonorScreen()),
          );
        } else if (userDetails['role'] == "Donee") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DoneeScreen()),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Google Sign-In failed: $e")));
    }
  }

  void loginWithFirebase() async {
    SharedPreferences _Pref = await SharedPreferences.getInstance();
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .where('email', isEqualTo: _myController.text)
        .limit(1)
        .get();
    dynamic cache = _Pref.getString('Data');

    if (cache != null && cache.isNotEmpty) {
      final Map<String, dynamic> cacheMap = json.decode(cache);
      if (cacheMap.isNotEmpty) {
        log(cacheMap.toString());
      } else {
        log("Cache is empty!");
      }
    } else {
      log("Cache is empty!");
    }

    try {
      List<String> signInMethods = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(_myController.text);

      if (signInMethods.contains('google.com')) {
        // If user signed up with Google, prompt Google Sign-In instead
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in using Google'),
            duration: Duration(seconds: 3),
          ),
        );
        await signInWithGoogle(); // call the reusable method below
        return;
      }

      final Signin = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _myController.text,
        password: _myController1.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Successful!'),
          duration: Duration(seconds: 2),
        ),
      );

      if (snapshot.docs.isNotEmpty) {
        final DocumentSnapshot data = snapshot.docs.first;
        final Map userDetails = {
          'username': data['username'],
          'email': data['email'],
          'role': data['role'],
          'time': DateTime.now().toString(),
        };
        setState(() {
          // if (data['role'] == 'User') {
          //   user = true;
          // } else if (data['role'] == 'Admin') {
          //   user = false;
          // }
        });
        log('$userDetails');
        _Pref.setString('Data', json.encode(userDetails)).then((value) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Roles()),
          );
        });
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Login failed")));
    }
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
                  // Positioned(
                  //   top: width / 4.15, //100,
                  //   left: width / 2.6000000001,
                  //   //160,
                  //   child: Text(
                  //     "SIGN IN",
                  //     style: GoogleFonts.poppins(
                  //       fontSize: (width / 19.5),
                  //       color: Colors.black,
                  //       fontWeight: FontWeight.w700,
                  //     ),
                  //   ),
                  // ),
                  // // SizedBox(height: (width / 69.55)),)
                  // Positioned(
                  //   top: width / 3.3,
                  //   // 110,
                  //   left: width / 4.2,
                  //   child: CircleAvatar(
                  //     maxRadius: (width / 4.1577777),
                  //     backgroundColor: const Color(0xFFF2EDF6),

                  //     backgroundImage: const AssetImage(
                  //       "assets/Profilepic2.png",
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),

            // SizedBox(height: (height / 350.22857142857)),
            // Center(
            //   child:
            // SizedBox(
            //   height: width / 2.1,
            //   child: Stack(
            //     children: [
            //       Positioned(
            //         left: 1.0,
            //         top: 2.0,
            //         child: Icon(
            //           Icons.circle,
            //           color: Colors.black54,
            //           size: (width / 1.955),
            //         ),
            //       ),
            //       Positioned(
            //         right: 1.0,
            //         top: 2.0,
            //         child: Icon(
            //           Icons.circle,
            //           color: Colors.black45,
            //           size: (width / 1.955),
            //         ),
            //       ),

            //     ],
            //   ),
            // ),
            // ),
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
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(
                    //     content: Text('Coming Soon!'),
                    //     duration: Duration(seconds: 3),
                    //   ),
                    // ),
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
                      _myController1.text.isNotEmpty &&
                      _myController.text.endsWith("@gmail.com")) {
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
            // SizedBox(height: (width / 20.55)),
            // RichText(
            //   children: Text(
            //     "New here ",
            //     style: GoogleFonts.poppins(
            //       color: Colors.black,
            //       fontSize: (width / 30.5714285714),
            //       fontWeight: FontWeight.w400,
            //     ),
            //   ),
            // ),
            // Text(
            //   " ?",
            //   style: GoogleFonts.poppins(
            //     color: Colors.black,
            //     fontSize: (width / 30.5714285714),
            //     fontWeight: FontWeight.w400,
            //   ),
            // ),
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
            // SizedBox(height: (width / 20.55)),
            // TextButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => const Sign_Up()),
            //     );
            //   },
            //   child: Text(
            //     "Sign up",
            //     style: GoogleFonts.montserrat(
            //       fontSize: (width / 21.5),
            //       fontWeight: FontWeight.w500,
            //       color: Colors.black,
            //     ),
            //   ),
            // ),
            // SizedBox(height: (width / 20.55)),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
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
