// lib/screens/profile/profile_screen.dart
import 'dart:convert';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/model/user_model.dart';
import 'package:app/screens/auth/login_screen.dart';
import 'package:app/screens/profile/edit_profile_screen.dart';
import 'package:app/screens/profile/favorites_screen.dart';
import 'package:app/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onProfileUpdated;

  const ProfileScreen({super.key, this.onProfileUpdated});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService userService = UserService();

  late Future<UserModel> userFuture;

  void refreshProfile() {
    setState(() {
      userFuture = userService.getUser();
    });
    widget.onProfileUpdated?.call();
  }

  @override
  void initState() {
    super.initState();
    userFuture = userService.getUser();
  }

  Future<void> logout() async {
    bool? result = await showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Logout",
                style: TextStyle(
                  color: AppColors.dark,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.darkGrey,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkGrey,
                        side: const BorderSide(color: AppColors.lightGrey),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Logout"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

  ImageProvider? _getImageProvider(String image) {
    if (image.isEmpty) return null;

    try {
      if (!image.startsWith('data:image') && image.length > 100) {
        final bytes = base64Decode(image);
        return MemoryImage(bytes);
      }

      if (image.startsWith('data:image')) {
        final base64String = image.split(',').last;
        final bytes = base64Decode(base64String);
        return MemoryImage(bytes);
      }

      return NetworkImage(image);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            color: AppColors.dark,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.dark),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.lightGrey,
          ),
        ),
      ),
      body: FutureBuilder<UserModel>(
        future: userFuture,
        builder: (context, snapshot) {
          // ── Loading State ──
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Loading profile...",
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          // ── Error State ──
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        size: 36,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Something went wrong",
                      style: TextStyle(
                        color: AppColors.dark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: refreshProfile,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text("Try Again"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ── No Data ──
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off_rounded,
                    size: 48,
                    color: AppColors.grey,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "User not found",
                    style: TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          }

          UserModel user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                // ── Profile Header Card ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppColors.mediumShadow,
                    border: Border.all(
                      color: AppColors.lightGrey.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      GestureDetector(
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
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.goldenGradient,
                                boxShadow: AppColors.warmGlow,
                              ),
                              child: CircleAvatar(
                                radius: 58,
                                backgroundImage: _getImageProvider(user.image),
                                backgroundColor: AppColors.primarySurface,
                                child: user.image.isEmpty
                                    ? Icon(
                                        Icons.person_rounded,
                                        size: 52,
                                        color: AppColors.grey,
                                      )
                                    : null,
                                onBackgroundImageError: (_, __) {
                                  setState(() {});
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.surface,
                                    width: 3,
                                  ),
                                  boxShadow: AppColors.subtleShadow,
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  size: 15,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Name
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: AppColors.dark,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Email
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 15,
                            color: AppColors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            user.email,
                            style: TextStyle(
                              color: AppColors.darkGrey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Phone
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 15,
                            color: AppColors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            user.phone.isNotEmpty
                                ? user.phone
                                : "No phone number",
                            style: TextStyle(
                              color: user.phone.isNotEmpty
                                  ? AppColors.darkGrey
                                  : AppColors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Menu Section ──
                _buildSectionLabel("Account"),
                const SizedBox(height: 8),

                _buildMenuItem(
                  icon: Icons.person_outline_rounded,
                  title: "Edit Profile",
                  subtitle: "Update your personal information",
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
                  icon: Icons.favorite_border_rounded,
                  title: "My Favorites",
                  subtitle: "View your saved places",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FavoritesScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
                _buildSectionLabel("Preferences"),
                const SizedBox(height: 8),

                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  title: "Settings",
                  subtitle: "App preferences and notifications",
                  onTap: () {
                    // Navigate to settings screen
                  },
                ),

                const SizedBox(height: 20),

                // ── Logout Button ──
                _buildMenuItem(
                  icon: Icons.logout_rounded,
                  title: "Logout",
                  subtitle: "Sign out of your account",
                  onTap: logout,
                  isDestructive: true,
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Section Label ──
  Widget _buildSectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: AppColors.grey,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  // ── Menu Item ──
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
    bool isDestructive = false,
  }) {
    final iconColor =
        isDestructive ? AppColors.error : AppColors.primary;
    final titleColor =
        isDestructive ? AppColors.error : AppColors.dark;
    final subtitleColor =
        isDestructive ? AppColors.error.withValues(alpha: 0.6) : AppColors.darkGrey;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDestructive
              ? AppColors.error.withValues(alpha: 0.15)
              : AppColors.lightGrey.withValues(alpha: 0.5),
        ),
        boxShadow: isDestructive ? null : AppColors.subtleShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDestructive
                      ? AppColors.error.withValues(alpha: 0.5)
                      : AppColors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}