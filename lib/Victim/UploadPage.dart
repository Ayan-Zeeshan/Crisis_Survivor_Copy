// ignore_for_file: file_names, depend_on_referenced_packages

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crisis_survivor/Widget/uploadButton.dart';
import 'package:crisis_survivor/Victim/request.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? cnicCard;
  File? livingCert;
  File? incomeCert;
  File? gasBill;

  Future<void> loadCachedFiles() async {
    final cacheDir = await getTemporaryDirectory();
    setState(() {
      cnicCard = File('${cacheDir.path}/cnic_card.png');
      livingCert = File('${cacheDir.path}/living_certificate.png');
      incomeCert = File('${cacheDir.path}/income_certificate.png');
      gasBill = File('${cacheDir.path}/gas_bill.png');

      if (!cnicCard!.existsSync()) cnicCard = null;
      if (!livingCert!.existsSync()) livingCert = null;
      if (!incomeCert!.existsSync()) incomeCert = null;
      if (!gasBill!.existsSync()) gasBill = null;
    });
  }

  Widget buildUploadRow({
    required File? file,
    required String label,
    required String subLabel,
    required String fileName,
    required Function(File?) onSelected,
    required double width,
    required double height,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: CustomUploadButton(
            label: label,
            subLabel: subLabel,
            width: width,
            height: height,
            fileName: fileName,
            onFileSelected: (f) => setState(() => onSelected(f)),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    loadCachedFiles();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: height * 0.23,
              child: Stack(
                children: [
                  Positioned(
                    top: width / -22,
                    left: width / -4.15,
                    child: Container(
                      width: height / 4.3,
                      height: width / 2.3,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(120, 125, 105, 108),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: width / -4.15,
                    left: width / -90,
                    child: Container(
                      width: width / 2.3,
                      height: height / 4.3,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(145, 109, 91, 91),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: width / 15),
            Text(
              "Basic Things Required for Donation Request",
              style: GoogleFonts.poppins(
                fontSize: width / 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: width / 12),

            buildUploadRow(
              file: cnicCard,
              label: "Click to Upload",
              subLabel: "CNIC/Smart Card",
              fileName: "cnic_card.png",
              onSelected: (f) => cnicCard = f,
              width: width,
              height: height,
            ),
            SizedBox(height: width / 28),

            buildUploadRow(
              file: livingCert,
              label: "Click to Upload",
              subLabel: "Living Certificate",
              fileName: "living_certificate.png",
              onSelected: (f) => livingCert = f,
              width: width,
              height: height,
            ),
            SizedBox(height: width / 28),

            buildUploadRow(
              file: incomeCert,
              label: "Click to Upload",
              subLabel: "Income Certificate",
              fileName: "income_certificate.png",
              onSelected: (f) => incomeCert = f,
              width: width,
              height: height,
            ),
            SizedBox(height: width / 28),

            buildUploadRow(
              file: gasBill,
              label: "Click to Upload",
              subLabel: "Electric and Gas Bill",
              fileName: "gas_bill.png",
              onSelected: (f) => gasBill = f,
              width: width,
              height: height,
            ),
            SizedBox(height: width / 12),

            ElevatedButton(
              onPressed: () {
                if (cnicCard != null &&
                    livingCert != null &&
                    incomeCert != null &&
                    gasBill != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RequestPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please upload all required documents."),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(width / 2.5, height * 0.063),
                backgroundColor: const Color.fromARGB(194, 86, 61, 61),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(width / 10)),
                  side: const BorderSide(
                    color: Color.fromARGB(194, 86, 61, 61),
                  ),
                ),
              ),
              child: Text(
                "Save",
                style: GoogleFonts.poppins(
                  color: const Color.fromARGB(253, 255, 255, 255),
                  fontSize: (width / 18.55),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: width / 10),
          ],
        ),
      ),
    );
  }
}
