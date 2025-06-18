// // ignore_for_file: file_names, use_build_context_synchronously, avoid_print

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:crisis_survivor/Screens/Roles.dart';

// class ForgotPasswordDialog extends StatefulWidget {
//   const ForgotPasswordDialog({super.key});

//   @override
//   State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
// }

// class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _codeController = TextEditingController();
//   bool emailSent = false;
//   bool canResend = false;
//   String? error;
//   int resendSeconds = 60;
//   Timer? _resendTimer;

//   void _startResendTimer() {
//     resendSeconds = 60;
//     canResend = false;
//     _resendTimer?.cancel();
//     _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
//       setState(() {
//         resendSeconds--;
//         if (resendSeconds <= 0) {
//           canResend = true;
//           timer.cancel();
//         }
//       });
//     });
//   }

//   // Future<void> sendResetCode(String email) async {
//   //   try {
//   //     // Step 1: Check if email exists
//   //     final checkUrl =
//   //         "https://email-checker-n18g22p8z-ayan-m-zeeshans-projects-ca51e2ff.vercel.app/api/check-email?email=$email";
//   //     final checkResponse = await http.get(Uri.parse(checkUrl));
//   //     final contentType = checkResponse.headers['content-type'];

//   //     if (checkResponse.statusCode != 200 ||
//   //         contentType == null ||
//   //         !contentType.contains('application/json')) {
//   //       setState(() => error = "Unexpected response from server.");
//   //       return;
//   //     }

//   //     final checkJson = jsonDecode(checkResponse.body);
//   //     if (checkJson['exists'] != true) {
//   //       setState(() => error = "No account found for this email.");
//   //       return;
//   //     }

//   //     // Step 2: Send code
//   //     final response = await http.post(
//   //       Uri.parse("https://127.0.0.1:8000/verify-code/"),
//   //       headers: {'Content-Type': 'application/json'},
//   //       body: jsonEncode({'email': email}),
//   //     );

//   //     final json = jsonDecode(response.body);
//   //     if (response.statusCode == 200 && json['status'] == "sent") {
//   //       setState(() {
//   //         emailSent = true;
//   //         error = null;
//   //         _startResendTimer();
//   //       });
//   //     } else {
//   //       setState(() => error = json['error'] ?? "Failed to send code.");
//   //     }
//   //   } catch (e) {
//   //     print("Error sending reset code: $e");
//   //     setState(() => error = "Something went wrong. Try again.");
//   //   }
//   // }

//   //   Future<void> verifyCodeAndLogin() async {
//   //     final email = _emailController.text.trim();
//   //     final code = _codeController.text.trim();

//   //    try {
//   //   // final response = await http.post(apiUrl, body: jsonEncode({'email': email}), headers: {'Content-Type': 'application/json'});
//   // final response = await http.post(
//   //   Uri.parse("https://your-django-api.com/verify-code/"),
//   //   body: jsonEncode({'email': email, 'code': code}),
//   //   headers: {'Content-Type': 'application/json'},
//   // );

//   //   if (response.statusCode == 200) {
//   //     final data = jsonDecode(response.body);
//   //     if (data['exists'] == true) {
//   //       // proceed
//   //     } else {
//   //       setState(() => error = "Email not found.");
//   //     }
//   //   } else {
//   //     setState(() => error = "Server error. Try again.");
//   //   }
//   // } catch (e) {
//   //   setState(() => error = "Network or response error.");
//   // }

//   //   }
//   Future<void> verifyCodeAndLogin() async {
//     final email = _emailController.text.trim();
//     final code = _codeController.text.trim();

//     try {
//       final response = await http.post(
//         Uri.parse("https://127.0.0.1:8000/verify-code/"),
//         body: jsonEncode({'email': email, 'code': code}),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['valid'] == true) {
//           Navigator.of(context).pop(); // Close dialog
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => Roles()), // or login screen
//           );
//         } else {
//           setState(() => error = "Invalid or expired code.");
//         }
//       } else {
//         setState(() => error = "Server error. Try again.");
//       }
//     } catch (e) {
//       setState(() => error = "Network or response error.");
//     }
//   }

