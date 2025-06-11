// // ignore_for_file: avoid_print, camel_case_types, no_leading_underscores_for_local_identifiers, avoid_unnecessary_containers, use_build_context_synchronously, unused_import
// import 'dart:async';
// import 'dart:convert';
// // import 'dart:developer';
// import 'package:crisis_survivor/Admin/adminPage.dart';
// import 'package:crisis_survivor/Donee/doneecreen.dart';
// import 'package:crisis_survivor/Donor/donorscreen.dart';
// import 'package:crisis_survivor/Screens/Roles.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:video_player/video_player.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class Splash_Screen extends StatefulWidget {
//   const Splash_Screen({super.key});

//   @override
//   State<Splash_Screen> createState() => _Splash_ScreenState();
// }

// class _Splash_ScreenState extends State<Splash_Screen> {
//   late VideoPlayerController _controller;
//   bool user = true;

//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.asset('assets/splash.webm')
//       ..initialize().then((value) {
//         setState(() {});
//       })
//       ..setVolume(0.0);
//     _playVideo();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _playVideo() async {
//     _controller.play();
//     await Future.delayed(const Duration(seconds: 6));

//     final currentUser = FirebaseAuth.instance.currentUser;

//     if (currentUser != null) {
//       final DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection("users")
//           .doc(currentUser.uid)
//           .get();

//       if (userDoc.exists) {
//         final userData = userDoc.data() as Map<String, dynamic>;
//         final userDetails = {
//           'username': userData['username'],
//           'email': userData['email'],
//           'role': userData['role'],
//           'time': DateTime.now().toString(),
//         };

//         SharedPreferences _pref = await SharedPreferences.getInstance();
//         await _pref.setString('Data', json.encode(userDetails));

//         if (userDetails['role'] == null || userDetails['role'] == "") {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const Roles()),
//           );
//         } else if ((userDetails['role'].toString()).toLowerCase() == "admin") {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const Admin()),
//           );
//         } else if ((userDetails['role'].toString()).toLowerCase() == "donee") {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const DoneeScreen()),
//           );
//         } else if ((userDetails['role'].toString()).toLowerCase() == "donor") {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const DonorScreen()),
//           );
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Center(
//             child: _controller.value.isInitialized
//                 ? AspectRatio(
//                     aspectRatio: _controller.value.aspectRatio,
//                     child: VideoPlayer(_controller),
//                   )
//                 : Container(),
//           ),
//         ],
//       ),
//       backgroundColor: const Color(0xFFF2EDF6),
//     );
//   }
// }
// ignore_for_file: avoid_print, camel_case_types, no_leading_underscores_for_local_identifiers, avoid_unnecessary_containers, use_build_context_synchronously, unused_import, file_names
import 'dart:async';
import 'dart:convert';
// import 'dart:developer';
import 'package:crisis_survivor/Admin/adminPage.dart';
import 'package:crisis_survivor/Donee/doneecreen.dart';
import 'package:crisis_survivor/Donor/donorscreen.dart';
import 'package:crisis_survivor/Screens/Roles.dart';
import 'package:crisis_survivor/Screens/roleBasedNavigation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Splash_Screen extends StatefulWidget {
  const Splash_Screen({super.key});

  @override
  State<Splash_Screen> createState() => _Splash_ScreenState();
}

class _Splash_ScreenState extends State<Splash_Screen> {
  late VideoPlayerController _controller;
  bool user = true;

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

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final userDetails = {
          'username': userData['username'],
          'email': userData['email'],
          'role': userData['role'],
          'time': DateTime.now().toString(),
        };

        SharedPreferences _pref = await SharedPreferences.getInstance();
        await _pref.setString('Data', json.encode(userDetails));

        if (userDetails['role'] != null ||
            (userDetails['role'].toString()).isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RoleBasedHome(
                role: (userDetails['role'].toString()).toLowerCase(),
              ),
            ),
          );
        }
        //  else if ((userDetails['role'].toString()).toLowerCase() == "admin") {
        //   Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(builder: (context) => const Admin()),
        //   );
        // } else if ((userDetails['role'].toString()).toLowerCase() == "donee") {
        //   Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(builder: (context) => const DoneeScreen()),
        //   );
        // } else if ((userDetails['role'].toString()).toLowerCase() == "donor") {
        //   Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(builder: (context) => const DonorScreen()),
        //   );
        // }
      }
    }
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
      backgroundColor: const Color(0xFFF2EDF6),
    );
  }
}
