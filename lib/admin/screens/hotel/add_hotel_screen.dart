// lib/admin/screens/hotel/add_hotel_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:app/admin/models/hotel_model.dart';
import 'package:app/admin/services/hotel_service.dart';
import 'package:app/admin/services/city_service.dart';
import 'package:app/admin/models/city_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  String? _imagePath;
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

  Future<void> _loadCities() async {
    try {
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

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
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
        setState(() => _imagePath = base64String);
      } else {
        final File file = File(image.path);
        setState(() => _imagePath = file.path);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e', style: GoogleFonts.poppins()),
          backgroundColor: _AdminColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _removeImage() => setState(() => _imagePath = null);

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a city', style: GoogleFonts.poppins()),
          backgroundColor: _AdminColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
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
        rating: double.tryParse(_ratingController.text) ?? 0.0,
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
      } else {
        await _hotelService.updateHotel(hotel);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.hotel == null ? '✅ Hotel added successfully!' : '✅ Hotel updated successfully!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _AdminColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      widget.onSave();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e', style: GoogleFonts.poppins()),
          backgroundColor: _AdminColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.poppins(fontSize: 15, color: _AdminColors.dark),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: _AdminColors.grey, fontSize: 14),
          prefixIcon: Icon(icon, color: _AdminColors.primary),
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.hotel != null;
    return Scaffold(
      backgroundColor: _AdminColors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Hotel' : 'Add Hotel',
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
                            'Delete Hotel?',
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
                                    await _hotelService.deleteHotel(widget.hotel!.id);
                                    if (!mounted) return;
                                    Navigator.pop(context);
                                    widget.onSave();
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
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image Picker ──
              Text(
                "Hotel Image",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _AdminColors.dark,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
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
                                  ? Image.memory(base64Decode(_imagePath!.split(',').last), fit: BoxFit.cover)
                                  : Image.file(File(_imagePath!), fit: BoxFit.cover),
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
                                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
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
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Name ──
              _buildTextField(
                controller: _nameController,
                label: 'Hotel Name',
                icon: Icons.hotel_rounded,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),

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
              _citiesLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: _selectedCityId,
                      style: GoogleFonts.poppins(fontSize: 15, color: _AdminColors.dark),
                      decoration: InputDecoration(
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
                        ..._cities.map((city) => DropdownMenuItem(
                          value: city.id,
                          child: Text(city.name),
                        )),
                      ],
                      onChanged: (v) => setState(() => _selectedCityId = v),
                      validator: (v) => v == null ? 'Select a city' : null,
                    ),
              const SizedBox(height: 16),

              // ── Description ──
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description_rounded,
                maxLines: 3,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),

              // ── Rating ──
              _buildTextField(
                controller: _ratingController,
                label: 'Rating (0-5)',
                icon: Icons.star_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v?.isEmpty == true) return 'Required';
                  final r = double.tryParse(v!);
                  if (r == null || r < 0 || r > 5) return 'Must be 0-5';
                  return null;
                },
              ),

              // ── Phone ──
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),

              // ── Website ──
              _buildTextField(
                controller: _websiteController,
                label: 'Website URL',
                icon: Icons.language_rounded,
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 30),

              // ── Save Button ──
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _AdminColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isEditing ? 'Update Hotel' : 'Add Hotel',
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
      ),
    );
  }
}