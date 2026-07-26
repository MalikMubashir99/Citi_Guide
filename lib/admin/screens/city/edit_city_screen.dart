// lib/admin/screens/city/edit_city_screen.dart
import 'package:app/admin/models/city_model.dart';
import 'package:app/admin/services/city_service.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class EditCityScreen extends StatefulWidget {
  final CityModel city;

  const EditCityScreen({
    super.key,
    required this.city,
  });

  @override
  State<EditCityScreen> createState() => _EditCityScreenState();
}

class _EditCityScreenState extends State<EditCityScreen> {
  final CityService cityService = CityService();

  late TextEditingController nameController;
  late TextEditingController imageController;
  late TextEditingController descriptionController;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.city.name);
    imageController = TextEditingController(text: widget.city.image);
    descriptionController = TextEditingController(text: widget.city.description);
  }

  @override
  void dispose() {
    nameController.dispose();
    imageController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> updateCity() async {
    if (nameController.text.trim().isEmpty ||
        imageController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      // ✅ Create CityModel object with updated values
      final city = CityModel(
        id: widget.city.id,
        name: nameController.text.trim(),
        image: imageController.text.trim(),
        description: descriptionController.text.trim(),
      );

      // ✅ Pass the CityModel object
      await cityService.updateCity(city);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ City Updated Successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        loading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error: $e"),
          backgroundColor: Colors.red,
        ),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Edit City",
          style: TextStyle(
            color: AppColors.dark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "City Name",
                labelStyle: TextStyle(color: AppColors.darkGrey),
                prefixIcon: Icon(Icons.location_city_rounded, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.lightGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.lightGrey),
                ),
                filled: true,
                fillColor: AppColors.white,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: imageController,
              decoration: InputDecoration(
                labelText: "Image URL",
                labelStyle: TextStyle(color: AppColors.darkGrey),
                prefixIcon: Icon(Icons.image_rounded, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.lightGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.lightGrey),
                ),
                filled: true,
                fillColor: AppColors.white,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Description",
                labelStyle: TextStyle(color: AppColors.darkGrey),
                prefixIcon: Icon(Icons.description_rounded, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.lightGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.lightGrey),
                ),
                filled: true,
                fillColor: AppColors.white,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: loading ? null : updateCity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Update City",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}