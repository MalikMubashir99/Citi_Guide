// lib/admin/screens/user/users_screen.dart
import 'package:app/admin/services/admin_user_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Direct colors ──
class _AdminColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color dark = Color(0xFF0F172A);
  static const Color darkGrey = Color(0xFF334155);
  static const Color grey = Color(0xFF64748B);
  static const Color lightGrey = Color(0xFFE2E8F0);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
}

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final AdminUserService userService = AdminUserService();
  final TextEditingController searchController = TextEditingController();
  String searchText = "";
  bool _isLoading = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AdminColors.background,
      appBar: AppBar(
        title: Text(
          "Users",
          style: GoogleFonts.poppins(
            color: _AdminColors.dark,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: _AdminColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _AdminColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: _AdminColors.primary),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ──
          _buildSearchBar(),

          // ── Users List ──
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _AdminColors.primary,
                    ),
                  )
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: userService.getUsers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: _AdminColors.primary,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return _buildErrorState(snapshot.error.toString());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState();
                      }

                      // ── Filter users by search ──
                      final users = snapshot.data!.where((user) {
                        final name =
                            user['name']?.toString().toLowerCase() ?? '';
                        final email =
                            user['email']?.toString().toLowerCase() ?? '';
                        return name.contains(searchText.toLowerCase()) ||
                            email.contains(searchText.toLowerCase());
                      }).toList();

                      if (users.isEmpty) {
                        return _buildNoResultsState();
                      }

                      return RefreshIndicator(
                        onRefresh: () async => setState(() {}),
                        color: _AdminColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildUserCard(
                                id: user['id'] ?? '',
                                name: user['name'] ?? 'Unknown',
                                email: user['email'] ?? 'No email',
                                phone: user['phone'] ?? '',
                                image: user['image'] ?? '',
                                isActive: user['isActive'] ?? true,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ──
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: _AdminColors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _AdminColors.background,
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          controller: searchController,
          style: GoogleFonts.poppins(fontSize: 15, color: _AdminColors.dark),
          decoration: InputDecoration(
            hintText: "Search users by name or email...",
            hintStyle: GoogleFonts.poppins(
              color: _AdminColors.grey,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _AdminColors.primary,
              size: 22,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            suffixIcon: searchText.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        searchController.clear();
                        searchText = "";
                      });
                    },
                    icon: Icon(
                      Icons.clear_rounded,
                      color: _AdminColors.grey,
                      size: 20,
                    ),
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildUserCard({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String image,
    bool isActive = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _AdminColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _AdminColors.lightGrey.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Custom Avatar (replaces CircleAvatar) ──
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  width: 56,
                  height: 56,
                  color: _AdminColors.primaryLight,
                  child: image.isNotEmpty
                      ? Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildAvatarFallback(name),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _AdminColors.primary,
                                ),
                              ),
                            );
                          },
                        )
                      : _buildAvatarFallback(name),
                ),
              ),
              // ── Status indicator ──
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isActive ? _AdminColors.success : _AdminColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: _AdminColors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          // ── User Info ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _AdminColors.dark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: _AdminColors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: _AdminColors.darkGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // ── Actions ──
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isActive
                      ? _AdminColors.success.withOpacity(0.08)
                      : _AdminColors.error.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    isActive ? Icons.check_circle_rounded : Icons.block_rounded,
                    color: isActive ? _AdminColors.success : _AdminColors.error,
                    size: 20,
                  ),
                  onPressed: () => _showStatusToggleDialog(id, name, isActive),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  tooltip: isActive ? 'Deactivate' : 'Activate',
                ),
              ),
              const SizedBox(width: 4),
              Container(
                decoration: BoxDecoration(
                  color: _AdminColors.error.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: _AdminColors.error,
                    size: 20,
                  ),
                  onPressed: () => _showDeleteDialog(id, name),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  tooltip: 'Delete',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: _AdminColors.primary,
        ),
      ),
    );
  }

  // ── Helper States ──
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _AdminColors.error.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: _AdminColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading users',
              style: GoogleFonts.poppins(
                color: _AdminColors.dark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: GoogleFonts.poppins(
                color: _AdminColors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
              label: Text(
                "Retry",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _AdminColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _AdminColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_rounded,
                size: 56,
                color: _AdminColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "No Users Found",
              style: GoogleFonts.poppins(
                color: _AdminColors.dark,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Users will appear here once they register",
              style: GoogleFonts.poppins(
                color: _AdminColors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _AdminColors.grey.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: _AdminColors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "No matching users",
              style: GoogleFonts.poppins(
                color: _AdminColors.dark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try adjusting your search",
              style: GoogleFonts.poppins(
                color: _AdminColors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  searchController.clear();
                  searchText = "";
                });
              },
              icon: Icon(
                Icons.clear_all_rounded,
                color: _AdminColors.primary,
                size: 18,
              ),
              label: Text(
                'Clear search',
                style: GoogleFonts.poppins(
                  color: _AdminColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete Confirmation ──
  void _showDeleteDialog(String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: _AdminColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _AdminColors.error.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 40,
                        color: _AdminColors.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Delete User',
                      style: GoogleFonts.poppins(
                        color: _AdminColors.dark,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Are you sure you want to delete "$userName"?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: _AdminColors.darkGrey,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    Text(
                      'This action cannot be undone.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: _AdminColors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isDeleting
                                ? null
                                : () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                color: _AdminColors.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isDeleting
                                ? null
                                : () async {
                                    setDialogState(() => isDeleting = true);
                                    try {
                                      await userService.deleteUser(userId);
                                      if (!mounted) return;
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '✅ User deleted successfully',
                                            style: GoogleFonts.poppins(),
                                          ),
                                          backgroundColor: _AdminColors.success,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                      setState(() {});
                                    } catch (e) {
                                      setDialogState(() => isDeleting = false);
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '❌ Error: $e',
                                            style: GoogleFonts.poppins(),
                                          ),
                                          backgroundColor: _AdminColors.error,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDeleting
                                  ? _AdminColors.grey
                                  : _AdminColors.error,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: isDeleting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Delete',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Status Toggle Dialog ──
  void _showStatusToggleDialog(String userId, String userName, bool isActive) {
    final newStatus = !isActive;
    final action = newStatus ? 'Activate' : 'Deactivate';

    showDialog(
      context: context,
      builder: (context) {
        bool isProcessing = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: _AdminColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            (newStatus
                                    ? _AdminColors.success
                                    : _AdminColors.error)
                                .withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        newStatus
                            ? Icons.check_circle_rounded
                            : Icons.block_rounded,
                        size: 40,
                        color: newStatus
                            ? _AdminColors.success
                            : _AdminColors.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$action User',
                      style: GoogleFonts.poppins(
                        color: _AdminColors.dark,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Are you sure you want to $action "$userName"?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: _AdminColors.darkGrey,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isProcessing
                                ? null
                                : () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                color: _AdminColors.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isProcessing
                                ? null
                                : () async {
                                    setDialogState(() => isProcessing = true);
                                    try {
                                      await userService.updateUserStatus(
                                        userId: userId,
                                        isActive: newStatus,
                                      );
                                      if (!mounted) return;
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '✅ User ${action}d successfully',
                                            style: GoogleFonts.poppins(),
                                          ),
                                          backgroundColor: _AdminColors.success,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                      setState(() {});
                                    } catch (e) {
                                      setDialogState(
                                        () => isProcessing = false,
                                      );
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '❌ Error: $e',
                                            style: GoogleFonts.poppins(),
                                          ),
                                          backgroundColor: _AdminColors.error,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: newStatus
                                  ? _AdminColors.success
                                  : _AdminColors.error,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: isProcessing
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    action,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
