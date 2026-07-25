import 'package:app/model/city_model.dart';
import 'package:flutter/material.dart';
import '../../services/city_service.dart';

class EditCityScreen extends StatefulWidget {
  final CityModel city;

  const EditCityScreen({
    super.key,
    required this.city,
  });

  @override
  State<EditCityScreen> createState() =>
      _EditCityScreenState();
}

class _EditCityScreenState
    extends State<EditCityScreen> {

  final CityService cityService = CityService();

  late TextEditingController nameController;
  late TextEditingController imageController;
  late TextEditingController descriptionController;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.city.name);

    imageController =
        TextEditingController(text: widget.city.image);

    descriptionController =
        TextEditingController(
          text: widget.city.description,
        );
  }

  Future<void> updateCity() async {

    if (nameController.text.trim().isEmpty ||
        imageController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Fill all fields"),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    await cityService.updateCity(

      id: widget.city.id,

      name: nameController.text.trim(),

      image: imageController.text.trim(),

      description:
          descriptionController.text.trim(),
    );

    setState(() {
      loading = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("City Updated"),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Edit City"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "City Name",
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: imageController,
              decoration: const InputDecoration(
                labelText: "Image URL",
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Description",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed:
                    loading ? null : updateCity,

                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Update City"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}