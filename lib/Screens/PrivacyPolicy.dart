// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''
Privacy Policy

This Privacy Policy describes how we collect, use, and disclose your information when you use our App.

1. Information Collection
We may collect information including name, email address, and usage data to improve our services.

2. Use of Information
We use the collected data to provide and improve the App’s features and user experience.

3. Data Sharing
We do not share your personal data with third parties except as required by law.

4. Security
We value your trust and strive to use commercially acceptable means of protecting your data.

5. Changes to This Policy
We may update our Privacy Policy from time to time. Changes will be reflected in this section.

Contact Us
If you have any questions about this Privacy Policy, contact us at privacy@example.com.
            ''',
            style: GoogleFonts.poppins(
              fontSize: width / 30,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(204, 0, 0, 0),
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xFFF2EDF6),
    );
  }
}
