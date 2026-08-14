import 'dart:convert';
import 'package:app/model/user_model.dart';
import 'package:app/screens/auth/login_screen.dart';
import 'package:app/screens/profile/edit_profile_screen.dart';
import 'package:app/screens/profile/my_reviews_screen.dart';
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

  // Combined future for user + stats
  late Future<Map<String, dynamic>> profileFuture;

  void refreshProfile() {
    setState(() {
      profileFuture =
          Future.wait([
            userService.getUser(),
            _statsService.getUserStats(),
          ]).then(
            (values) => {
              'user': values[0] as UserModel,
              'stats': values[1] as Map<String, int>,
            },
          );
    });
    widget.onProfileUpdated?.call();
  }

  @override
  void initState() {
    super.initState();
    // Load both user and stats at the same time
    profileFuture =
        Future.wait([userService.getUser(), _statsService.getUserStats()]).then(
          (values) => {
            'user': values[0] as UserModel,
            'stats': values[1] as Map<String, int>,
          },
        );
  }

  Future<void> logout() async {
    bool? result = await showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFDC2626),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Sign Out",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to sign out?",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF64748B),
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
                        foregroundColor: const Color(0xFF64748B),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("Cancel", style: GoogleFonts.poppins()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("Sign Out", style: GoogleFonts.poppins()),
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
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>>(
        future: profileFuture,
        builder: (context, snapshot) {
          // ── Loading State ──
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Loading profile...",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          // ── Error State ──
          if (snapshot.hasError || !snapshot.hasData) {
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
                        color: const Color(0xFFDC2626).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        size: 36,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Something went wrong",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      snapshot.error?.toString() ?? 'Unknown error',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: refreshProfile,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text("Try Again", style: GoogleFonts.poppins()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
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

          // ── Success: extract data ──
          final data = snapshot.data!;
          final UserModel user = data['user'] as UserModel;
          final Map<String, int> stats = data['stats'] as Map<String, int>;

          // Safe stats with fallback to 0
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
                    // ── Custom Header Bar ──
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

                    // ── Profile Avatar ──
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
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _getImageProvider(user.image),
                        backgroundColor: const Color(0xFF2563EB),
                        child: user.image.isEmpty
                            ? Text(
                                user.name.isNotEmpty
                                    ? user.name
                                          .trim()
                                          .split(' ')
                                          .map((e) => e[0])
                                          .take(2)
                                          .join()
                                          .toUpperCase()
                                    : "U",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                        onBackgroundImageError: (_, __) {
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Name
                    Text(
                      user.name,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF0F172A),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Email
                    Text(
                      user.email,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Verified Traveler Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
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

                    // ── DYNAMIC STATS CARD ──
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1.5,
                        ),
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
                          Container(
                            height: 30,
                            width: 1,
                            color: const Color(0xFFF1F5F9),
                          ),
                          _buildStatItem(favorites.toString(), "Favorites"),
                          Container(
                            height: 30,
                            width: 1,
                            color: const Color(0xFFF1F5F9),
                          ),
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
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1.5,
                        ),
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
                            onTap: () {},
                          ),
                          _buildMenuItem(
                            icon: Icons.settings_outlined,
                            iconBgColor: const Color(0xFFF3E8FF),
                            iconColor: const Color(0xFF9333EA),
                            title: "Settings",
                            showDivider: true,
                            onTap: () {},
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

  // ── Stat Item Builder ──
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

  // ── Menu Item Builder ──
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
