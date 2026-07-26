// lib/admin/screens/hotel/add_hotel_screen.dart
import 'package:app/admin/models/hotel_model.dart';
import 'package:app/admin/services/hotel_service.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

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
  final _nameController = TextEditingController();
  final _cityIdController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();
  final _ratingController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();

  bool _isLoading = false;
  final HotelService _service = HotelService();

  @override
  void initState() {
    super.initState();
    if (widget.hotel != null) {
      _nameController.text = widget.hotel!.name;
      _cityIdController.text = widget.hotel!.cityId;
      _descriptionController.text = widget.hotel!.description;
      _imageController.text = widget.hotel!.image;
      _ratingController.text = widget.hotel!.rating.toString();
      _phoneController.text = widget.hotel!.phone;
      _websiteController.text = widget.hotel!.website;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityIdController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _ratingController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final hotel = HotelModel(
        id: widget.hotel?.id ?? '',
        cityId: _cityIdController.text.trim(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        image: _imageController.text.trim(),
        rating: double.parse(_ratingController.text),
        phone: _phoneController.text.trim(),
        website: _websiteController.text.trim(),
        // ✅ Added required fields
        createdAt: widget.hotel?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isFeatured: widget.hotel?.isFeatured ?? false,
        isActive: widget.hotel?.isActive ?? true,
        views: widget.hotel?.views ?? 0,
        bookings: widget.hotel?.bookings ?? 0,
      );

      if (widget.hotel == null) {
        await _service.addHotel(hotel);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Hotel added successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        await _service.updateHotel(hotel);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Hotel updated successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
          if (widget.hotel != null)
            IconButton(
              icon: Icon(Icons.delete_rounded, color: AppColors.error),
              onPressed: () {
                // Show delete confirmation
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Hotel Name',
                icon: Icons.hotel_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter hotel name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _cityIdController,
                label: 'City ID',
                icon: Icons.location_city_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter city ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description_rounded,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _imageController,
                label: 'Image URL',
                icon: Icons.image_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter image URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ratingController,
                label: 'Rating (0-5)',
                icon: Icons.star_rounded,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter rating';
                  }
                  final rating = double.tryParse(value);
                  if (rating == null || rating < 0 || rating > 5) {
                    return 'Rating must be between 0 and 5';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _websiteController,
                label: 'Website URL',
                icon: Icons.language_rounded,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.hotel == null ? 'Add Hotel' : 'Update Hotel',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
    );
  }
}