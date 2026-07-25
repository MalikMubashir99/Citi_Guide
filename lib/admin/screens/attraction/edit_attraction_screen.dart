import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:app/admin/models/attraction_model.dart';
import 'package:app/admin/services/attraction_service.dart';
import 'package:app/admin/services/city_service.dart';
import 'package:app/model/city_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditAttractionScreen extends StatefulWidget {
  final AttractionModel attraction;

  const EditAttractionScreen({
    super.key,
    required this.attraction,
  });

  @override
  State<EditAttractionScreen> createState() => _EditAttractionScreenState();
}

class _EditAttractionScreenState extends State<EditAttractionScreen> {
  final AttractionService attractionService = AttractionService();
  final CityService cityService = CityService();

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController ratingController;
  late TextEditingController openingHoursController;
  late TextEditingController phoneController;
  late TextEditingController websiteController;
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;

  String? selectedCityId;
  bool loading = false;

  // ✅ Image state
  String? _imagePath;
  File? _imageFile;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();

    selectedCityId = widget.attraction.cityId;
    _existingImageUrl = widget.attraction.image;

    nameController = TextEditingController(text: widget.attraction.name);
    descriptionController = TextEditingController(text: widget.attraction.description);
    ratingController = TextEditingController(
      text: widget.attraction.rating.toString(),
    );
    openingHoursController = TextEditingController(
      text: widget.attraction.openingHours,
    );
    phoneController = TextEditingController(text: widget.attraction.phone);
    websiteController = TextEditingController(text: widget.attraction.website);
    latitudeController = TextEditingController(
      text: widget.attraction.latitude.toString(),
    );
    longitudeController = TextEditingController(
      text: widget.attraction.longitude.toString(),
    );
  }

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

  // ✅ Pick Image - Store only path
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
      _existingImageUrl = null;
    });
  }

  Future<void> updateAttraction() async {
    if (selectedCityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a city"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter attraction name"),
          backgroundColor: Colors.red,
        ),
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
        // If new image selected, use it
        finalImageUrl = _imagePath!;
      }

      AttractionModel attraction = AttractionModel(
        id: widget.attraction.id,
        name: nameController.text.trim(),
        cityId: selectedCityId!,
        description: descriptionController.text.trim(),
        image: finalImageUrl,
        rating: double.tryParse(ratingController.text) ?? 0,
        openingHours: openingHoursController.text.trim(),
        phone: phoneController.text.trim(),
        website: websiteController.text.trim(),
        latitude: double.tryParse(latitudeController.text) ?? 0,
        longitude: double.tryParse(longitudeController.text) ?? 0,
      );

      await attractionService.updateAttraction(attraction);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Attraction Updated Successfully ✅"),
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

  Widget buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
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
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Attraction"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Name Field
            buildField("Name", nameController),

            const SizedBox(height: 15),

            // City Dropdown
            StreamBuilder<List<CityModel>>(
              stream: cityService.getCities(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No cities available");
                }

                return DropdownButtonFormField<String>(
                  initialValue: selectedCityId,
                  decoration: const InputDecoration(
                    labelText: "City",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
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

            const SizedBox(height: 15),

            // ✅ Image Section (Like AddAttractionScreen)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // ✅ Image Preview
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
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                    SizedBox(height: 8),
                                    Text(
                                      "Image not available",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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

                  // ✅ Choose Image Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Change Image"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  // ✅ Show path (for debugging)
                  if (_imagePath != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "Path: ${_imagePath!.length > 50 ? _imagePath!.substring(0, 50) + '...' : _imagePath!}",
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Description
            buildField("Description", descriptionController),

            // Rating
            buildField(
              "Rating",
              ratingController,
              keyboardType: TextInputType.number,
            ),

            // Opening Hours
            buildField("Opening Hours", openingHoursController),

            // Phone
            buildField("Phone", phoneController),

            // Website
            buildField("Website", websiteController),

            // Latitude
            buildField(
              "Latitude",
              latitudeController,
              keyboardType: TextInputType.number,
            ),

            // Longitude
            buildField(
              "Longitude",
              longitudeController,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            // Update Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : updateAttraction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Update Attraction",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}