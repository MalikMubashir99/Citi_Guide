// lib/admin/screens/city/add_city_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:app/admin/models/city_model.dart';
import 'package:app/admin/services/city_service.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  
  // ✅ Image storage
  String? _base64Image;
  String? _imageFileName;
  String? _imageMimeType;
  bool _isPickingImage = false;

  // ✅ Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      setState(() => _isPickingImage = true);
      
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        await _processImage(File(image.path), image.name);
      }
    } catch (e) {
      _showError('Error picking image: $e');
    } finally {
      setState(() => _isPickingImage = false);
    }
  }

  // ✅ Pick image from camera
  Future<void> _pickImageFromCamera() async {
    try {
      setState(() => _isPickingImage = true);
      
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        await _processImage(File(image.path), image.name);
      }
    } catch (e) {
      _showError('Error capturing image: $e');
    } finally {
      setState(() => _isPickingImage = false);
    }
  }

  // ✅ Pick image using file picker
  Future<void> _pickImageWithFilePicker() async {
    try {
      setState(() => _isPickingImage = true);
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        await _processImage(file, fileName);
      }
    } catch (e) {
      _showError('Error picking file: $e');
    } finally {
      setState(() => _isPickingImage = false);
    }
  }

  // ✅ Process and convert image to base64
  Future<void> _processImage(File imageFile, String fileName) async {
    try {
      // Read file bytes
      final bytes = await imageFile.readAsBytes();
      
      // Get file extension and mime type
      final extension = fileName.split('.').last.toLowerCase();
      String mimeType;
      
      switch (extension) {
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        case 'bmp':
          mimeType = 'image/bmp';
          break;
        default:
          mimeType = 'image/jpeg';
      }
      
      // Convert to base64
      final base64String = base64Encode(bytes);
      
      // Store as data URL format (like your events)
      final dataUrl = 'data:$mimeType;base64,$base64String';
      
      setState(() {
        _base64Image = dataUrl;
        _imageFileName = fileName;
        _imageMimeType = mimeType;
      });
      
      print('✅ Image converted to base64');
      print('📸 File name: $fileName');
      print('📸 MIME type: $mimeType');
      print('📸 Base64 length: ${base64String.length}');
      print('📸 Data URL starts with: ${dataUrl.substring(0, 50)}...');
      
    } catch (e) {
      _showError('Error processing image: $e');
    }
  }

  // ✅ Remove selected image
  void _removeImage() {
    setState(() {
      _base64Image = null;
      _imageFileName = null;
      _imageMimeType = null;
    });
  }

  // ✅ Show image picker options
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
              const Text(
                "Select Image",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_open_rounded, color: AppColors.primary),
                title: const Text("Browse Files"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageWithFilePicker();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Show error message
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> saveCity() async {
    // Validate name
    if (nameController.text.trim().isEmpty) {
      _showError("Please enter city name");
      return;
    }

    // Validate description
    if (descriptionController.text.trim().isEmpty) {
      _showError("Please enter description");
      return;
    }

    // Validate image
    if (_base64Image == null || _base64Image!.isEmpty) {
      _showError("Please select an image");
      return;
    }

    setState(() => loading = true);

    try {
      // ✅ Create CityModel with base64 image
      final city = CityModel(
        id: '', // Will be auto-generated
        name: nameController.text.trim(),
        image: _base64Image!, // Store the full data URL
        description: descriptionController.text.trim(),
      );

      print('📦 Saving city with image type: $_imageMimeType');
      print('📦 Image data starts with: ${_base64Image!.substring(0, 50)}...');

      // ✅ Save to Firestore
      await cityService.addCity(city);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ City Added Successfully"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Add City",
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Image Picker Section
            Text(
              "City Image",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 10),
            
            // Image preview or picker button
            GestureDetector(
              onTap: _isPickingImage ? null : _showImagePickerOptions,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _base64Image != null ? AppColors.primary : AppColors.lightGrey,
                    width: 2,
                    style: _base64Image != null ? BorderStyle.solid : BorderStyle.solid,
                  ),
                ),
                child: _isPickingImage
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(strokeWidth: 2),
                            SizedBox(height: 12),
                            Text(
                              "Processing image...",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : _base64Image != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              // ✅ Image Preview
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  base64Decode(_base64Image!.split(',').last),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              // ✅ Remove button
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: _removeImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              // ✅ Image info
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _imageFileName ?? 'Image',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Tap to select image",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Supports JPG, PNG, GIF, WebP",
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // ✅ City Name Field
            Text(
              "City Name",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Enter city name",
                prefixIcon: Icon(Icons.location_city_rounded, color: AppColors.primary),
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
            
            const SizedBox(height: 24),
            
            // ✅ Description Field
            Text(
              "Description",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter city description",
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Icon(Icons.description_rounded, color: AppColors.primary),
                ),
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
            
            const SizedBox(height: 30),
            
            // ✅ Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: loading ? null : saveCity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
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
                        "Save City",
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
}