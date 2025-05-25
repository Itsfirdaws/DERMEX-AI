import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'add_users.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Function to delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _usersRef.child(userId).remove();
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete user')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'User Management',
                    style: AppTextStyles.headerTitle,
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Search and User List Section
              Expanded(
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value.toLowerCase();
                                });
                              },
                              style: AppTextStyles.searchText,
                              decoration: const InputDecoration(
                                hintText: 'Search...',
                                hintStyle: AppTextStyles.searchText,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Add User Button
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddUsers()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border, width: 2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Add New User',
                              style: AppTextStyles.addUserText,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // User List
                    Expanded(
                      child: FirebaseAnimatedList(
                        query: _usersRef,
                        defaultChild:
                            const Center(child: CircularProgressIndicator()),
                        itemBuilder: (context, snapshot, animation, index) {
                          final userId = snapshot.key!;
                          final userEmail =
                              snapshot.child('email').value.toString();
                          final userName =
                              snapshot.child('name').value?.toString() ??
                                  'No Name';
                          final userPhone =
                              snapshot.child('phone').value?.toString() ??
                                  'No Phone';
                          final isAdmin =
                              snapshot.child('isAdmin').value as bool? ?? false;

                          if (_searchQuery.isNotEmpty &&
                              !userEmail.toLowerCase().contains(_searchQuery) &&
                              !userName.toLowerCase().contains(_searchQuery) &&
                              !userPhone.toLowerCase().contains(_searchQuery)) {
                            return const SizedBox.shrink();
                          }

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.surfaceLight,
                                    border: Border.all(
                                      color: AppColors.imageBorder,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(Icons.person,
                                      color: Colors.white),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        style: AppTextStyles.userName,
                                      ),
                                      Text(
                                        userEmail,
                                        style: AppTextStyles.userEmail,
                                      ),
                                      Text(
                                        userPhone,
                                        style: AppTextStyles.userPhone,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isAdmin)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Admin',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    deleteUser(userId);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppColors {
  static const Color background = Color(0xFF111827);
  static const Color surface = Color(0xFF374151);
  static const Color surfaceLight = Color(0x801F2937);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFCCCCCC);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textQuaternary = Color(0xFFD1D5DB);
  static const Color border = Color(0xFF374151);
  static const Color imageBorder = Color(0x4C60A5FA);
}

class AppTextStyles {
  static const TextStyle headerTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle searchText = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle addUserText = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle userName = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle userEmail = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
  );

  static const TextStyle userPhone = TextStyle(
    color: AppColors.textTertiary,
    fontSize: 12,
  );
}
