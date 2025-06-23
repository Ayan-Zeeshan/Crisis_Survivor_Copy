// ignore_for_file: use_build_context_synchronously

import 'package:crisis_survivor/auth_guard.dart';
import 'package:flutter/material.dart';

class DonorScreen extends StatefulWidget {
  const DonorScreen({super.key});

  @override
  State<DonorScreen> createState() => _DonorScreenState();
}

class _DonorScreenState extends State<DonorScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => AuthGuard.startMonitoring(context));
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: height * 0.23,
            child: Stack(
              children: [
                Positioned(
                  top: width / -22,
                  left: width / -4.15,
                  child: Container(
                    width: height / 4.3,
                    height: width / 2.3,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(120, 125, 105, 108),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: width / -4.15,
                  left: width / -90,
                  child: Container(
                    width: width / 2.3,
                    height: height / 4.3,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(145, 109, 91, 91),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text("Donor"),
        ],
      ),
      backgroundColor: const Color(0xFFF2EDF6),
    );
  }
}
