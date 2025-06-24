// ignore_for_file: file_names

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:crisis_survivor/Screens/Signup.dart';

class SplashSignUp extends StatefulWidget {
  const SplashSignUp({super.key});

  @override
  State<SplashSignUp> createState() => _SplashSignUpState();
}

class _SplashSignUpState extends State<SplashSignUp> {
  late VideoPlayerController _controller;
  bool navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/splash.webm')
      ..initialize().then((_) {
        _controller.play();
        setState(() {});

        // Fallback: force navigate after video duration or 6s
        Future.delayed(
          _controller.value.duration >= Duration(seconds: 0)
              ? _controller.value.duration + const Duration(seconds: 0)
              : const Duration(seconds: 6),
          () {
            if (mounted && !navigated) {
              navigated = true;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Sign_Up()),
              );
            }
          },
        );
      })
      ..setLooping(false)
      ..setVolume(0.0);
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
        child: // _controller.value.isInitialized
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        // : const CircularProgressIndicator(),
      ),
    );
  }
}
