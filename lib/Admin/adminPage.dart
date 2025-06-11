// ignore_for_file: file_names

import 'package:crisis_survivor/Admin/usersList.dart';
import 'package:flutter/material.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Users()),
            ),
            child: Text("User List"),
          ),
        ],
      ),
      backgroundColor: Color(0xFFF2EDF6),
    );
  }
}
