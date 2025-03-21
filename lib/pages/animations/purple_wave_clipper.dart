import 'package:flutter/material.dart';

// This is an animation for top screen, currently used in:
// - home_page_gigs.dart
class PurpleWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.7);

    // First control point & end point
    var firstControlPoint = Offset(size.width * 0.2, size.height * 0.9);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.8);

    // Second control point & end point
    var secondControlPoint = Offset(size.width * 0.8, size.height * 0.7);
    var secondEndPoint = Offset(size.width, size.height * 0.9);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant PurpleWaveClipper oldClipper) => false;
}
