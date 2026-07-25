import 'package:app/admin/models/attraction_model.dart';
import 'package:app/admin/services/attraction_service.dart';
import 'package:app/admin/services/city_service.dart';
import 'package:app/model/city_model.dart';
import 'package:flutter/material.dart';

class EditAttractionScreen extends StatefulWidget {
  final AttractionModel attraction;

  const EditAttractionScreen({
    super.key,
    required this.attraction,
  });

  @override
  State<EditAttractionScreen> createState() =>
      _EditAttractionScreenState();
}

class _EditAttractionScreenState extends State<EditAttractionScreen> {
  final AttractionService attractionService = AttractionService();
  final CityService cityService = CityService();

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController imageController;
  late TextEditingController ratingController;
  late TextEditingController openingHoursController;
  late TextEditingController phoneController;
  late TextEditingController websiteController;
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;

  String? selectedCityId;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    selectedCityId = widget.attraction.cityId;

    nameController = TextEditingController(text: widget.attraction.name);
    descriptionController = TextEditingController(text: widget.attraction.description);
    imageController = TextEditingController(text: widget.attraction.image);
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
    imageController.dispose();
    ratingController.dispose();
    openingHoursController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
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

    // ✅ Validate name
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
      AttractionModel attraction = AttractionModel(
        id: widget.attraction.id,
        name: nameController.text.trim(),
        cityId: selectedCityId!,
        description: descriptionController.text.trim(),
        image: imageController.text.trim(),
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
            // ✅ Name Field
            buildField("Name", nameController),

            const SizedBox(height: 15),

            // ✅ City Dropdown
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

            // ✅ Description
            buildField("Description", descriptionController),

            // ✅ Image URL
            buildField("Image URL", imageController),

            // ✅ Rating
            buildField(
              "Rating",
              ratingController,
              keyboardType: TextInputType.number,
            ),

            // ✅ Opening Hours
            buildField("Opening Hours", openingHoursController),

            // ✅ Phone
            buildField("Phone", phoneController),

            // ✅ Website
            buildField("Website", websiteController),

            // ✅ Latitude
            buildField(
              "Latitude",
              latitudeController,
              keyboardType: TextInputType.number,
            ),

            // ✅ Longitude
            buildField(
              "Longitude",
              longitudeController,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            // ✅ Update Button
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