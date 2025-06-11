// ignore_for_file: avoid_print, camel_case_types, no_leading_underscores_for_local_identifiers, avoid_unnecessary_containers, use_build_context_synchronously, unused_import
import 'dart:async';
import 'dart:convert';
// import 'dart:developer';
import 'package:crisis_survivor/Admin/adminPage.dart';
import 'package:crisis_survivor/Consultant/consultantscreen.dart';
import 'package:crisis_survivor/Donee/doneecreen.dart';
import 'package:crisis_survivor/Donor/donorscreen.dart';
import 'package:crisis_survivor/Screens/Roles.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class Splash_Screen extends StatefulWidget {
  const Splash_Screen({super.key});

  @override
  State<Splash_Screen> createState() => _Splash_ScreenState();
}

class _Splash_ScreenState extends State<Splash_Screen> {
  late VideoPlayerController _controller;
  bool user = true;
  // getPrefs() async {
  //   SharedPreferences _pref = await SharedPreferences.getInstance();
  //   try {
  //     dynamic getCacheData = json.decode(_pref.getString("Data") ?? "");
  //     Map<String, dynamic> cache = getCacheData as Map<String, dynamic>;
  //     setState(() {
  //       if (cache['role'] == 'user') {
  //         log("User");
  //         user = true;
  //       } else if (cache['role'] == 'Admin') {
  //         log("Admin");
  //         user = false;
  //       }
  //     });
  //   } catch (e) {
  //     log("$e");
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/splash.webm')
      ..initialize().then((value) {
        setState(() {});
      })
      ..setVolume(0.0);
    _playVideo();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playVideo() async {
    _controller.play();
    await Future.delayed(const Duration(seconds: 6));
    SharedPreferences _pref = await SharedPreferences.getInstance();
    String? cachedData = _pref.getString('Data');
    setState(() {
      if (cachedData != null && cachedData.isNotEmpty) {
        Map<String, dynamic> userDetails = json.decode(cachedData);

        if (userDetails['role'] == null || userDetails['role'] == "") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => //user ? const ConsultantScreen() :
                      const Roles(),
            ),
          );
        } else if ((userDetails['role'].toString()).toLowerCase() == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => //user ? const ConsultantScreen() :
                      // const ConsultantScreen(),
                      const Admin(),
            ),
          );
        } else if ((userDetails['role'].toString()).toLowerCase() == "donee") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => //user ? const ConsultantScreen() :
                      const DoneeScreen(),
            ),
          );
        } else if ((userDetails['role'].toString()).toLowerCase() == "donor") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => //user ? const ConsultantScreen() :
                      const DonorScreen(),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : Container(),
          ),
        ],
      ),
      backgroundColor: Color(0xFFF2EDF6),
    );
  }
}
