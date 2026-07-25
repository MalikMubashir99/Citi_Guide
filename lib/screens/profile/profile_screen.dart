import 'package:app/model/user_model.dart';
import 'package:app/screens/auth/login_screen.dart';
import 'package:app/screens/profile/edit_profile_screen.dart';
import 'package:app/screens/profile/favorites_screen.dart';
import 'package:app/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService userService = UserService();

  late Future<UserModel> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = userService.getUser();
  }

  Future<void> logout() async {
    bool? result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void refreshProfile() {
    setState(() {
      userFuture = userService.getUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: FutureBuilder<UserModel>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 10),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: refreshProfile,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text("User not found"),
            );
          }

          UserModel user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ✅ Profile Image with better handling
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          user.image.isNotEmpty
                              ? NetworkImage(user.image)
                              : null,
                      backgroundColor: Colors.grey.shade200,
                      child: user.image.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 55,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    // ✅ Edit icon overlay
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xff0984E3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  user.phone.isNotEmpty ? user.phone : "No phone number",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 30),

                // ✅ Menu Items with better styling
                _buildMenuItem(
                  icon: Icons.edit,
                  title: "Edit Profile",
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(
                          user: user,
                          onProfileUpdated: refreshProfile,
                        ),
                      ),
                    );
                    refreshProfile();
                  },
                ),

                _buildMenuItem(
                  icon: Icons.favorite,
                  title: "My Favorites",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FavoritesScreen(),
                      ),
                    );
                  },
                ),

                _buildMenuItem(
                  icon: Icons.settings,
                  title: "Settings",
                  onTap: () {
                    // Navigate to settings screen
                  },
                ),

                _buildMenuItem(
                  icon: Icons.logout,
                  title: "Logout",
                  onTap: logout,
                  isDestructive: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xff0984E3),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDestructive ? Colors.red : Colors.grey.shade400,
        ),
        onTap: onTap,
      ),
    );
  }
}