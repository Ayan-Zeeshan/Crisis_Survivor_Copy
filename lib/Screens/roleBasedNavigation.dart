// // ignore_for_file: file_names, use_build_context_synchronously
// import 'package:crisis_survivor/Admin/adminPage.dart';
// import 'package:crisis_survivor/Consultant/consultantscreen.dart';
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
//     Future.microtask(() => AuthGuard.startMonitoring(context));

//     Future.delayed(Duration.zero, () {
//       Widget roleWidget;
//       if (widget.role == 'donor') {
//         roleWidget = DonorScreen();
//       } else if (widget.role == 'victim') {
//         roleWidget = victimScreen();
//       } else if (widget.role == 'admin') {
//         roleWidget = Admin();
//       } else if (widget.role == 'consultant') {
//         roleWidget = ConsultantScreen();
//       } else {
//         roleWidget = Roles(); // fallback
//       }

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => roleWidget),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF2EDF6),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Center(
//             child: SizedBox(
//               height: height / 4,
//               width: width / 2,
//               child: const CircularProgressIndicator(color: Colors.blue),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// ignore_for_file: file_names, use_build_context_synchronously
import 'package:crisis_survivor/Admin/adminPage.dart';
import 'package:crisis_survivor/Consultant/consultantscreen.dart';
import 'package:crisis_survivor/Victim/victimScreen.dart';
import 'package:crisis_survivor/Donor/donorscreen.dart';
import 'package:crisis_survivor/Screens/Roles.dart';
import 'package:crisis_survivor/auth_guard.dart';
import 'package:flutter/material.dart';

class RoleBasedHome extends StatefulWidget {
  final String role;
  const RoleBasedHome({super.key, required this.role});

  @override
  State<RoleBasedHome> createState() => _RoleBasedHomeState();
}

class _RoleBasedHomeState extends State<RoleBasedHome> {
  @override
  void initState() {
    super.initState();

    // Start auth monitoring
    Future.microtask(() => AuthGuard.startMonitoring(context));

    // Navigate based on role
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigateToRoleScreen(widget.role);
    });
  }

  void navigateToRoleScreen(String role) {
    Widget destination;

    switch (role.toLowerCase()) {
      case 'donor':
        destination = DonorScreen();
        break;
      case 'victim':
        destination = victimScreen();
        break;
      case 'admin':
        destination = Admin();
        break;
      case 'consultant':
        destination = ConsultantScreen();
        break;
      default:
        destination = Roles(); // fallback
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF2EDF6),
      body: Center(
        child: SizedBox(
          height: height / 4,
          width: width / 2,
          child: const CircularProgressIndicator(color: Colors.blue),
        ),
      ),
    );
  }
}
