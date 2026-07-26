// lib/admin/screens/city/add_city_screen.dart
import 'package:app/admin/models/city_model.dart';
import 'package:app/admin/services/city_service.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AddCityScreen extends StatefulWidget {
  const AddCityScreen({super.key});

  @override
  State<AddCityScreen> createState() => _AddCityScreenState();
}

class _AddCityScreenState extends State<AddCityScreen> {
  final CityService cityService = CityService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool loading = false;

  Future<void> saveCity() async {
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
      // ✅ Create CityModel object
      final city = CityModel(
        id: '', // Will be auto-generated
        name: nameController.text.trim(),
        image: imageController.text.trim(),
        description: descriptionController.text.trim(),
      );

      // ✅ Pass the CityModel object
      await cityService.addCity(city);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ City Added Successfully"),
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
          "Add City",
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
                onPressed: loading ? null : saveCity,
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
                        "Save City",
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