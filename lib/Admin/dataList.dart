// ignore_for_file: file_names, camel_case_types, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:crisis_survivor/Admin/editScreen.dart';
import 'package:google_fonts/google_fonts.dart';

class Data extends StatefulWidget {
  const Data({super.key});

  @override
  State<Data> createState() => _DataState();
}

class _DataState extends State<Data> {
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

                      return ListTile(
                        title: Text(
                          data['username'],
                          style: GoogleFonts.roboto(
                            fontSize: width / 27,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          data['email'],
                          style: GoogleFonts.roboto(
                            fontSize: width / 35,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              data['role'],
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
                                deleteDocument(
                                  documents[index].id,
                                  data['email'],
                                );
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

  Future<void> deleteDocument(String documentId, String email) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    try {
      if (querySnapshot.docs.isEmpty) {
        return;
      }

      DocumentSnapshot userDocument = querySnapshot.docs.first;

      // Delete the user's Firebase Authentication account
      // User? user = FirebaseAuth.instance.currentUser;
      // await user?.delete();

      // Delete the user's Firestore document
      await userDocument.reference.delete();

      setState(() {});
    } catch (e) {
      print('Failed to delete user: $e');
    }
  }
}
