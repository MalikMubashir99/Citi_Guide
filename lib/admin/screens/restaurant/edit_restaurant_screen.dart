import 'dart:io';

import 'package:app/admin/services/city_service.dart';
import 'package:app/admin/services/storage_service.dart';
import 'package:app/model/city_model.dart';
import 'package:app/model/restaurant_model.dart';
import 'package:app/services/restaurant_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditRestaurantScreen extends StatefulWidget {
  final RestaurantModel restaurant;

  const EditRestaurantScreen({super.key, required this.restaurant});

  @override
  State<EditRestaurantScreen> createState() => _EditRestaurantScreenState();
}

class _EditRestaurantScreenState extends State<EditRestaurantScreen> {
  final RestaurantService restaurantService = RestaurantService();

  final CityService cityService = CityService();

  final StorageService storageService = StorageService();

  late TextEditingController nameController;

  late TextEditingController descriptionController;

  late TextEditingController ratingController;

  late TextEditingController phoneController;

  late TextEditingController latitudeController;

  late TextEditingController longitudeController;

  String? selectedCity;

  File? selectedImage;

  bool loading = false;

  String imageUrl = "";

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.restaurant.name);

    descriptionController = TextEditingController(
      text: widget.restaurant.description,
    );

    ratingController = TextEditingController(
      text: widget.restaurant.rating.toString(),
    );

    phoneController = TextEditingController(text: widget.restaurant.phone);

    latitudeController = TextEditingController(
      text: widget.restaurant.latitude.toString(),
    );

    longitudeController = TextEditingController(
      text: widget.restaurant.longitude.toString(),
    );

    selectedCity = widget.restaurant.cityId;

    imageUrl = widget.restaurant.image;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
    });
  }
Future<void> updateRestaurant() async {
  if (selectedCity == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select a city")),
    );
    return;
  }

  if (nameController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter restaurant name")),
    );
    return;
  }

  setState(() {
    loading = true;
  });

  try {
    String finalImageUrl = imageUrl;

    if (selectedImage != null) {
      finalImageUrl = await storageService.uploadImage(
        selectedImage!,
        folder: 'restaurants',
      );
    }

    RestaurantModel restaurant = RestaurantModel(
      id: widget.restaurant.id,
      name: nameController.text.trim(),
      cityId: selectedCity!,
      image: finalImageUrl,
      description: descriptionController.text.trim(),
      rating: double.tryParse(ratingController.text) ?? 0,
      phone: phoneController.text.trim(),
      latitude: double.tryParse(latitudeController.text) ?? 0,
      longitude: double.tryParse(longitudeController.text) ?? 0,
    );

    await restaurantService.updateRestaurant(restaurant);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Restaurant Updated Successfully ✅"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  } catch (e) {
    setState(() => loading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Restaurant")),

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
                  initialValue: selectedCity,

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

            if (selectedImage != null)
              Image.file(selectedImage!, height: 180)
            else if (imageUrl.isNotEmpty)
              Image.network(imageUrl, height: 180),

            ElevatedButton(
              onPressed: pickImage,

              child: const Text("Change Image"),
            ),
            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: loading ? null : updateRestaurant,

                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Update Restaurant"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
