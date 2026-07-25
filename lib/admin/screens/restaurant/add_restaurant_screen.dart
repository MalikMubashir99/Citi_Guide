import 'dart:io';

import 'package:app/admin/services/city_service.dart';
import 'package:app/admin/services/storage_service.dart';
import 'package:app/model/city_model.dart';
import 'package:app/model/restaurant_model.dart';
import 'package:app/services/restaurant_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class AddRestaurantScreen extends StatefulWidget {
  const AddRestaurantScreen({super.key});

  @override
  State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final RestaurantService restaurantService = RestaurantService();

  final CityService cityService = CityService();

  final StorageService storageService = StorageService();

  final nameController = TextEditingController();

  final descriptionController = TextEditingController();

  final ratingController = TextEditingController();

  final phoneController = TextEditingController();

  final latitudeController = TextEditingController();

  final longitudeController = TextEditingController();

  String? selectedCity;

  File? selectedImage;

  bool loading = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
    });
  }

  Future<void> saveRestaurant() async {
    if (selectedCity == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select City")));

      return;
    }

    setState(() {
      loading = true;
    });

    String imageUrl = "";

    if (selectedImage != null) {
      imageUrl = await storageService.uploadImage(selectedImage!);
    }

    RestaurantModel restaurant = RestaurantModel(
      id: "",

      name: nameController.text.trim(),

      cityId: selectedCity!,

      image: imageUrl,

      description: descriptionController.text.trim(),

      rating: double.tryParse(ratingController.text) ?? 0,

      phone: phoneController.text.trim(),

      latitude: double.tryParse(latitudeController.text) ?? 0,

      longitude: double.tryParse(longitudeController.text) ?? 0,
    );

    await restaurantService.addRestaurant(restaurant);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Restaurant")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            StreamBuilder<List<CityModel>>(
              stream: cityService.getCities(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                return DropdownButtonFormField<String>(
                  value: selectedCity,

                  decoration: const InputDecoration(labelText: "City"),

                  items: snapshot.data!.map((city) {
                    return DropdownMenuItem(
                      value: city.id,

                      child: Text(city.name),
                    );
                  }).toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedCity = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 15),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Restaurant Name"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: ratingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Rating"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: latitudeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Latitude"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: longitudeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Longitude"),
            ),
            const SizedBox(height: 20),

            if (selectedImage != null) Image.file(selectedImage!, height: 180),

            ElevatedButton(
              onPressed: pickImage,

              child: const Text("Choose Image"),
            ),
            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: loading ? null : saveRestaurant,

                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Save Restaurant"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
