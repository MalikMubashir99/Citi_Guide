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
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
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
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
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

                CircleAvatar(
                  radius: 55,
                  backgroundImage:
                      user.image.isNotEmpty
                          ? NetworkImage(user.image)
                          : null,
                  child: user.image.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 55,
                        )
                      : null,
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
                  user.phone,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 30),

                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text("Edit Profile"),

                  trailing:
                      const Icon(Icons.arrow_forward_ios),

                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditProfileScreen(user: user),
                      ),
                    );

                    setState(() {
                      userFuture = userService.getUser();
                    });
                  },
                ),

                ListTile(
                  leading:
                      const Icon(Icons.favorite),
                  title:
                      const Text("My Favorites"),

                  trailing:
                      const Icon(Icons.arrow_forward_ios),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FavoritesScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading:
                      const Icon(Icons.logout),
                  title:
                      const Text("Logout"),

                  trailing:
                      const Icon(Icons.arrow_forward_ios),

                  onTap: logout,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}