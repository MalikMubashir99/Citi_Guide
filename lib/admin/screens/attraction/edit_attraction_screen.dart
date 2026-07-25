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

class _EditAttractionScreenState
    extends State<EditAttractionScreen> {

  final AttractionService attractionService =
      AttractionService();

  final CityService cityService =
      CityService();

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

    nameController =
        TextEditingController(text: widget.attraction.name);

    descriptionController =
        TextEditingController(text: widget.attraction.description);

    imageController =
        TextEditingController(text: widget.attraction.image);

    ratingController =
        TextEditingController(text: widget.attraction.rating.toString());

    openingHoursController =
        TextEditingController(text: widget.attraction.openingHours);

    phoneController =
        TextEditingController(text: widget.attraction.phone);

    websiteController =
        TextEditingController(text: widget.attraction.website);

    latitudeController =
        TextEditingController(text: widget.attraction.latitude.toString());

    longitudeController =
        TextEditingController(text: widget.attraction.longitude.toString());
  }

  Future<void> updateAttraction() async {

    if (selectedCityId == null) return;

    setState(() {
      loading = true;
    });

    AttractionModel attraction = AttractionModel(
      id: widget.attraction.id,
      name: nameController.text.trim(),
      cityId: selectedCityId!,
      description: descriptionController.text.trim(),
      image: imageController.text.trim(),
      rating:
          double.tryParse(ratingController.text) ?? 0,
      openingHours:
          openingHoursController.text.trim(),
      phone: phoneController.text.trim(),
      website: websiteController.text.trim(),
      latitude:
          double.tryParse(latitudeController.text) ?? 0,
      longitude:
          double.tryParse(longitudeController.text) ?? 0,
    );

    await attractionService.updateAttraction(attraction);

    if (!mounted) return;

    Navigator.pop(context);
  }

  Widget buildField(
    String label,
    TextEditingController controller,
  ) {

    return Padding(

      padding: const EdgeInsets.only(bottom: 15),

      child: TextField(

        controller: controller,

        decoration: InputDecoration(

          labelText: label,

          border: const OutlineInputBorder(),

        ),

      ),

    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Edit Attraction"),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            buildField("Name", nameController),

            StreamBuilder<List<CityModel>>(

              stream: cityService.getCities(),

              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                return DropdownButtonFormField<String>(

                  initialValue: selectedCityId,

                  decoration: const InputDecoration(
                    labelText: "City",
                    border: OutlineInputBorder(),
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

            buildField(
              "Description",
              descriptionController,
            ),

            buildField(
              "Image URL",
              imageController,
            ),

            buildField(
              "Rating",
              ratingController,
            ),

            buildField(
              "Opening Hours",
              openingHoursController,
            ),

            buildField(
              "Phone",
              phoneController,
            ),

            buildField(
              "Website",
              websiteController,
            ),

            buildField(
              "Latitude",
              latitudeController,
            ),

            buildField(
              "Longitude",
              longitudeController,
            ),

            const SizedBox(height: 20),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed:
                    loading
                        ? null
                        : updateAttraction,

                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Update Attraction"),

              ),

            ),

          ],

        ),

      ),

    );

  }

}