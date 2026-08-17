import 'dart:convert';
import 'package:app/model/user_model.dart';
import 'package:app/screens/auth/login_screen.dart';
import 'package:app/screens/home/notification_screen.dart';
import 'package:app/screens/profile/edit_profile_screen.dart';
import 'package:app/screens/profile/my_reviews_screen.dart';
import 'package:app/screens/settings/settings_screen.dart';
import 'package:app/services/stats_service.dart';
import 'package:app/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onProfileUpdated;

  const ProfileScreen({super.key, this.onProfileUpdated});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService userService = UserService();
  final StatsService _statsService = StatsService();

  late Future<Map<String, dynamic>> profileFuture;

  void refreshProfile() {
    setState(() {
      profileFuture = Future.wait([
        userService.getUser(),
        _statsService.getUserStats(),
      ]).then((values) => {
        'user': values[0] as UserModel,
        'stats': values[1] as Map<String, int>,
      });
    });
    widget.onProfileUpdated?.call();
  }

  @override
  void initState() {
    super.initState();
    profileFuture = Future.wait([
      userService.getUser(),
      _statsService.getUserStats(),
    ]).then((values) => {
      'user': values[0] as UserModel,
      'stats': values[1] as Map<String, int>,
    });
  }

  Future<void> logout() async {
    // ... (same as your code)
  }

  ImageProvider? _getImageProvider(String image) {
    // ... (same as your code - optional, not used now)
  }

  // ✅ MISSING METHOD – Avatar Fallback
  Widget _buildAvatarFallback(String name) {
    return Container(
      width: 100,
      height: 100,
      color: const Color(0xFF2563EB),
      child: Center(
        child: Text(
          name.isNotEmpty
              ? name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
              : "U",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>>(
        future: profileFuture,
        builder: (context, snapshot) {
          // ... loading, error states (same as your code)

          // ── Success ──
          final data = snapshot.data!;
          final UserModel user = data['user'] as UserModel;
          final Map<String, int> stats = data['stats'] as Map<String, int>;
          final reviews = stats['reviews'] ?? 0;
          final favorites = stats['favorites'] ?? 0;
          final cities = stats['cities'] ?? 0;

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // ── Header ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Profile",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF0F172A),
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF0F172A),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Custom Avatar ──
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          width: 100,
                          height: 100,
                          color: const Color(0xFF2563EB),
                          child: user.image.isNotEmpty
                              ? Image.network(
                                  user.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildAvatarFallback(user.name),
                                  loadingBuilder: (_, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      color: const Color(0xFF2563EB),
                                      child: const Center(
                                        child: SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : _buildAvatarFallback(user.name),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Name, Email, Badge ──
                    Text(
                      user.name,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF0F172A),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF15803D),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Verified Traveler",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF15803D),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Stats Card ──
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(reviews.toString(), "Reviews"),
                          Container(height: 30, width: 1, color: const Color(0xFFF1F5F9)),
                          _buildStatItem(favorites.toString(), "Favorites"),
                          Container(height: 30, width: 1, color: const Color(0xFFF1F5F9)),
                          _buildStatItem(cities.toString(), "Cities"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Menu List ──
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.edit_outlined,
                            iconBgColor: const Color(0xFFEFF6FF),
                            iconColor: const Color(0xFF2563EB),
                            title: "Edit Profile",
                            showDivider: true,
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
                            icon: Icons.notifications_outlined,
                            iconBgColor: const Color(0xFFFEF3C7),
                            iconColor: const Color(0xFFD97706),
                            title: "Notifications",
                            showDivider: true,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NotificationScreen(),
                                ),
                              );
                            },
                          ),
                          _buildMenuItem(
                            icon: Icons.settings_outlined,
                            iconBgColor: const Color(0xFFF3E8FF),
                            iconColor: const Color(0xFF9333EA),
                            title: "Settings",
                            showDivider: true,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SettingsScreen(),
                                ),
                              );
                            },
                          ),
                          _buildMenuItem(
                            icon: Icons.star_outline_rounded,
                            iconBgColor: const Color(0xFFDCFCE7),
                            iconColor: const Color(0xFF16A34A),
                            title: "My Reviews",
                            showDivider: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MyReviewsScreen(),
                                ),
                              );
                            },
                          ),
                          _buildMenuItem(
                            icon: Icons.info_outline_rounded,
                            iconBgColor: const Color(0xFFF1F5F9),
                            iconColor: const Color(0xFF475569),
                            title: "Help & Support",
                            showDivider: true,
                            onTap: () {},
                          ),
                          _buildMenuItem(
                            icon: Icons.logout_rounded,
                            iconBgColor: const Color(0xFFFEE2E2),
                            iconColor: const Color(0xFFDC2626),
                            title: "Sign Out",
                            titleColor: const Color(0xFFDC2626),
                            onTap: logout,
                            showArrow: false,
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Stat Item ──
  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.poppins(
            color: const Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── Menu Item ──
  Widget _buildMenuItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    bool showArrow = true,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: titleColor ?? const Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (showArrow)
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: const Color(0xFFF1F5F9),
            indent: 72,
            endIndent: 16,
          ),
      ],
    );
  }
}