// ignore_for_file: use_build_context_synchronously, unnecessary_string_interpolations

import 'package:crisis_survivor/Donor/donorscreen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DonateUsPage extends StatefulWidget {
  const DonateUsPage({super.key});

  @override
  State<DonateUsPage> createState() => _DonateUsPageState();
}

class _DonateUsPageState extends State<DonateUsPage> {
  bool _showSuccess = false;
  String? _selectedCard;

  void _handleDone() {
    if (_selectedCard != null) {
      setState(() {
        _showSuccess = true;
      });

      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DonorScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F2F5),
      body: _showSuccess
          ? Center(
              child: Lottie.asset(
                'assets/ms1.json',
                width: width * 0.7,
                height: height * 0.7,
                fit: BoxFit.contain,
              ),
            )
          : SingleChildScrollView(
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
                  SizedBox(height: height * 0.02),
                  Row(
                    children: [
                      SizedBox(width: width * 0.38),
                      Text(
                        "Donate US",
                        style: TextStyle(
                          fontSize: width * 0.05,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.01),
                  // Icon(
                  //   Icons.volunteer_activism,
                  //   size: width * 0.3,
                  //   color: Colors.brown.shade800,
                  // ),
                  // Text(
                  //   "Donate",
                  //   style: TextStyle(
                  //     fontSize: width * 0.05,
                  //     fontWeight: FontWeight.w600,
                  //     color: Colors.brown.shade800,
                  //   ),
                  // ),
                  Image.asset("assets/DonateUs.png", width: width * 0.45),
                  SizedBox(height: height * 0.03),
                  _buildCardOption(
                    type: "Mastercard",
                    number: "**** 5967",
                    expiry: "03/28",
                    width: width,
                    path: "assets/MasterCard.png",
                    height: height,
                  ),
                  _buildCardOption(
                    type: "VISA",
                    number: "**** 7539",
                    expiry: "09/25",
                    width: width,
                    path: "assets/Visa.png",
                    height: height,
                  ),
                  _buildCardOption(
                    type: "JazzCash",
                    width: width,
                    path: "assets/JazzCash2.png",
                    height: height,
                  ),
                  _buildCardOption(
                    type: "EasyPaisa",
                    width: width,
                    path: "assets/EasyPaisa2.png",
                    height: height,
                  ),
                  _buildCardOption(
                    type: "SadaPay",
                    width: width,
                    path: "assets/sadapay2.png",
                    height: height,
                  ),
                  SizedBox(height: height * 0.05),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade400,
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.2,
                        vertical: height * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _handleDone,
                    child: Text(
                      "Done",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.045,
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.05),
                ],
              ),
            ),
    );
  }

  Widget _buildCardOption({
    required String type,
    String? number,
    String? expiry,
    required double width,
    required String path,
    required double height,
  }) {
    String key = "$type $number";

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCard = key;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: width * 0.1),
        padding: EdgeInsets.all(width * 0.035),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedCard == key
                ? Colors.blueAccent
                : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Checkbox(
              value: _selectedCard == key,
              onChanged: (_) {
                setState(() {
                  _selectedCard = key;
                });
              },
              activeColor: Colors.blue,
            ),
            Image.asset(path, height: height * 0.05, width: width * 0.08),
            // Icon(
            //   Icons.credit_card,
            //   color: Colors.blueAccent,
            //   size: width * 0.08,
            // ),
            SizedBox(width: width * 0.03),
            if (number != null && expiry != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$type $number",
                      style: TextStyle(
                        fontSize: width * 0.04,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Expires $expiry",
                      style: TextStyle(
                        fontSize: width * 0.035,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            if (number == null && expiry == null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$type",
                      style: TextStyle(
                        fontSize: width * 0.04,
                        color: Colors.black,
                      ),
                    ),
                    // Text(
                    //   "Expires $expiry",
                    //   style: TextStyle(
                    //     fontSize: width * 0.035,
                    //     color: Colors.grey,
                    //   ),
                    // ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
