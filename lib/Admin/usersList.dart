// // ignore_for_file: file_names, camel_case_types, avoid_print, non_constant_identifier_names, no_leading_underscores_for_local_identifiers, use_build_context_synchronously

// import 'dart:convert';
// import 'dart:developer' show log;

// import 'package:flutter/material.dart';
// import 'package:crisis_survivor/Admin/editUsers.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_auth/firebase_auth.dart';

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
//   List<Map<String, dynamic>> users = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     loadRequesterEmail().then((_) {
//       fetchUsersFromAPI();
//     });
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

//   Future<void> fetchUsersFromAPI() async {
//     try {
//       final response = await http.get(
//         Uri.parse(
//           "https://authbackend-production-d43e.up.railway.app/api/get-users/",
//         ),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         final List<dynamic> usersList = jsonData['users'];

//         setState(() {
//           users = usersList.map((e) => Map<String, dynamic>.from(e)).toList();
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           error = "Failed to load users from server.";
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         error = "Network error occurred.";
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> deleteDocument(String documentId, String emailToDelete) async {
//     try {
//       final response = await http.post(
//         Uri.parse(
//           "https://authbackend-production-d43e.up.railway.app/api/delete-user/",
//         ),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "requester_email": requester_email,
//           "email": emailToDelete,
//         }),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200 && data['success'] == true) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('User Successfully Deleted!'),
//             duration: Duration(seconds: 3),
//           ),
//         );

//         // If the admin deleted themselves, log them out and navigate to login
//         if (emailToDelete == requester_email) {
//           await FirebaseAuth.instance.signOut();
//           SharedPreferences _pref = await SharedPreferences.getInstance();
//           await _pref.clear();
//           Navigator.pushNamedAndRemoveUntil(
//             context,
//             '/signup',
//             (route) => false,
//           );
//         } else {
//           fetchUsersFromAPI(); // Refresh user list
//         }
//       } else {
//         error = data['error'] ?? "Something went wrong.";
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
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator(color: Colors.blue))
//           : users.isEmpty
//           ? const Center(child: Text("No users found."))
//           : SingleChildScrollView(
//               child: ListView.builder(
//                 physics: const NeverScrollableScrollPhysics(),
//                 shrinkWrap: true,
//                 itemCount: users.length,
//                 itemBuilder: (context, index) {
//                   final data = users[index];
//                   final email = data['email'] ?? "";
//                   final userId =
//                       data['uid'] ?? ""; // Django might return it as _id or id

//                   return ListTile(
//                     title: Text(
//                       data['username'] ?? "",
//                       style: GoogleFonts.roboto(
//                         fontSize: width / 27,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     subtitle: Text(
//                       email,
//                       style: GoogleFonts.roboto(
//                         fontSize: width / 35,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           data['role'] ?? "Unassigned",
//                           style: const TextStyle(color: Colors.black),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.edit),
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => EditScreen(userId),
//                               ),
//                             ).then((_) {
//                               fetchUsersFromAPI(); // Refresh list after editing
//                             });
//                           },
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.delete),
//                           onPressed: () {
//                             deleteDocument(userId, email);
//                           },
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//     );
//   }
// }
// ignore_for_file: file_names, camel_case_types, avoid_print, non_constant_identifier_names, no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'dart:convert';
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:crisis_survivor/Admin/editUsers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  String? error;
  String? requester_email = "";
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRequesterEmail().then((_) {
      fetchUsersFromAPI();
    });
  }

  Future<void> loadRequesterEmail() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    final cache = _pref.getString('Data');
    if (cache != null && cache.isNotEmpty) {
      final cacheMap = json.decode(cache) as Map<String, dynamic>;
      if (cacheMap.isNotEmpty) {
        requester_email = cacheMap['email'] as String?;
        log("Requester Email: $requester_email");
      } else {
        log("Cache is empty!");
      }
    } else {
      log("Cache is empty!");
    }
  }

  Future<void> fetchUsersFromAPI() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
          "https://authbackend-production-d43e.up.railway.app/api/list-users/",
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final usersList = jsonData['users'] as List<dynamic>;

        setState(() {
          users = usersList
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Failed to load users from server.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Network error occurred.";
        isLoading = false;
      });
    }
  }

  Future<void> deleteDocument(String documentId, String emailToDelete) async {
    try {
      final response = await http.post(
        Uri.parse(
          "https://authbackend-production-d43e.up.railway.app/api/delete-user/",
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "requester_email": requester_email,
          "email": emailToDelete,
        }),
      );
      final data = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User Successfully Deleted!'),
            duration: Duration(seconds: 3),
          ),
        );
        if (emailToDelete == requester_email) {
          await FirebaseAuth.instance.signOut();
          final _pref = await SharedPreferences.getInstance();
          await _pref.clear();
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/signup',
            (route) => false,
          );
        } else {
          fetchUsersFromAPI();
        }
      } else {
        error = data['error'] as String? ?? "Something went wrong.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User Deletion Failed: $error'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() => error = "Something went wrong. Try again.");
      log('Failed to delete user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : users.isEmpty
          ? const Center(child: Text("No users found."))
          : SingleChildScrollView(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final data = users[index];
                  final email = data['email'] as String? ?? "";
                  final userId = data['uid'] as String? ?? "";

                  return ListTile(
                    title: Text(
                      data['username'] as String? ?? "",
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
                          data['role'] as String? ?? "Unassigned",
                          style: const TextStyle(color: Colors.black),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditScreen(userId),
                              ),
                            ).then((_) => fetchUsersFromAPI());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deleteDocument(userId, email);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
