import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Upload.dart';
import 'details_screen.dart';
import 'history_screen.dart';
import 'profile.dart';
import 'settings_screen.dart';
import 'admin/admindashboard_screen.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';

class HomeScreen extends StatelessWidget {
  final bool isAdmin;

  const HomeScreen({Key? key, this.isAdmin = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            margin: EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                const SizedBox(height: 70),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ProfileSection(isAdmin: isAdmin),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        'Hello! Ready to analyze your skin?',
                        style: TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.6,
                          fontFamily: 'Roboto',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Take or upload a photo of your skin concern, and our AI will help identify potential conditions',
                        style: TextStyle(
                          color: Color(0xFF373737),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                          fontFamily: 'Roboto',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      ActionButton(
                        text: 'Capture New Image',
                        icon: Icons.camera_alt,
                        isPrimary: true,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailsScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      ActionButton(
                        text: 'Upload From Gallery',
                        icon: Icons.upload_file,
                        isPrimary: false,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Gallerypage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: DotNavBar(),
    );
  }
}

class ProfileSection extends StatelessWidget {
  final bool isAdmin;

  const ProfileSection({Key? key, required this.isAdmin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userName = user?.email?.split('@')[0] ?? 'User';

    return Container(
      constraints: const BoxConstraints(maxWidth: 370),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 173, 173, 173),
                  image: DecorationImage(
                    image: AssetImage('assets/image/user.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello!',
                    style: TextStyle(
                      color: Color(0xFF373737),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userName,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              if (isAdmin)
                IconButton(
                  icon: Icon(Icons.admin_panel_settings, size: 28),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminDashboardScreen()),
                    );
                  },
                ),
              IconButton(
                icon: Icon(Icons.person, size: 28),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Profile()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onPressed;

  const ActionButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.isPrimary,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF1B9BDB) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isPrimary ? Colors.white : const Color(0xFF1B9BDB),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    color: isPrimary ? Colors.white : const Color(0xFF1B9BDB),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 2,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
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
