import 'package:flutter/material.dart';

class VictimShapeWidget extends StatelessWidget {
  const VictimShapeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: VictimClipper(),
      child: Container(
        width: 130,
        height: 40,
        color: Color(0xFF7B6767), // Matching your shape's color
        alignment: Alignment.center,
        child: const Text(
          'VICTIMS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class VictimClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Start from top-left
    path.moveTo(20, 0); // Add curve inward on top-left
    path.quadraticBezierTo(0, 0, 0, 20);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.quadraticBezierTo(size.width - 10, 0, size.width - 20, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
