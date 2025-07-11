// // ignore_for_file: file_names, use_build_context_synchronously, unused_import, constant_pattern_never_matches_value_type
// import 'package:crisis_survivor/Admin/adminPage.dart';
// import 'package:crisis_survivor/Consultant/consultantscreen.dart';
// import 'package:crisis_survivor/Consultant/BasicInfo.dart';
// import 'package:crisis_survivor/Victim/victimScreen.dart';
// import 'package:crisis_survivor/Donor/donorscreen.dart';
// import 'package:crisis_survivor/Screens/Roles.dart';
// import 'package:crisis_survivor/auth_guard.dart';
// import 'package:flutter/material.dart';

// class RoleBasedHome extends StatefulWidget {
//   final String role;
//   const RoleBasedHome({super.key, required this.role});

//   @override
//   State<RoleBasedHome> createState() => _RoleBasedHomeState();
// }

// class _RoleBasedHomeState extends State<RoleBasedHome> {
//   @override
//   void initState() {
//     super.initState();

//     // Start auth monitoring
//     Future.microtask(() => AuthGuard.startMonitoring(context));

//     // Navigate based on role
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       navigateToRoleScreen(widget.role);
//     });
//   }

//   void navigateToRoleScreen(String role) {
//     Widget destination;

//     switch (role.toLowerCase()) {
//       case '':
//         destination = Roles();
//       case null:
//         destination = Roles();
//       case 'donor':
//         destination = BasicInfo(role: role);
//         break;
//       case 'victim':
//         destination = BasicInfo(role: role);
//         break;
//       case 'admin':
//         destination = Admin();
//         break;
//       case 'consultant':
//         destination = BasicInfo(role: role);
//         break;
//       default:
//         destination = Roles(); // fallback
//     }

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => destination),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;

// ignore_for_file: file_names

//     return Scaffold(
//       backgroundColor: const Color(0xFFF2EDF6),
//       body: Center(
//         child: SizedBox(
//           height: height / 4,
//           width: width / 2,
//           child: const CircularProgressIndicator(color: Colors.blue),
//         ),
//       ),
//     );
//   }
// }
