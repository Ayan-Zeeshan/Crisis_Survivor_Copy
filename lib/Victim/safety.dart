// ignore_for_file: empty_catches

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class Safety extends StatefulWidget {
  const Safety({super.key});

  @override
  State<Safety> createState() => _SafetyState();
}

class _SafetyState extends State<Safety> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final String fromUid = "user_123"; // Replace with current user's UID
  final String toUid = "consultant_456"; // Replace with recipient UID
  final String sendUrl =
      "https://authbackend-production-d43e.up.railway.app/api/send-chat/";
  final String receiveUrl =
      "https://authbackend-production-d43e.up.railway.app/api/receive-chat/";

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final res = await http.post(
        Uri.parse(receiveUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"from_uid": fromUid, "to_uid": toUid}),
      );

      if (res.statusCode == 200) {
        final List msgs = jsonDecode(res.body)['messages'];
        setState(() {
          _messages.clear();
          _messages.addAll(
            msgs.map(
              (e) => {
                "text": e["text"],
                "sender": e["from"] == fromUid ? "victim" : "consultant",
              },
            ),
          );
        });
      } else {}
    } catch (e) {}
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'text': text.trim(), 'sender': 'victim'});
    });

    _controller.clear();

    try {
      await http.post(
        Uri.parse(sendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "from_uid": fromUid,
          "to_uid": toUid,
          "message": text.trim(),
        }),
      );
    } catch (e) {}
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    bool isVictim = message['sender'] == 'victim';

    return Align(
      alignment: isVictim ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isVictim ? Colors.purpleAccent : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isVictim ? 12 : 0),
            bottomRight: Radius.circular(isVictim ? 0 : 12),
          ),
        ),
        child: Text(
          message['text'],
          style: TextStyle(color: isVictim ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF2EDF6),
      body: Column(
        children: [
          // Header with title and stacked circles
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
                Positioned(
                  top: height / 8,
                  left: width / 4.3,
                  child: Text(
                    "SAFETY AND\nGUIDE",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Color(0xFF563D3D),
                      fontSize: width / 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Message list
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return _buildMessage(message);
              },
            ),
          ),

          // Input field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendMessage,
                    style: GoogleFonts.poppins(),
                    decoration: InputDecoration(
                      fillColor: const Color(0xFFC0B5BB),
                      filled: true,
                      hintText: 'Type a message...',
                      hintStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: width / 20,
                        color: Colors.black,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(width),
                        borderSide: const BorderSide(color: Color(0xFFC0B5BB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(width),
                        borderSide: const BorderSide(color: Color(0xFFC0B5BB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(width),
                        borderSide: const BorderSide(color: Color(0xFFC0B5BB)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendMessage(_controller.text),
                  child: const Icon(Icons.send, color: Color(0xFFC0B5BB)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
