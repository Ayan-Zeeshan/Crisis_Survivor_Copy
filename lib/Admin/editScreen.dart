// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crisis_survivor/Admin/dataList.dart';
import 'package:google_fonts/google_fonts.dart';

class EditScreen extends StatefulWidget {
  final String documentId;

  const EditScreen(this.documentId, {super.key});

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController subtitleController = TextEditingController();
  TextEditingController roleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDocumentData();
  }

  Future<void> fetchDocumentData() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.documentId)
        .get();

    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
    titleController.text = data['username'];
    subtitleController.text = data['email'];
    roleController.text = data['role'];
  }

  Future<void> updateDocument() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.documentId)
        .update({
          'username': titleController.text,
          'email': subtitleController.text,
          'role': roleController.text,
        });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Data()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Document'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Call the update function when the check button is pressed
              updateDocument();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              style: GoogleFonts.roboto(
                fontSize: width / 20,
                fontWeight: FontWeight.w500,
              ),
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Change Full Name:'),
            ),
            TextField(
              controller: subtitleController,
              decoration: const InputDecoration(labelText: 'Change Email:'),
            ),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(labelText: 'Change Role:'),
            ),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }
}
