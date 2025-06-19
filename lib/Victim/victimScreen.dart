// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

class victimScreen extends StatefulWidget {
  const victimScreen({super.key});

  @override
  State<victimScreen> createState() => _victimScreenState();
}

class _victimScreenState extends State<victimScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Center(child: Text("Victim"))],
      ),
      backgroundColor: const Color(0xFFF2EDF6),
    );
  }
}
