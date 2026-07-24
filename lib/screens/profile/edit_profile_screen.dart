import 'package:flutter/material.dart';

import '../../model/user_model.dart';
import '../../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {

  final UserService userService = UserService();

  late TextEditingController nameController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.user.name);

    phoneController =
        TextEditingController(text: widget.user.phone);
  }

  Future<void> updateProfile() async {

    if (nameController.text.trim().isEmpty) {
      return;
    }

    await userService.updateUser(

      name: nameController.text.trim(),

      phone: phoneController.text.trim(),

    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile Updated"),
      ),
    );

    Navigator.pop(context);

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(

              controller: nameController,

              decoration: const InputDecoration(
                labelText: "Name",
              ),

            ),

            const SizedBox(height: 20),

            TextField(

              controller: phoneController,

              keyboardType: TextInputType.phone,

              decoration: const InputDecoration(
                labelText: "Phone",
              ),

            ),

            const SizedBox(height: 30),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed: updateProfile,

                child: const Text(
                  "Save Changes",
                ),

              ),

            ),

          ],

        ),

      ),

    );

  }
}