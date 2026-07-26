import 'dart:convert';
import 'dart:io';
import 'package:app/admin/models/city_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:app/admin/services/city_service.dart';
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

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final ratingController = TextEditingController();
  final phoneController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  String? selectedCity;

  // ✅ Local image only
  String? _imagePath;
  File? _imageFile;

  bool loading = false;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    ratingController.dispose();
    phoneController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  // ✅ Pick Image - Local only
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      setState(() {
        _imagePath = base64String;
        _imageFile = null;
      });
    } else {
      final File file = File(image.path);
      setState(() {
        _imagePath = file.path;
        _imageFile = file;
      });
    }
  }

  // ✅ Remove image
  void removeImage() {
    setState(() {
      _imagePath = null;
      _imageFile = null;
    });
  }

  Future<void> saveRestaurant() async {
    if (selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select City")),
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
      // ✅ Store local path only
      String finalImage = _imagePath ?? '';

      RestaurantModel restaurant = RestaurantModel(
        id: "",
        name: nameController.text.trim(),
        cityId: selectedCity!,
        image: finalImage,
        description: descriptionController.text.trim(),
        rating: double.tryParse(ratingController.text) ?? 0,
        phone: phoneController.text.trim(),
        latitude: double.tryParse(latitudeController.text) ?? 0,
        longitude: double.tryParse(longitudeController.text) ?? 0,
      );

      await restaurantService.addRestaurant(restaurant);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Restaurant Added Successfully ✅"),
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
                  initialValue: selectedCity,
                  decoration: const InputDecoration(
                    labelText: "City",
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
                      selectedCity = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 15),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Restaurant Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: ratingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Rating",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 15),

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

            const SizedBox(height: 15),

            TextField(
              controller: latitudeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Latitude",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: longitudeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Longitude",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Image Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (_imagePath != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb
                              ? Image.memory(
                                  base64Decode(_imagePath!.split(',').last),
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_imagePath!),
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 16,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, size: 16),
                              onPressed: removeImage,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              "No image selected",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Choose Image"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
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