//   @override
//   void dispose() {
//     _resendTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text(emailSent ? "Enter Code" : "Forgot Password"),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (!emailSent)
//             TextField(
//               controller: _emailController,
//               decoration: InputDecoration(
//                 labelText: "Enter your email",
//                 errorText: error,
//               ),
//             ),
//           if (emailSent)
//             TextField(
//               controller: _codeController,
//               decoration: InputDecoration(
//                 labelText: "Enter verification code",
//                 errorText: error,
//               ),
//             ),
//         ],
//       ),
//       actions: [
//         if (!emailSent)
//           TextButton(
//             onPressed: () => sendResetCode(_emailController.text.trim()),
//             child: Text("Send Code"),
//           ),
//         if (emailSent)
//           TextButton(
//             onPressed: canResend
//                 ? () => sendResetCode(_emailController.text.trim())
//                 : null,
//             child: Text("Resend Code (${resendSeconds}s)"),
//           ),
//         if (emailSent)
//           TextButton(onPressed: verifyCodeAndLogin, child: Text("Verify")),
//       ],
//     );
//   }
// }
// ignore_for_file: file_names, use_build_context_synchronously, avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crisis_survivor/Screens/Roles.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  bool emailSent = false;
  bool canResend = false;
  String? error;
  int resendSeconds = 60;
  Timer? _resendTimer;

  void _startResendTimer() {
    resendSeconds = 60;
    canResend = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        resendSeconds--;
        if (resendSeconds <= 0) {
          canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> sendResetCode(String email) async {
    setState(() => error = null);
    try {
      // Check if the email exists
      final checkResponse = await http.post(
        Uri.parse(
          "https://authbackend-production-d43e.up.railway.app/api/check-email/",
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final checkJson = jsonDecode(checkResponse.body);
      if (checkResponse.statusCode != 200 || checkJson['exists'] != true) {
        setState(() => error = "No account found for this email.");
        return;
      } else {
        // Send the reset code
        final resetResponse = await http.post(
          Uri.parse(
            "https://authbackend-production-d43e.up.railway.app/api/send-code/",
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        );

        final resetJson = jsonDecode(resetResponse.body);
        if (resetResponse.statusCode == 200 && resetJson['success'] == true) {
          setState(() {
            emailSent = true;
            error = null;
            _startResendTimer();
          });
        } else {
          setState(() => error = resetJson['error'] ?? "Failed to send code.");
        }
      }
    } catch (e) {
      setState(() => error = "Network error. Try again.");
    }
  }

  Future<void> verifyCodeAndLogin() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    setState(() => error = null);

    try {
      final response = await http.post(
        Uri.parse(
          "https://authbackend-production-d43e.up.railway.app/api/verify-code/",
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        Navigator.of(context).pop();
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (context) => Roles()));
      } else {
        setState(() => error = data['error'] ?? "Invalid or expired code.");
      }
    } catch (e) {
      setState(() => error = "Something went wrong. Try again.");
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(emailSent ? "Enter Verification Code" : "Forgot Password"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!emailSent)
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Enter your email",
                errorText: error,
              ),
            ),
          if (emailSent)
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: "Enter verification code",
                errorText: error,
              ),
            ),
        ],
      ),
      actions: [
        if (!emailSent)
          TextButton(
            onPressed: () => sendResetCode(_emailController.text.trim()),
            child: const Text("Send Code"),
          ),
        if (emailSent)
          TextButton(
            onPressed: canResend
                ? () => sendResetCode(_emailController.text.trim())
                : null,
            child: Text("Resend Code (${resendSeconds}s)"),
          ),
        if (emailSent)
          TextButton(
            onPressed: verifyCodeAndLogin,
            child: const Text("Verify"),
          ),
      ],
    );
  }
}
