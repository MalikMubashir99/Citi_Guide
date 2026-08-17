// lib/admin/screens/city/add_city_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:app/admin/models/city_model.dart';
import 'package:app/admin/services/city_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

// ── Direct colors ──
class _AdminColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color dark = Color(0xFF0F172A);
  static const Color darkGrey = Color(0xFF334155);
  static const Color grey = Color(0xFF64748B);
  static const Color lightGrey = Color(0xFFE2E8F0);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF10B981);
}

class AddCityScreen extends StatefulWidget {
  const AddCityScreen({super.key});

  @override
  State<AddCityScreen> createState() => _AddCityScreenState();
}

class _AddCityScreenState extends State<AddCityScreen> {
  final CityService cityService = CityService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool loading = false;
  String? _imagePath;
  File? _imageFile;

  Future<void> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
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
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  void _removeImage() {
    setState(() {
      _imagePath = null;
      _imageFile = null;
    });
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Image",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _AdminColors.dark,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.camera_alt_rounded, color: _AdminColors.primary),
                title: Text("Take Photo", style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_rounded, color: _AdminColors.primary),
                title: Text("Choose from Gallery", style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: _AdminColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> saveCity() async {
    if (nameController.text.trim().isEmpty) {
      _showError("Please enter city name");
      return;
    }
    if (descriptionController.text.trim().isEmpty) {
      _showError("Please enter description");
      return;
    }
    if (_imagePath == null || _imagePath!.isEmpty) {
      _showError("Please select an image");
      return;
    }

    setState(() => loading = true);

    try {
      final city = CityModel(
        id: '',
        name: nameController.text.trim(),
        image: _imagePath!,
        description: descriptionController.text.trim(),
      );
      await cityService.addCity(city);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ City Added Successfully", style: GoogleFonts.poppins()),
          backgroundColor: _AdminColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showError("❌ Error: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AdminColors.background,
      appBar: AppBar(
        title: Text(
          "Add City",
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Picker ──
            Text(
              "City Image",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _AdminColors.dark,
              ),
            ),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: _showImagePickerOptions,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: _AdminColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _imagePath != null ? _AdminColors.primary : _AdminColors.lightGrey,
                    width: 2,
                  ),
                ),
                child: _imagePath != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: kIsWeb
                                ? Image.memory(
                                    base64Decode(_imagePath!.split(',').last),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                                  )
                                : Image.file(
                                    File(_imagePath!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                                  ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: _removeImage,
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
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_rounded, size: 60, color: _AdminColors.grey.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          Text(
                            "Tap to select image",
                            style: GoogleFonts.poppins(color: _AdminColors.grey, fontSize: 14),
                          ),
                          Text(
                            "Supports JPG, PNG",
                            style: GoogleFonts.poppins(color: _AdminColors.grey.withOpacity(0.6), fontSize: 12),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // ── City Name ──
            Text(
              "City Name",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _AdminColors.dark,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              style: GoogleFonts.poppins(fontSize: 15, color: _AdminColors.dark),
              decoration: InputDecoration(
                hintText: "Enter city name",
                hintStyle: GoogleFonts.poppins(color: _AdminColors.grey, fontSize: 14),
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
            ),

            const SizedBox(height: 24),

            // ── Description ──
            Text(
              "Description",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _AdminColors.dark,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              style: GoogleFonts.poppins(fontSize: 15, color: _AdminColors.dark),
              decoration: InputDecoration(
                hintText: "Enter city description",
                hintStyle: GoogleFonts.poppins(color: _AdminColors.grey, fontSize: 14),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Icon(Icons.description_rounded, color: _AdminColors.primary),
                ),
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

            const SizedBox(height: 30),

            // ── Save Button ──
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: loading ? null : saveCity,
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
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        "Save City",
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

  Widget _buildImagePlaceholder() {
    return Container(
      color: _AdminColors.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 50, color: _AdminColors.grey),
          const SizedBox(height: 8),
          Text(
            "Image not available",
            style: GoogleFonts.poppins(color: _AdminColors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}