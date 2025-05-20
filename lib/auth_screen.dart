import 'package:flutter/material.dart';
import 'register.dart';
import 'login.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  Widget _buildCustomButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 58,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1B9BDB),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Determine padding based on screen width
    double horizontalPadding;
    if (screenWidth > 991) {
      horizontalPadding = 80.0;
    } else if (screenWidth > 640) {
      horizontalPadding = 40.0;
    } else {
      horizontalPadding = 24.0;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            'https://cdn.builder.io/api/v1/image/assets/TEMP/b16d09f6d3560a333e0f8920506c56d8a41929f3',
                            width: double.infinity,
                            height: screenHeight * 0.35, // 35% من الشاشة
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 48),
                        _buildCustomButton(
                          text: 'Log In',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildCustomButton(
                          text: 'Sign Up',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Register()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
