import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login.dart';
import 'history_screen.dart';
import 'profile.dart';
import 'forgetpassword_screen.dart';
import 'faq_screen.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool showLanguageDropdown = false;
  bool showFaqDropdown = false;
  String currentLanguage = 'English';

  final List<FaqItem> faqItems = [
    FaqItem(
      question: 'How do I change my password?',
      answer: 'Go to Settings > Change Password and follow the instructions.',
    ),
    FaqItem(
      question: 'How do I update my profile?',
      answer:
          'Select Edit Profile from the Settings menu to modify your information.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSettingsItems(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DotNavBar(),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(18),
      child: Row(
        children: [
          SizedBox(width: 16),
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItems() {
    return Column(
      children: [
        _buildSettingsMenuItem(
          title: 'Edit Profile',
          trailing: const Icon(Icons.edit, color: Color(0xFF374151)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Profile()),
            );
          },
        ),
        const SizedBox(height: 24),
        _buildSettingsMenuItem(
          title: 'Change Password',
          trailing: const Icon(Icons.lock_outline, color: Color(0xFF374151)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ForgotPasswordScreen()),
            );
          },
        ),
        const SizedBox(height: 24),
        _buildLanguageDropdown(),
        const SizedBox(height: 24),
        _buildFaqDropdown(),
        const SizedBox(height: 24),
        _buildSettingsMenuItem(
          title: 'Log Out',
          trailing: const Icon(Icons.logout, color: Color(0xFF374151)),
          onTap: () => _showLogoutDialog(),
        ),
      ],
    );
  }

  Widget _buildSettingsMenuItem({
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF374151)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF374151),
              ),
            ),
            trailing ?? const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return Column(
      children: [
        _buildSettingsMenuItem(
          title: 'Change Language',
          trailing: Icon(
            showLanguageDropdown
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            color: const Color(0xFF374151),
          ),
          onTap: () =>
              setState(() => showLanguageDropdown = !showLanguageDropdown),
        ),
        if (showLanguageDropdown)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF374151)),
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              children: ['English', 'Spanish', 'French']
                  .map((lang) => _buildLanguageOption(lang))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildLanguageOption(String language) {
    return InkWell(
      onTap: () {
        setState(() {
          currentLanguage = language;
          showLanguageDropdown = false;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Text(
          language,
          style: const TextStyle(color: Color(0xFF374151)),
        ),
      ),
    );
  }

  Widget _buildFaqDropdown() {
    return Column(
      children: [
        _buildSettingsMenuItem(
          title: 'FAQs',
          trailing: Icon(
            showFaqDropdown
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            color: const Color(0xFF374151),
          ),
          onTap: () => setState(() => showFaqDropdown = !showFaqDropdown),
        ),
        if (showFaqDropdown)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF374151)),
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              children: faqItems.map((item) => _buildFaqItem(item)).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildFaqItem(FaqItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.answer,
            style: const TextStyle(color: Color(0xFF374151)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("Logout"),
            onPressed: () {
              Navigator.of(context).pop();
              // هنا يمكن إضافة منطق تسجيل الخروج الخاص بك
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
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

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}
