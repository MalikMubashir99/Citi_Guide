// lib/screens/profile/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;

  // Local color constants replacing AppColors
  static const Color _bgColor = Color(0xFFF8F9FA);
  static const Color _surfaceColor = Colors.white;
  static const Color _darkColor = Color(0xFF1A1A1A);
  static const Color _darkGreyColor = Color(0xFF666666);
  static const Color _greyColor = Color(0xFF9E9E9E);
  static const Color _lightGreyColor = Color(0xFFE0E0E0);
  static const Color _primaryColor = Colors.blue;
  static const Color _errorColor = Colors.red;

  static final List<BoxShadow> _subtleShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            color: _darkColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: _bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _darkColor),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: _lightGreyColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // ── Appearance ──
          _buildSectionHeader("Appearance"),
          const SizedBox(height: 8),
          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: "Dark Mode",
            subtitle: "Switch between light and dark theme",
            value: isDarkMode,
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
              });
              // TODO: Apply theme
            },
          ),

          const SizedBox(height: 20),

          // ── Account ──
          _buildSectionHeader("Account"),
          const SizedBox(height: 8),
          _buildSettingsTile(
            icon: Icons.person_outline_rounded,
            title: "Edit Profile",
            subtitle: "Update your personal information",
            onTap: () {
              // Navigate to edit profile
            },
          ),
          _buildSettingsTile(
            icon: Icons.email_outlined,
            title: "Change Email",
            subtitle: "Update your email address",
            onTap: () {
              // Navigate to change email
            },
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline_rounded,
            title: "Change Password",
            subtitle: "Update your password",
            onTap: () {
              // Navigate to change password
            },
          ),

          const SizedBox(height: 20),

          // ── Preferences ──
          _buildSectionHeader("Preferences"),
          const SizedBox(height: 8),
          _buildSettingsTile(
            icon: Icons.language_outlined,
            title: "Language",
            subtitle: "English",
            onTap: () {
              // Show language selector
            },
          ),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: "Notifications",
            subtitle: "Manage notification settings",
            onTap: () {
              // Navigate to notification settings
            },
          ),

          const SizedBox(height: 20),

          // ── Support ──
          _buildSectionHeader("Support"),
          const SizedBox(height: 8),
          _buildSettingsTile(
            icon: Icons.help_outline_rounded,
            title: "Help & Support",
            subtitle: "Get help or contact support",
            onTap: () {
              // Navigate to help
            },
          ),
          _buildSettingsTile(
            icon: Icons.info_outline_rounded,
            title: "About",
            subtitle: "Version 1.0.0",
            onTap: () {
              // Show about dialog
            },
          ),

          const SizedBox(height: 24),

          // ── Logout ──
          _buildSettingsTile(
            icon: Icons.logout_rounded,
            title: "Logout",
            subtitle: "Sign out of your account",
            onTap: () {
              _showLogoutDialog(context);
            },
            isDestructive: true,
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ── Section Header ──
  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: _greyColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  // ── Settings Tile ──
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final iconColor = isDestructive ? _errorColor : _primaryColor;
    final titleColor = isDestructive ? _errorColor : _darkColor;
    final subtitleColor = isDestructive
        ? _errorColor.withValues(alpha: 0.6)
        : _darkGreyColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDestructive
              ? _errorColor.withValues(alpha: 0.15)
              : _lightGreyColor.withValues(alpha: 0.5),
        ),
        boxShadow: isDestructive ? null : _subtleShadow,
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
                // Icon Container
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
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDestructive
                      ? _errorColor.withValues(alpha: 0.5)
                      : _greyColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Switch Tile ──
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _lightGreyColor.withValues(alpha: 0.5),
        ),
        boxShadow: _subtleShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: _primaryColor,
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
                    style: const TextStyle(
                      color: _darkColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _darkGreyColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Switch
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: _primaryColor,
              inactiveThumbColor: _surfaceColor,
              inactiveTrackColor: _lightGreyColor,
            ),
          ],
        ),
      ),
    );
  }

  // ── Logout Dialog ──
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: _surfaceColor,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _errorColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: _errorColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Logout",
                style: TextStyle(
                  color: _darkColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _darkGreyColor,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _darkGreyColor,
                        side: const BorderSide(color: _lightGreyColor),
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
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!context.mounted) return;
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _errorColor,
                        foregroundColor: Colors.white,
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
  }
}