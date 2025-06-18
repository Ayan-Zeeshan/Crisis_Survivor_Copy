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
    Future.microtask(() => AuthGuard.startMonitoring(context));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    navigate(role) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => role),
      );
    }

    if (widget.role == 'donor') {
      navigate(DonorScreen());
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DonorScreen()));
    } else if (widget.role == 'victim') {
      navigate(victimScreen());
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => victimScreen()));
    } else if (widget.role == 'admin') {
      navigate(Admin());
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Admin()));
    } else if (widget.role == 'consultant') {
      navigate(ConsultantScreen());
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Admin()));
    } else {
      navigate(Roles()); // fallback if something went wrong
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2EDF6),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              height: height / 4,
              width: width / 2,
              child: CircularProgressIndicator(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
