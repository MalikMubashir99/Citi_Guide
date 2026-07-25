import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/model/city_model.dart';
import 'package:app/services/city_service.dart';
import '../../services/attraction_service.dart';

class AddAttractionScreen extends StatefulWidget {
   AddAttractionScreen({super.key});

  @override
  State<AddAttractionScreen> createState() => _AddAttractionScreenState();

  final CityService cityService = CityService();
}

class _AddAttractionScreenState extends State<AddAttractionScreen> {
  final AttractionService attractionService = AttractionService();

  final nameController = TextEditingController();
  String? selectedCityId;
  final descriptionController = TextEditingController();
  final ratingController = TextEditingController();
  final openingHoursController = TextEditingController();
  final phoneController = TextEditingController();
  final websiteController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  // ✅ Store image path only
  String? _imagePath;  // Mobile: file path, Web: base64 or URL
  File? _imageFile;    // Mobile only

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

  // ✅ Pick Image - Store only path
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    if (kIsWeb) {
      // ✅ Web: Store as base64 string (or URL)
      final bytes = await image.readAsBytes();
      final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      setState(() {
        _imagePath = base64String;
        _imageFile = null;
      });
    } else {
      // ✅ Mobile: Store file path only
      final File file = File(image.path);
      setState(() {
        _imagePath = file.path;  // ✅ Only path, not uploading anywhere
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
      // ✅ Store the path in database (not the actual image)
      await attractionService.addAttraction(
        name: nameController.text.trim(),
        cityId: selectedCityId!,
        description: descriptionController.text.trim(),
        image: _imagePath ?? '', // ✅ Store path only
        rating: double.tryParse(ratingController.text) ?? 0,
        openingHours: openingHoursController.text.trim(),
        phone: phoneController.text.trim(),
        website: websiteController.text.trim(),
        latitude: double.tryParse(latitudeController.text) ?? 0,
        longitude: double.tryParse(longitudeController.text) ?? 0,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attraction Added Successfully ✅")),
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

            // ✅ Image Selection (Local Path Only)
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
                      label: const Text("Choose Image"),
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

            buildField("Rating", ratingController,
                keyboardType: TextInputType.number),
            buildField("Opening Hours", openingHoursController),
            buildField("Phone", phoneController),
            buildField("Website", websiteController,
                keyboardType: TextInputType.url),
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