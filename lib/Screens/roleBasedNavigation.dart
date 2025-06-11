// ignore_for_file: file_names, use_build_context_synchronously
import 'package:crisis_survivor/Admin/adminPage.dart';
import 'package:crisis_survivor/Donee/doneecreen.dart';
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
    if (widget.role == 'donor') {
      return DonorScreen();
    } else if (widget.role == 'donee') {
      return DoneeScreen();
    } else if (widget.role == 'admin') {
      return Admin();
    } else {
      return Roles(); // fallback if something went wrong
    }
  }
}
