import 'dart:io';

import 'package:app/admin/services/city_service.dart';
import 'package:app/admin/services/storage_service.dart';
import 'package:app/model/city_model.dart';
import 'package:app/model/hotel_model.dart';
import 'package:app/services/hotel_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class EditHotelScreen extends StatefulWidget {
  final HotelModel hotel;

  const EditHotelScreen({
    super.key,
    required this.hotel,
  });

  @override
  State<EditHotelScreen> createState() => _EditHotelScreenState();
}

class _EditHotelScreenState extends State<EditHotelScreen> {
  final HotelService hotelService = HotelService();
  final CityService cityService = CityService();
  final StorageService storageService = StorageService();

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController ratingController;
  late TextEditingController phoneController;
  late TextEditingController websiteController;

  String? selectedCity;
  File? selectedImage;
  bool loading = false;
  String imageUrl = "";

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with hotel data
    nameController = TextEditingController(text: widget.hotel.name);
    descriptionController = TextEditingController(text: widget.hotel.description);
    ratingController = TextEditingController(text: widget.hotel.rating.toString());
    phoneController = TextEditingController(text: widget.hotel.phone);
    websiteController = TextEditingController(text: widget.hotel.website);
    
    // Set initial values
    selectedCity = widget.hotel.cityId;
    imageUrl = widget.hotel.image;
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    nameController.dispose();
    descriptionController.dispose();
    ratingController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
    });
  }

  Future<void> updateHotel() async {
    if (selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a city")),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      String finalImageUrl = imageUrl;
      
      // Upload new image if selected
      if (selectedImage != null) {
        finalImageUrl = await storageService.uploadImage(selectedImage!);
      }

      HotelModel hotel = HotelModel(
        id: widget.hotel.id,
        cityId: selectedCity!,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        image: finalImageUrl,
        rating: double.tryParse(ratingController.text) ?? 0,
        phone: phoneController.text.trim(),
        website: websiteController.text.trim(),
      );

      await hotelService.updateHotel(hotel);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hotel Updated Successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Hotel"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // City Dropdown
            StreamBuilder<List<CityModel>>(
              stream: cityService.getCities(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No cities available");
                }

                return DropdownButtonFormField<String>(
                  value: selectedCity,
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

            // Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Hotel Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Description
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

            // Rating
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

            // Phone
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Website
            TextField(
              controller: websiteController,
              decoration: const InputDecoration(
                labelText: "Website",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Image preview
            if (selectedImage != null)
              Image.file(
                selectedImage!,
                height: 180,
                fit: BoxFit.cover,
              )
            else if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image,
                  size: 180,
                ),
              ),

            const SizedBox(height: 15),

            // Change Image button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text("Change Image"),
              ),
            ),

            const SizedBox(height: 25),

            // Update button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : updateHotel,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Update Hotel"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}