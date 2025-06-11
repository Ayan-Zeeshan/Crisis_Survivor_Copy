// // ignore_for_file: file_names, camel_case_types, avoid_print, non_constant_identifier_names, no_leading_underscores_for_local_identifiers, use_build_context_synchronously

// import 'dart:convert';
// import 'dart:developer' show log;

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:crisis_survivor/Admin/editUsers.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class Users extends StatefulWidget {
//   const Users({super.key});

//   @override
//   State<Users> createState() => _UsersState();
// }

// class _UsersState extends State<Users> {
//   bool emailSent = false;
//   bool canResend = false;
//   String? error;

//   String? requester_email = "";

//   @override
//   void initState() {
//     super.initState();
//     loadRequesterEmail();
//   }

//   Future<void> loadRequesterEmail() async {
//     SharedPreferences _pref = await SharedPreferences.getInstance();
//     dynamic cache = _pref.getString('Data');

//     if (cache != null && cache.isNotEmpty) {
//       final Map<String, dynamic> cacheMap = json.decode(cache);
//       if (cacheMap.isNotEmpty) {
//         requester_email = cacheMap['email'];
//         log("Requester Email: $requester_email");
//       } else {
//         log("Cache is empty!");
//       }
//     } else {
//       log("Cache is empty!");
//     }
//   }

//   Future<void> deleteDocument(String documentId, String emailToDelete) async {
//     try {
//       // Check if the email to delete exists in Firestore
//       QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .where('email', isEqualTo: emailToDelete)
//           .get();

//       if (querySnapshot.docs.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('User not found!'),
//             duration: Duration(seconds: 3),
//           ),
//         );
//         return;
//       }

//       // Make request to backend to verify admin rights and delete
//       final response = await http.post(
//         Uri.parse(
//           "https://authbackend-production-ed7f.up.railway.app/api/delete-code/",
//         ),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "requester_email": requester_email,
//           "email": emailToDelete,
//         }),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200 && data['success'] == true) {
//         // Delete the user's Firestore document
//         await querySnapshot.docs.first.reference.delete();

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('User Successfully Deleted!'),
//             duration: Duration(seconds: 3),
//           ),
//         );

//         setState(() {});
//       } else {
//         error = data['error'] ?? "Invalid or expired code.";
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('User Deletion Failed: $error'),
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() => error = "Something went wrong. Try again.");
//       print('Failed to delete user: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "List of Users",
//           style: GoogleFonts.roboto(
//             fontWeight: FontWeight.w500,
//             fontSize: width / 20,
//           ),
//         ),
//         backgroundColor: const Color.fromARGB(255, 12, 226, 65),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection("users")
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(
//                     child: CircularProgressIndicator(color: Colors.blue),
//                   );
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 } else {
//                   QuerySnapshot querySnapshot = snapshot.data!;
//                   List<DocumentSnapshot> documents = querySnapshot.docs;
//                   return ListView.builder(
//                     physics: const NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     itemCount: documents.length,
//                     itemBuilder: (context, index) {
//                       Map<String, dynamic> data =
//                           documents[index].data() as Map<String, dynamic>;

//                       String email = data['email'] ?? "";

//                       return ListTile(
//                         title: Text(
//                           data['username'],
//                           style: GoogleFonts.roboto(
//                             fontSize: width / 27,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         subtitle: Text(
//                           email,
//                           style: GoogleFonts.roboto(
//                             fontSize: width / 35,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               data['role'] ?? "Unassigned",
//                               style: const TextStyle(color: Colors.black),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.edit),
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         EditScreen(documents[index].id),
//                                   ),
//                                 ).then((_) {
//                                   setState(() {});
//                                 });
//                               },
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.delete),
//                               onPressed: () {
//                                 deleteDocument(documents[index].id, email);
//                               },
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   );
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// ignore_for_file: file_names, camel_case_types, avoid_print, non_constant_identifier_names, no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'dart:convert';
import 'dart:developer' show log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:crisis_survivor/Admin/editUsers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  bool emailSent = false;
  bool canResend = false;
  String? error;

  String? requester_email = "";

  @override
  void initState() {
    super.initState();
    loadRequesterEmail();
  }

  Future<void> loadRequesterEmail() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    dynamic cache = _pref.getString('Data');

    if (cache != null && cache.isNotEmpty) {
      final Map<String, dynamic> cacheMap = json.decode(cache);
      if (cacheMap.isNotEmpty) {
        requester_email = cacheMap['email'];
        log("Requester Email: $requester_email");
      } else {
        log("Cache is empty!");
      }
    } else {
      log("Cache is empty!");
    }
  }

  Future<void> deleteDocument(String documentId, String emailToDelete) async {
    try {
      final response = await http.post(
        Uri.parse(
          "https://authbackend-production-ed7f.up.railway.app/api/delete-user/",
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "requester_email": requester_email,
          "email": emailToDelete,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User Successfully Deleted!'),
            duration: Duration(seconds: 3),
          ),
        );
        setState(() {});
      } else {
        error = data['error'] ?? "Something went wrong.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User Deletion Failed: $error'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() => error = "Something went wrong. Try again.");
      print('Failed to delete user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "List of Users",
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w500,
            fontSize: width / 20,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 12, 226, 65),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  QuerySnapshot querySnapshot = snapshot.data!;
                  List<DocumentSnapshot> documents = querySnapshot.docs;
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data =
                          documents[index].data() as Map<String, dynamic>;

                      String email = data['email'] ?? "";

                      return ListTile(
                        title: Text(
                          data['username'],
                          style: GoogleFonts.roboto(
                            fontSize: width / 27,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          email,
                          style: GoogleFonts.roboto(
                            fontSize: width / 35,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              data['role'] ?? "Unassigned",
                              style: const TextStyle(color: Colors.black),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditScreen(documents[index].id),
                                  ),
                                ).then((_) {
                                  setState(() {});
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                deleteDocument(documents[index].id, email);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
