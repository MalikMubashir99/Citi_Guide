import 'dart:io';

import 'package:app/admin/services/storage_service.dart';
import 'package:app/model/city_model.dart';
import 'package:app/services/city_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/attraction_service.dart';

class AddAttractionScreen extends StatefulWidget {
   AddAttractionScreen({super.key});

  @override
  State<AddAttractionScreen> createState() => _AddAttractionScreenState();

  final CityService cityService = CityService();
  final StorageService storageService = StorageService();
}

class _AddAttractionScreenState extends State<AddAttractionScreen> {
  final AttractionService attractionService = AttractionService();

  final nameController = TextEditingController();
  String? selectedCityId;
  File? selectedImage;
  final descriptionController = TextEditingController();
  final ratingController = TextEditingController();
  final openingHoursController = TextEditingController();
  final phoneController = TextEditingController();
  final websiteController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    ratingController.dispose();
    openingHoursController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  Future<void> saveAttraction() async {
    if (nameController.text.isEmpty || selectedCityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      // ✅ Upload image first (if selected)
      String imageUrl = "";
      if (selectedImage != null) {
        imageUrl = await widget.storageService.uploadImage(selectedImage!);
      }

      // ✅ Then add attraction with all required parameters
      await attractionService.addAttraction(
        name: nameController.text.trim(),
        cityId: selectedCityId!,
        description: descriptionController.text.trim(),
        image: imageUrl,
        rating: double.tryParse(ratingController.text) ?? 0,
        openingHours: openingHoursController.text.trim(),
        phone: phoneController.text.trim(),
        website: websiteController.text.trim(),
        latitude: double.tryParse(latitudeController.text) ?? 0,
        longitude: double.tryParse(longitudeController.text) ?? 0,
      );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attraction Added Successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
    });
  }

  Widget buildField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Attraction")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildField("Name", nameController),

            FutureBuilder<List<CityModel>>(
              future: widget.cityService.getCities(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No cities available');
                }

                return DropdownButtonFormField<String>(
                  // ✅ Fixed: initialValue instead of value
                  initialValue: selectedCityId,
                  decoration: const InputDecoration(
                    labelText: "Select City",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  items: snapshot.data!.map((city) {
                    return DropdownMenuItem(
                      value: city.id,
                      child: Text(city.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCityId = value;
                    });
                  },
                );
              },
            ),

            buildField("Description", descriptionController),

            Column(
              children: [
                if (selectedImage != null)
                  Image.file(selectedImage!, height: 180, fit: BoxFit.cover),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Choose Image"),
                  ),
                ),
              ],
            ),

            buildField("Rating", ratingController,
                keyboardType: TextInputType.number),
            buildField("Opening Hours", openingHoursController),
            buildField("Phone", phoneController),
            buildField("Website", websiteController),
            buildField("Latitude", latitudeController,
                keyboardType: TextInputType.number),
            buildField("Longitude", longitudeController,
                keyboardType: TextInputType.number),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : saveAttraction,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}