// ignore_for_file: use_build_context_synchronously

import 'package:crisis_survivor/auth_guard.dart';
import 'package:flutter/material.dart';

class ConsultantScreen extends StatefulWidget {
  const ConsultantScreen({super.key});

  @override
  State<ConsultantScreen> createState() => _ConsultantScreenState();
}

class _ConsultantScreenState extends State<ConsultantScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => AuthGuard.startMonitoring(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: []),
      backgroundColor: const Color(0xFFF2EDF6),
    );
  }
}
