// ignore_for_file: file_names, camel_case_types, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    final response = await http.post(
      Uri.parse(
        "https://authbackend-production-d43e.up.railway.app/api/receive-data/",
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"uid": widget.docId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      setState(() {
        usernameController.text = data['username'] ?? '';
        emailController.text = data['email'] ?? '';
        selectedRole = data['role'];
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to load user data")));
    }
  }

  Future<void> updateUser() async {
    final response = await http.post(
      Uri.parse(
        "https://authbackend-production-d43e.up.railway.app/api/send-data/",
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "uid": widget.docId,
        "username": usernameController.text,
        "email": emailController.text,
        "role": selectedRole,
      }),
    );

    if (response.statusCode == 200 &&
        json.decode(response.body)['success'] == true) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update user data")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Edit User'),
      //   backgroundColor: const Color.fromARGB(255, 12, 226, 65),
      // ),
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
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                DropdownMenuItem(value: 'donor', child: Text('Donor')),
                DropdownMenuItem(value: 'victim', child: Text('Victim')),
                DropdownMenuItem(value: null, child: Text('Unassigned')),
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
