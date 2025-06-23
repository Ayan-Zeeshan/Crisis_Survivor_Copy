import 'package:crisis_survivor/Screens/Login.dart';
import 'package:crisis_survivor/Screens/PrivacyPolicy.dart';
import 'package:crisis_survivor/Screens/TermsandConditions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildSignupFooterSection({
  required double width,
  required bool isButtonClicked,
  required TextEditingController nameController,
  required TextEditingController emailController,
  required TextEditingController passController,
  required TextEditingController confirmPassController,
  required Color bordercolor1,
  required Color bordercolor2,
  required Color bordercolor3,
  required Color bordercolor4,
  required Color color1,
  required Color color2,
  required Color color3,
  required Color color4,
  required BuildContext context,
  required VoidCallback signInWithGoogle,
  required VoidCallback signOut,
  required dynamic user, // Firebase user
  required void Function(String msg) showSnack,
  required void Function({bool all, bool passOnly, bool emailOnly})
  setErrorColors,
  required VoidCallback resetColors,
  required void Function(BuildContext ctx, String email)
  checkIfAccountExistsAndRedirect,
}) {
  return Column(
    children: [
      SizedBox(
        width: width / 1.2,
        height: width / 8,
        child: RichText(
          text: TextSpan(
            text: "By signing up you agree to our ",
            style: GoogleFonts.poppins(
              color: const Color.fromARGB(204, 0, 0, 0),
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
                        builder: (_) => TermsAndConditionsPage(),
                      ),
                    );
                  },
              ),
              TextSpan(
                text: " and ",
                style: GoogleFonts.poppins(
                  color: const Color.fromARGB(204, 0, 0, 0),
                  fontSize: width / 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: 'Privacy Policy.',
                style: GoogleFonts.poppins(
                  color: Colors.blue,
                  fontSize: width / 30,
                  fontWeight: FontWeight.w500,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PrivacyPolicyPage()),
                    );
                  },
              ),
            ],
          ),
        ),
      ),
      SizedBox(height: width / 30.4),
      Padding(
        padding: EdgeInsets.symmetric(vertical: width / 100),
        child: ElevatedButton(
          onPressed: () {
            final name = nameController.text.trim();
            final email = emailController.text.trim();
            final pass = passController.text;
            final confirmPass = confirmPassController.text;

            if ([name, email, pass, confirmPass].any((e) => e.isEmpty)) {
              showSnack("All fields are required!");
              setErrorColors(all: true);
              return;
            }

            if (pass.length < 8 ||
                !RegExp(r'[0-9]').hasMatch(pass) ||
                !RegExp(r'[a-zA-Z]').hasMatch(pass)) {
              showSnack(
                "Password must be 8+ chars, include letters & numbers.",
              );
              setErrorColors(passOnly: true);
              return;
            }

            if (pass != confirmPass) {
              showSnack("Passwords do not match!");
              setErrorColors(passOnly: true);
              return;
            }

            if (!RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$").hasMatch(email)) {
              showSnack("Enter a valid email (e.g. name@example.com)");
              setErrorColors(emailOnly: true);
              return;
            }

            resetColors();
            checkIfAccountExistsAndRedirect(context, email);
          },
          style: ElevatedButton.styleFrom(
            fixedSize: Size(width / 1.12, width / 7.5),
            backgroundColor: const Color.fromARGB(194, 86, 61, 61),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(width / 50),
              side: const BorderSide(color: Color.fromARGB(194, 86, 61, 61)),
            ),
          ),
          child: Text(
            "Continue",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: width / 25.55,
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
                color: const Color.fromARGB(204, 0, 0, 0),
                thickness: width / 250,
                endIndent: width / 69,
              ),
            ),
            Text(
              "OR",
              style: GoogleFonts.poppins(
                color: const Color.fromARGB(204, 0, 0, 0),
                fontWeight: FontWeight.bold,
                fontSize: width / 22,
              ),
            ),
            Expanded(
              child: Divider(
                color: const Color.fromARGB(204, 0, 0, 0),
                thickness: width / 250,
                indent: width / 69,
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: width / 25),
      user == null
          ? ElevatedButton(
              onPressed: signInWithGoogle,
              style: ElevatedButton.styleFrom(
                fixedSize: Size(width / 1.12, width / 7.5),
                backgroundColor: const Color.fromARGB(253, 230, 230, 230),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(width / 50),
                  side: const BorderSide(
                    color: Color.fromARGB(253, 230, 230, 230),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/Google.png", height: width / 15),
                  SizedBox(width: width / 25),
                  Text(
                    'Continue with Google',
                    style: GoogleFonts.poppins(
                      fontSize: width / 25,
                      fontWeight: FontWeight.w500,
                      color: const Color.fromARGB(253, 0, 0, 0),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(user!.photoURL ?? ''),
                  radius: 40,
                ),
                const SizedBox(height: 10),
                Text('Hello, ${user!.displayName ?? 'User'}'),
                const SizedBox(height: 10),
                Text('Email: ${user!.email}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: signOut,
                  child: const Text('Sign Out'),
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
              color: Colors.black,
              fontSize: width / 25.57,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: width / 65),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Login()),
              );
            },
            child: Text(
              "Login",
              style: GoogleFonts.poppins(
                fontSize: width / 25.57,
                fontWeight: FontWeight.w500,
                color: const Color.fromARGB(253, 80, 194, 201),
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: width / 45),
    ],
  );
}
