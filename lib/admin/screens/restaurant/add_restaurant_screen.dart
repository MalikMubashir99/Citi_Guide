// lib/admin/screens/restaurant/add_restaurant_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:app/admin/models/city_model.dart';
import 'package:app/admin/models/restaurant_model.dart';
import 'package:app/admin/services/city_service.dart';
import 'package:app/admin/services/restaurant_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

// ── Direct colors ──
class _AdminColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color dark = Color(0xFF0F172A);
  static const Color darkGrey = Color(0xFF334155);
  static const Color grey = Color(0xFF64748B);
  static const Color lightGrey = Color(0xFFE2E8F0);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF10B981);
}

class AddRestaurantScreen extends StatefulWidget {
  final RestaurantModel? restaurant;
  final VoidCallback? onSave;

  const AddRestaurantScreen({super.key, this.restaurant, this.onSave});

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
  String? _imagePath;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.restaurant != null) {
      nameController.text = widget.restaurant!.name;
      descriptionController.text = widget.restaurant!.description;
      ratingController.text = widget.restaurant!.rating.toString();
      phoneController.text = widget.restaurant!.phone;
      latitudeController.text = widget.restaurant!.latitude.toString();
      longitudeController.text = widget.restaurant!.longitude.toString();
      selectedCity = widget.restaurant!.cityId;
      _imagePath = widget.restaurant!.image;
    }
  }

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

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      setState(() => _imagePath = base64String);
    } else {
      final File file = File(image.path);
      setState(() => _imagePath = file.path);
    }
  }

  void removeImage() => setState(() => _imagePath = null);

  Future<void> saveRestaurant() async {
    if (selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Select a city", style: GoogleFonts.poppins()),
          backgroundColor: _AdminColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter restaurant name", style: GoogleFonts.poppins()),
          backgroundColor: _AdminColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => loading = true);
    try {
      final restaurant = RestaurantModel(
        id: widget.restaurant?.id ?? '',
        name: nameController.text.trim(),
        cityId: selectedCity!,
        image: _imagePath ?? '',
        description: descriptionController.text.trim(),
        rating: double.tryParse(ratingController.text) ?? 0,
        phone: phoneController.text.trim(),
        latitude: double.tryParse(latitudeController.text) ?? 0,
        longitude: double.tryParse(longitudeController.text) ?? 0,
      );
      if (widget.restaurant == null) {
        await restaurantService.addRestaurant(restaurant);
      } else {
        await restaurantService.updateRestaurant(restaurant);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.restaurant == null ? '✅ Restaurant added!' : '✅ Restaurant updated!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _AdminColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      widget.onSave?.call();
      Navigator.pop(context);
    } catch (e) {
      setState(() => loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e", style: GoogleFonts.poppins()),
          backgroundColor: _AdminColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget buildField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 15, color: _AdminColors.dark),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: _AdminColors.grey, fontSize: 14),
          prefixIcon: Icon(_iconForLabel(label), color: _AdminColors.primary),
          filled: true,
          fillColor: _AdminColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _AdminColors.lightGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _AdminColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  IconData _iconForLabel(String label) {
    switch (label) {
      case 'Restaurant Name':
        return Icons.restaurant_rounded;
      case 'Description':
        return Icons.description_rounded;
      case 'Rating':
        return Icons.star_rounded;
      case 'Phone':
        return Icons.phone_rounded;
      case 'Latitude':
        return Icons.pin_drop_rounded;
      case 'Longitude':
        return Icons.pin_drop_rounded;
      default:
        return Icons.edit_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.restaurant != null;
    return Scaffold(
      backgroundColor: _AdminColors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Restaurant' : 'Add Restaurant',
          style: GoogleFonts.poppins(
            color: _AdminColors.dark,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: _AdminColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _AdminColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete_rounded, color: _AdminColors.error),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    backgroundColor: _AdminColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _AdminColors.error.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.delete_outline_rounded, size: 40, color: _AdminColors.error),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Delete Restaurant?',
                            style: GoogleFonts.poppins(
                              color: _AdminColors.dark,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This action cannot be undone.',
                            style: GoogleFonts.poppins(
                              color: _AdminColors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.poppins(
                                      color: _AdminColors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await restaurantService.deleteRestaurant(widget.restaurant!.id);
                                    if (!mounted) return;
                                    Navigator.pop(context);
                                    widget.onSave?.call();
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _AdminColors.error,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Delete',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── City Dropdown ──
            Text(
              "City",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _AdminColors.dark,
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<CityModel>>(
              stream: cityService.getCities(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _AdminColors.primary,
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "No cities available",
                      style: GoogleFonts.poppins(color: _AdminColors.grey),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: DropdownButtonFormField<String>(
                    value: selectedCity,
                    style: GoogleFonts.poppins(fontSize: 15, color: _AdminColors.dark),
                    decoration: InputDecoration(
                      labelText: "Select City",
                      labelStyle: GoogleFonts.poppins(color: _AdminColors.grey, fontSize: 14),
                      prefixIcon: Icon(Icons.location_city_rounded, color: _AdminColors.primary),
                      filled: true,
                      fillColor: _AdminColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _AdminColors.lightGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _AdminColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text("Select a city"),
                      ),
                      ...snapshot.data!.map((city) => DropdownMenuItem(
                        value: city.id,
                        child: Text(city.name),
                      )),
                    ],
                    onChanged: (value) => setState(() => selectedCity = value),
                  ),
                );
              },
            ),

            // ── Name ──
            buildField("Restaurant Name", nameController),

            // ── Description ──
            buildField("Description", descriptionController),

            // ── Rating ──
            buildField("Rating", ratingController, keyboardType: TextInputType.number),

            // ── Phone ──
            buildField("Phone", phoneController, keyboardType: TextInputType.phone),

            // ── Latitude ──
            buildField("Latitude", latitudeController, keyboardType: TextInputType.number),

            // ── Longitude ──
            buildField("Longitude", longitudeController, keyboardType: TextInputType.number),

            const SizedBox(height: 20),

            // ── Image Section ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _AdminColors.white,
                border: Border.all(color: _AdminColors.lightGrey.withOpacity(0.5)),
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
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_imagePath!),
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: removeImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: _AdminColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _AdminColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_rounded, size: 40, color: _AdminColors.grey),
                          const SizedBox(height: 8),
                          Text(
                            "No image selected",
                            style: GoogleFonts.poppins(color: _AdminColors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: pickImage,
                      icon: Icon(Icons.photo_library_rounded, color: _AdminColors.primary),
                      label: Text(
                        isEditing ? "Change Image" : "Choose Image",
                        style: GoogleFonts.poppins(
                          color: _AdminColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: _AdminColors.lightGrey),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ── Save Button ──
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: loading ? null : saveRestaurant,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _AdminColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEditing ? "Update Restaurant" : "Save Restaurant",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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