// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''
Terms & Conditions

By using this application ("App"), you agree to the following terms and conditions:

1. Acceptance of Terms
By accessing or using the App, you agree to be bound by these Terms & Conditions and our Privacy Policy.

2. Use of the App
You may use the App only for lawful purposes. You must not use the App in any way that is unlawful, or harmful to others.

3. Intellectual Property
All content, logos, designs, and features are the property of the App developer and protected under copyright law.

4. Termination
We may terminate or suspend your access to the App at any time, without prior notice, for conduct that violates these terms.

5. Limitation of Liability
We do not guarantee that the App will be available at all times. We are not responsible for any loss or damages incurred.

6. Changes to the Terms
We reserve the right to update or change these Terms at any time without notice.

Contact Us
If you have any questions about these Terms, contact us at support@example.com.
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
