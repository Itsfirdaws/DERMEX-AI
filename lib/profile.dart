import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';

import 'settings_screen.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: InputDesignStyles.backgroundColor,
            borderRadius: BorderRadius.circular(25),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(
            horizontal: 17,
            vertical: 68,
          ),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 40),
              _buildProfileSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const DotNavBar(),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const SizedBox(width: 20),
        const Text(
          'Profile',
          style: InputDesignStyles.titleStyle,
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Image.network(
            'https://cdn.builder.io/api/v1/image/assets/862c5b82d300491da5746b94a28aaf1d/1c5f95667e36a94ebc077c8f91b50ee610849dad4a75b6dc6436c7b7f72dd43c?placeholderIfAbsent=true',
            width: 160,
            height: 160,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 40),
          _buildInputField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter Your Email',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$")
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: InputDesignStyles.spacing),
          _buildInputField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter Your Password',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
            obscureText: true,
          ),
          const SizedBox(height: InputDesignStyles.spacing),
          _buildInputField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: 'Enter Your Phone Number',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              if (!RegExp(r"^[0-9]{11}$").hasMatch(value)) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: InputDesignStyles.spacing),
          _buildInputField(
            controller: _dobController,
            label: 'Date of Birth',
            hint: 'Enter Your Date of Birth',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your date of birth';
              }
              return null;
            },
          ),
          const SizedBox(height: 40),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDesignStyles.getInputDecoration(label, hint),
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black,
        fontFamily: 'Roboto',
      ),
      obscureText: obscureText,
      validator: validator,
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: InputDesignStyles.inputHeight,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState?.validate() ?? false) {
            try {
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: _emailController.text.trim(),
                password: _passwordController.text.trim(),
              );
              // Here you can save the phone number and date of birth in Firestore if needed
              // For now, we just navigate to the home screen after a successful registration
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            } on FirebaseAuthException catch (e) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Error'),
                  content: Text(e.message ?? 'An error occurred'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: InputDesignStyles.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(InputDesignStyles.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: InputDesignStyles.horizontalPadding,
            vertical: InputDesignStyles.verticalPadding,
          ),
        ),
        child: const Text(
          'Confirm',
          style: InputDesignStyles.buttonStyle,
        ),
      ),
    );
  }
}

class DotNavBar extends StatefulWidget {
  const DotNavBar({Key? key}) : super(key: key);

  @override
  _DotNavBarState createState() => _DotNavBarState();
}

class _DotNavBarState extends State<DotNavBar> {
  var _selectedTab = _SelectedTab.home;

  void _handleIndexChanged(int i) {
    setState(() {
      _selectedTab = _SelectedTab.values[i];
    });

    switch (_selectedTab) {
      case _SelectedTab.home:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        break;
      case _SelectedTab.history:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HistoryScreen()),
        );
        break;
      case _SelectedTab.settings:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()),
        );
        break;
      case _SelectedTab.profile:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Profile()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DotNavigationBar(
      currentIndex: _SelectedTab.values.indexOf(_selectedTab),
      onTap: _handleIndexChanged,
      dotIndicatorColor: Colors.black,
      marginR: EdgeInsets.symmetric(horizontal: 15, vertical: 1),
      paddingR: EdgeInsets.only(bottom: 5, top: 5),
      borderRadius: 50,
      backgroundColor: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 2,
          offset: Offset(0, 2),
        )
      ],
      items: [
        DotNavigationBarItem(
          icon: Icon(Icons.home),
          selectedColor: Colors.blue,
        ),
        DotNavigationBarItem(
          icon: Icon(Icons.history),
          selectedColor: Colors.blue,
        ),
        DotNavigationBarItem(
          icon: Icon(Icons.settings),
          selectedColor: Colors.blue,
        ),
        DotNavigationBarItem(
          icon: Icon(Icons.person),
          selectedColor: Colors.blue,
        ),
      ],
      itemPadding: EdgeInsets.symmetric(vertical: 10), // Increase item size
    );
  }
}

enum _SelectedTab { home, history, settings, profile }

class InputDesignStyles {
  static const Color primaryBlue = Color(0xFF1B9BDB);
  static const Color grayText = Color(0xFFAFAFAFAF);
  static const Color borderColor = Color(0xFFB9B9B9);
  static const Color backgroundColor = Colors.white;

  static const double borderRadius = 16.0;
  static const double inputHeight = 56.0;
  static const double horizontalPadding = 24.0;
  static const double verticalPadding = 12.0;
  static const double spacing = 24.0;

  static const TextStyle labelStyle = TextStyle(
    fontSize: 18.0,
    color: primaryBlue,
    fontWeight: FontWeight.w500,
    fontFamily: 'Roboto',
  );

  static const TextStyle hintStyle = TextStyle(
    fontSize: 12.0,
    color: grayText,
    fontWeight: FontWeight.w400,
    fontFamily: 'Roboto',
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 24.0,
    color: Colors.black,
    fontWeight: FontWeight.w700,
    fontFamily: 'Roboto',
  );

  static const TextStyle buttonStyle = TextStyle(
    fontSize: 14.0,
    color: Colors.white,
    fontWeight: FontWeight.w500,
    fontFamily: 'Roboto',
  );

  static InputDecoration getInputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      labelStyle: labelStyle,
      hintText: hint,
      hintStyle: hintStyle,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: primaryBlue),
      ),
    );
  }
}
