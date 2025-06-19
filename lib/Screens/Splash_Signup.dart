// ignore_for_file: avoid_print, camel_case_types, no_leading_underscores_for_local_identifiers, avoid_unnecessary_containers, use_build_context_synchronously, depend_on_referenced_packages, file_names
// import 'dart:async';
import 'package:crisis_survivor/Screens/Signup.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashSignUp extends StatefulWidget {
  const SplashSignUp({super.key});

  @override
  State<SplashSignUp> createState() => _SplashSignUpState();
}

class _SplashSignUpState extends State<SplashSignUp> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/splash.webm')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      })
      ..setLooping(false)
      ..setVolume(0.0);

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration &&
          !_controller.value.isPlaying) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Sign_Up()), //MapPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EDF6),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
