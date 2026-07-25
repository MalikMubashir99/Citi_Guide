// lib/screens/profile/settings_screen.dart
import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          // Appearance
          _buildSectionHeader("Appearance"),
          _buildSwitchTile(
            icon: Icons.dark_mode,
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

          // Account
          _buildSectionHeader("Account"),
          _buildSettingsTile(
            icon: Icons.person,
            title: "Edit Profile",
            subtitle: "Update your personal information",
            onTap: () {
              // Navigate to edit profile
            },
          ),
          _buildSettingsTile(
            icon: Icons.email,
            title: "Change Email",
            subtitle: "Update your email address",
            onTap: () {
              // Navigate to change email
            },
          ),
          _buildSettingsTile(
            icon: Icons.lock,
            title: "Change Password",
            subtitle: "Update your password",
            onTap: () {
              // Navigate to change password
            },
          ),

          // Preferences
          _buildSectionHeader("Preferences"),
          _buildSettingsTile(
            icon: Icons.language,
            title: "Language",
            subtitle: "English",
            onTap: () {
              // Show language selector
            },
          ),
          _buildSettingsTile(
            icon: Icons.notifications,
            title: "Notifications",
            subtitle: "Manage notification settings",
            onTap: () {
              // Navigate to notification settings
            },
          ),

          // Support
          _buildSectionHeader("Support"),
          _buildSettingsTile(
            icon: Icons.help,
            title: "Help & Support",
            subtitle: "Get help or contact support",
            onTap: () {
              // Navigate to help
            },
          ),
          _buildSettingsTile(
            icon: Icons.info,
            title: "About",
            subtitle: "Version 1.0.0",
            onTap: () {
              // Show about dialog
            },
          ),

          // Logout
          const Divider(height: 30),
          _buildSettingsTile(
            icon: Icons.logout,
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xff0984E3),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}