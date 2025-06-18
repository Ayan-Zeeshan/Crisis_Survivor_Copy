// ignore_for_file: file_names, camel_case_types, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditScreen extends StatefulWidget {
  final String docId;
  const EditScreen(this.docId, {super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController usernameController;
  late TextEditingController emailController;
  String? selectedRole;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    loadUserData();
  }

  Future<void> loadUserData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.docId)
        .get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      setState(() {
        usernameController.text = data['username'] ?? '';
        emailController.text = data['email'] ?? '';
        selectedRole = data['role'] ?? 'donor';
      });
    }
  }

  Future<void> updateUser() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.docId)
        .update({
          'username': usernameController.text,
          'email': emailController.text,
          'role': selectedRole ?? 'donor',
        });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
        backgroundColor: const Color.fromARGB(255, 12, 226, 65),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRole,
              items: [
                DropdownMenuItem(
                  value: 'Admin'.toLowerCase(),
                  child: Text('Admin'),
                ),
                DropdownMenuItem(
                  value: 'Donor'.toLowerCase(),
                  child: Text('Donor'),
                ),
                DropdownMenuItem(
                  value: 'victim'.toLowerCase(),
                  child: Text('victim'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedRole = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: updateUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 12, 226, 65),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
