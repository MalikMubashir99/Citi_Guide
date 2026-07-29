// lib/admin/screens/hotel/add_hotel_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:app/admin/models/hotel_model.dart';
import 'package:app/admin/services/hotel_service.dart';
import 'package:app/admin/services/city_service.dart';
import 'package:app/admin/models/city_model.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddHotelScreen extends StatefulWidget {
  final HotelModel? hotel;
  final VoidCallback onSave;

  const AddHotelScreen({
    super.key,
    this.hotel,
    required this.onSave,
  });

  @override
  State<AddHotelScreen> createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen> {
  final _formKey = GlobalKey<FormState>();
  final HotelService _hotelService = HotelService();
  final CityService _cityService = CityService();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ratingController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();

  String? _selectedCityId;
  List<CityModel> _cities = [];
  bool _citiesLoading = true;

  // ✅ Image picker - store path only
  String? _imagePath;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCities();

    if (widget.hotel != null) {
      _nameController.text = widget.hotel!.name;
      _selectedCityId = widget.hotel!.cityId;
      _descriptionController.text = widget.hotel!.description;
      _imagePath = widget.hotel!.image;
      _ratingController.text = widget.hotel!.rating.toString();
      _phoneController.text = widget.hotel!.phone;
      _websiteController.text = widget.hotel!.website;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ratingController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  // ✅ Load cities for dropdown
 Future<void> _loadCities() async {
  try {
    // ✅ Fix: Get first emission from Stream
    final cities = await _cityService.getCities().first;
    if (!mounted) return;
    setState(() {
      _cities = cities;
      _citiesLoading = false;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() => _citiesLoading = false);
  }
}

  // ✅ Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  // ✅ Remove image
  void _removeImage() {
    setState(() {
      _imagePath = null;
      _imageFile = null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please select a city'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final hotel = HotelModel(
        id: widget.hotel?.id ?? '',
        cityId: _selectedCityId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        image: _imagePath ?? '',
        rating: double.parse(_ratingController.text),
        phone: _phoneController.text.trim(),
        website: _websiteController.text.trim(),
        createdAt: widget.hotel?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isFeatured: widget.hotel?.isFeatured ?? false,
        isActive: widget.hotel?.isActive ?? true,
        views: widget.hotel?.views ?? 0,
        bookings: widget.hotel?.bookings ?? 0,
      );

      if (widget.hotel == null) {
        await _hotelService.addHotel(hotel);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Hotel added successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        await _hotelService.updateHotel(hotel);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Hotel updated successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }

      widget.onSave();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.hotel == null ? 'Add New Hotel' : 'Edit Hotel',
          style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.hotel != null)
            IconButton(
              icon: Icon(Icons.delete_rounded, color: AppColors.error),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Hotel?'),
                    content: const Text('This action cannot be undone.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () async {
                          await _hotelService.deleteHotel(widget.hotel!.id);
                          if (!mounted) return;
                          Navigator.pop(context); // dialog
                          widget.onSave();
                          Navigator.pop(context); // screen
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Image Picker
              Text("Hotel Image", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.dark)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _imagePath != null ? AppColors.primary : AppColors.lightGrey, width: 2),
                  ),
                  child: _imagePath != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: kIsWeb
                                  ? Image.memory(base64Decode(_imagePath!.split(',').last), fit: BoxFit.cover)
                                  : Image.file(File(_imagePath!), fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 8, right: 8,
                              child: GestureDetector(
                                onTap: _removeImage,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_rounded, size: 60, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text("Tap to select image", style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // ✅ Hotel Name
              _buildTextField(controller: _nameController, label: 'Hotel Name', icon: Icons.hotel_rounded, validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 16),

              // ✅ City Dropdown
              Text("City", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.dark)),
              const SizedBox(height: 10),
              _citiesLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: _selectedCityId,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.location_city_rounded, color: AppColors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: AppColors.white,
                      ),
                      items: _cities.map((city) => DropdownMenuItem(value: city.id, child: Text(city.name))).toList(),
                      onChanged: (v) => setState(() => _selectedCityId = v),
                      validator: (v) => v == null ? 'Select a city' : null,
                    ),

              const SizedBox(height: 16),

              // ✅ Description
              _buildTextField(controller: _descriptionController, label: 'Description', icon: Icons.description_rounded, maxLines: 3, validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 16),

              // ✅ Rating
              _buildTextField(controller: _ratingController, label: 'Rating (0-5)', icon: Icons.star_rounded, keyboardType: TextInputType.number, validator: (v) {
                if (v?.isEmpty == true) return 'Required';
                final r = double.tryParse(v!);
                if (r == null || r < 0 || r > 5) return 'Must be 0-5';
                return null;
              }),
              const SizedBox(height: 16),

              // ✅ Phone
              _buildTextField(controller: _phoneController, label: 'Phone Number', icon: Icons.phone_rounded, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),

              // ✅ Website
              _buildTextField(controller: _websiteController, label: 'Website URL', icon: Icons.language_rounded, keyboardType: TextInputType.url),
              const SizedBox(height: 30),

              // ✅ Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(widget.hotel == null ? 'Add Hotel' : 'Update Hotel', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.lightGrey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary, width: 2)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.lightGrey)),
        filled: true,
        fillColor: AppColors.white,
      ),
    );
  }
}