// // ignore_for_file: use_build_context_synchronously

// import 'dart:async' show StreamSubscription;
// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Screens/splash_signup.dart';

// class AuthGuard {
//   static StreamSubscription<User?>? _authSub;
//   static StreamSubscription<QuerySnapshot>? _firestoreSub;

//   static void startMonitoring(BuildContext context) async {
//     final prefs = await SharedPreferences.getInstance();
//     final dataString = prefs.getString('Data');

//     if (dataString == null) return;

//     final cache = jsonDecode(dataString);
//     final email = cache['email'];

//     // Listen for auth state changes (e.g. if user is deleted from Firebase Auth)
//     _authSub = FirebaseAuth.instance.idTokenChanges().listen((user) async {
//       if (user == null) {
//         await prefs.clear();
//         _cancelListeners();
//         _forceLogout(context);
//       }
//     });

//     // Listen to Firestore doc deletion
//     _firestoreSub = FirebaseFirestore.instance
//         .collection('users')
//         .where('email', isEqualTo: email)
//         .snapshots()
//         .listen((snapshot) async {
//           if (snapshot.docs.isEmpty) {
//             await FirebaseAuth.instance.signOut();
//             await prefs.clear();
//             _cancelListeners();
//             _forceLogout(context);
//           }
//         });
//   }

//   static void _forceLogout(BuildContext context) {
//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (_) => SplashSignUp()),
//       (route) => false,
//     );
//   }

//   static void _cancelListeners() {
//     _authSub?.cancel();
//     _firestoreSub?.cancel();
//   }
// }
// ignore_for_file: use_build_context_synchronously, unused_import

import 'dart:async' show StreamSubscription;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Screens/splash_signup.dart';

class AuthGuard {
  static StreamSubscription<User?>? _authSub;
  static StreamSubscription<DocumentSnapshot>? _firestoreSub;

  static void startMonitoring(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString('Data');

    if (dataString == null) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final uid = currentUser.uid;

    // 🔒 Listen for auth state changes (e.g. if user is signed out or deleted)
    _authSub = FirebaseAuth.instance.idTokenChanges().listen((user) async {
      if (user == null) {
        await prefs.clear();
        _cancelListeners();
        _forceLogout(context);
      }
    });

    // 🔄 Listen for Firestore document deletion using UID
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);

    _firestoreSub = userDocRef.snapshots().listen((snapshot) async {
      if (!snapshot.exists) {
        await FirebaseAuth.instance.signOut();
        await prefs.clear();
        _cancelListeners();
        _forceLogout(context);
      }
    });
  }

  static void _forceLogout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashSignUp()),
      (route) => false,
    );
  }

  static void _cancelListeners() {
    _authSub?.cancel();
    _firestoreSub?.cancel();
  }
}
