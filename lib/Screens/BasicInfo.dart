// ignore_for_file: unused_element, file_names, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class BasicInfo extends StatefulWidget {
  final String role;
  const BasicInfo({super.key, required this.role});

  @override
  State<BasicInfo> createState() => _BasicInfoState();
}

class _BasicInfoState extends State<BasicInfo> {
  Future<void> _Permissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.mediaLibrary,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);
    if (!allGranted) {
      print('Permissions not granted');
      bool isPermanentlyDenied = statuses.values.any(
        (status) => status.isPermanentlyDenied,
      );
      if (isPermanentlyDenied) {
        print('Permissions permanently denied');
        openAppSettings();
      }
    } else {
      print('Permissions granted!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFFF2EDF6), body: Column(children: [],));
  }
}
