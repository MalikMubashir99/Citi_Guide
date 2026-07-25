import 'package:flutter/material.dart';
import '../../model/user_model.dart';
import '../../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  final VoidCallback? onProfileUpdated; // ✅ Add callback

  const EditProfileScreen({
    super.key,
    required this.user,
    this.onProfileUpdated,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserService userService = UserService();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> updateProfile() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name is too short")),
      );
      return;
    }

    if (phone.isNotEmpty && phone.length < 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid phone number")),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await userService.updateUser(
        name: name,
        phone: phone,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated")),
      );

      // ✅ Call callback to refresh profile
      widget.onProfileUpdated?.call();

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : updateProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Save Changes",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}