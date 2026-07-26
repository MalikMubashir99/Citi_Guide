// lib/admin/screens/hotel/edit_hotel_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:app/admin/models/city_model.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:app/admin/services/city_service.dart';
import 'package:app/admin/models/hotel_model.dart';
import 'package:app/admin/services/hotel_service.dart';
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

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController ratingController;
  late TextEditingController phoneController;
  late TextEditingController websiteController;

  String? selectedCity;
  bool loading = false;

  // ✅ Local image only
  String? _imagePath;
  // ✅ Removed unused _imageFile
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.hotel.name);
    descriptionController = TextEditingController(text: widget.hotel.description);
    ratingController = TextEditingController(text: widget.hotel.rating.toString());
    phoneController = TextEditingController(text: widget.hotel.phone);
    websiteController = TextEditingController(text: widget.hotel.website);

    selectedCity = widget.hotel.cityId;
    _existingImageUrl = widget.hotel.image;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    ratingController.dispose();
    phoneController.dispose();
    websiteController.dispose();
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
      });
    } else {
      final File file = File(image.path);
      setState(() {
        _imagePath = file.path;
      });
    }
  }

  // ✅ Remove image
  void removeImage() {
    setState(() {
      _imagePath = null;
      _existingImageUrl = null;
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
      // ✅ Use new image if selected, otherwise keep existing
      String finalImageUrl = _existingImageUrl ?? '';
      
      if (_imagePath != null) {
        finalImageUrl = _imagePath!;
      }

      // ✅ Fixed: Added all required fields
      HotelModel hotel = HotelModel(
        id: widget.hotel.id,
        cityId: selectedCity!,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        image: finalImageUrl,
        rating: double.tryParse(ratingController.text) ?? 0,
        phone: phoneController.text.trim(),
        website: websiteController.text.trim(),
        // ✅ Added required fields
        createdAt: widget.hotel.createdAt,
        updatedAt: DateTime.now(),
        isFeatured: widget.hotel.isFeatured,
        isActive: widget.hotel.isActive,
        views: widget.hotel.views,
        bookings: widget.hotel.bookings,
      );

      await hotelService.updateHotel(hotel);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hotel Updated Successfully ✅")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Edit Hotel",
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
        actions: [
          IconButton(
            icon: Icon(Icons.delete_rounded, color: AppColors.error),
            onPressed: () {
              _confirmDelete();
            },
          ),
        ],
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
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: const Text(
                      "No cities available",
                      style: TextStyle(color: AppColors.grey),
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  value: selectedCity,
                  decoration: InputDecoration(
                    labelText: "City",
                    labelStyle: TextStyle(color: AppColors.darkGrey),
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

            // Name Field
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Hotel Name",
                labelStyle: TextStyle(color: AppColors.darkGrey),
                prefixIcon: Icon(Icons.hotel_rounded, color: AppColors.primary),
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

            const SizedBox(height: 15),

            // Description Field
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

            const SizedBox(height: 15),

            // Rating Field
            TextField(
              controller: ratingController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Rating",
                labelStyle: TextStyle(color: AppColors.darkGrey),
                prefixIcon: Icon(Icons.star_rounded, color: AppColors.primary),
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

            const SizedBox(height: 15),

            // Phone Field
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Phone",
                labelStyle: TextStyle(color: AppColors.darkGrey),
                prefixIcon: Icon(Icons.phone_rounded, color: AppColors.primary),
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

            const SizedBox(height: 15),

            // Website Field
            TextField(
              controller: websiteController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: "Website",
                labelStyle: TextStyle(color: AppColors.darkGrey),
                prefixIcon: Icon(Icons.language_rounded, color: AppColors.primary),
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

            // ✅ Image Section (Local only)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.lightGrey),
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
                            backgroundColor: AppColors.error,
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
                  else if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _existingImageUrl!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 180,
                              color: AppColors.lightGrey,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: AppColors.grey,
                                  size: 40,
                                ),
                              ),
                            ),
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                height: 180,
                                color: AppColors.lightGrey,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: AppColors.error,
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
                      color: AppColors.lightGrey,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_rounded, size: 40, color: AppColors.grey),
                            SizedBox(height: 8),
                            Text(
                              "No image selected",
                              style: TextStyle(color: AppColors.grey),
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
                      label: const Text("Change Image"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Update Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: loading ? null : updateHotel,
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
                        "Update Hotel",
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

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              'Delete Hotel',
              style: TextStyle(
                color: AppColors.dark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${widget.hotel.name}"? This action cannot be undone.',
          style: TextStyle(color: AppColors.darkGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => loading = true);
              try {
                await hotelService.deleteHotel(widget.hotel.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ ${widget.hotel.name} deleted successfully'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                Navigator.pop(context); // Go back to list
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error deleting hotel: $e'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              } finally {
                if (mounted) setState(() => loading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}