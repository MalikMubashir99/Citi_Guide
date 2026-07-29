// lib/admin/screens/user/users_screen.dart
import 'package:app/admin/services/admin_user_service.dart';
import 'package:flutter/material.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final AdminUserService userService = AdminUserService();
  final TextEditingController searchController = TextEditingController();
  String searchText = "";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users"),
        elevation: 0,
        actions: [
          // ✅ Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Search Bar
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search Users by name or email...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchText = "";
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
            ),
          ),
          
          // ✅ Users List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: userService.getUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 10),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {});
                          },
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 80, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          "No Users Found",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Users will appear here once they register",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // ✅ Filter users by search
                final users = snapshot.data!.where((user) {
                  final name = user['name']?.toString().toLowerCase() ?? '';
                  final email = user['email']?.toString().toLowerCase() ?? '';
                  return name.contains(searchText) || 
                         email.contains(searchText);
                }).toList();

                if (users.isEmpty) {
                  return const Center(
                    child: Text(
                      "No matching users found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _buildUserCard(
                      id: user['id'] ?? '',
                      name: user['name'] ?? 'Unknown',
                      email: user['email'] ?? 'No email',
                      phone: user['phone'] ?? '',
                      image: user['image'] ?? '',
                      isActive: user['isActive'] ?? true,
                    );
                  },
                );
              },
            ),
          ),
        ],
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: image.isNotEmpty
                  ? NetworkImage(image)
                  : null,
              backgroundColor: Colors.grey.shade200,
              child: image.isEmpty
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    )
                  : null,
            ),
            // ✅ Active status indicator
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isActive ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              email,
              style: const TextStyle(fontSize: 13),
            ),
            if (phone.isNotEmpty)
              Text(
                phone,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDeleteDialog(context, id, name);
              },
              tooltip: 'Delete User',
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Delete confirmation dialog
  void _showDeleteDialog(BuildContext context, String userId, String userName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete User"),
        content: Text("Delete $userName permanently?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await userService.deleteUser(userId);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("User Deleted Successfully"),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ✅ Status toggle dialog
  void _showStatusToggleDialog(
    BuildContext context,
    String userId,
    String userName,
    bool isActive,
  ) {
    final newStatus = !isActive;
    final action = newStatus ? 'Activate' : 'Deactivate';
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("$action User"),
        content: Text("$action $userName?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await userService.updateUserStatus(
                  userId: userId,
                  isActive: newStatus,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("User ${action}d Successfully"),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(action),
          ),
        ],
      ),
    );
  }
}