import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabler_icons_flutter/tabler_icons_flutter.dart';
import 'auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= 640;
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine padding based on screen width
    double horizontalPadding;
    if (screenWidth > 991) {
      horizontalPadding = 40.0;
    } else if (screenWidth > 640) {
      horizontalPadding = 30.0;
    } else {
      horizontalPadding = 20.0;
    }

    return Scaffold(
      body: Container(
        width: isSmallScreen ? screenSize.width : 402,
        height: isSmallScreen ? screenSize.height : 874,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFA9E0F5),
              Color(0xFFE2F5FC),
              Color(0xFFAFE4FA),
            ],
            stops: [0.1723, 0.4842, 1.0],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GradientCircle(size: 275, top: -58, right: -58),
            GradientCircle(size: 275, bottom: -58, left: -58),
            GradientCircle(size: 137, top: 189, right: -69),
            GradientCircle(size: 137, bottom: 189, left: -69),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(
                    'https://cdn.builder.io/api/v1/image/assets/TEMP/b16d09f6d3560a333e0f8920506c56d8a41929f3',
                    width: double.infinity,
                    height: 700 * (screenWidth / 991), // Responsive height
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GradientCircle extends StatelessWidget {
  final double size;
  final double top;
  final double left;
  final double right;
  final double bottom;

  const GradientCircle({
    Key? key,
    required this.size,
    this.top = double.infinity,
    this.left = double.infinity,
    this.right = double.infinity,
    this.bottom = double.infinity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top != double.infinity ? top : null,
      left: left != double.infinity ? left : null,
      right: right != double.infinity ? right : null,
      bottom: bottom != double.infinity ? bottom : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment(-0.7, -0.7),
            end: Alignment(0.7, 0.7),
            colors: [
              Color(0xFF35BCEA),
              Color(0xFF4AC1EC),
              Color(0xFF95D8F3),
            ],
            stops: [0.1321, 0.3016, 0.7451],
          ),
        ),
      ),
    );
  }
}
