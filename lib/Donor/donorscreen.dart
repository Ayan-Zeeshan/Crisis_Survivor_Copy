import 'package:flutter/material.dart';

class DonorScreen extends StatefulWidget {
  const DonorScreen({super.key});

  @override
  State<DonorScreen> createState() => _DonorScreenState();
}

class _DonorScreenState extends State<DonorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [Text("Donor")]),
      backgroundColor: const Color(0xFFF2EDF6),
    );
  }
}
