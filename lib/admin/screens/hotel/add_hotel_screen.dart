import 'dart:io';

import 'package:app/admin/services/city_service.dart';
import 'package:app/admin/services/storage_service.dart';
import 'package:app/model/city_model.dart';
import 'package:app/model/hotel_model.dart';
import 'package:app/services/hotel_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
class AddHotelScreen extends StatefulWidget {
  const AddHotelScreen({super.key});

  @override
  State<AddHotelScreen> createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen> {
  final HotelService hotelService = HotelService();

  final CityService cityService = CityService();

  final StorageService storageService = StorageService();

  final nameController = TextEditingController();

  final descriptionController = TextEditingController();

  final phoneController = TextEditingController();

  final websiteController = TextEditingController();

  final ratingController = TextEditingController();

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

  Future<void> saveHotel() async {
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

    HotelModel hotel = HotelModel(
      id: "",

      cityId: selectedCity!,

      name: nameController.text.trim(),

      description: descriptionController.text.trim(),

      image: imageUrl,

      rating: double.tryParse(ratingController.text) ?? 0,

      phone: phoneController.text.trim(),

      website: websiteController.text.trim(),
    );

    await hotelService.addHotel(hotel);

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Hotel")),

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

              decoration: const InputDecoration(labelText: "Hotel Name"),
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

              decoration: const InputDecoration(labelText: "Phone"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: websiteController,

              decoration: const InputDecoration(labelText: "Website"),
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
                onPressed: loading ? null : saveHotel,

                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Save Hotel"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
