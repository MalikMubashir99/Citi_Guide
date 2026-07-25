import 'dart:io';

import 'package:app/admin/services/storage_service.dart';
import 'package:app/model/city_model.dart';
import 'package:app/model/event_model.dart';
import 'package:app/services/city_service.dart';
import 'package:app/services/event_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditEventScreen extends StatefulWidget {
  final EventModel event;

  const EditEventScreen({
    super.key,
    required this.event,
  });

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final EventService eventService = EventService();
  final CityService cityService = CityService();
  final StorageService storageService = StorageService();

  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;
  late TextEditingController dateController;
  late TextEditingController timeController;

  String? selectedCity;
  File? selectedImage;
  bool loading = false;
  String imageUrl = "";

  @override
  void initState() {
    super.initState();

    // Initialize controllers with event data
    titleController = TextEditingController(
      text: widget.event.title,
    );
    descriptionController = TextEditingController(
      text: widget.event.description,
    );
    locationController = TextEditingController(
      text: widget.event.location,
    );
    dateController = TextEditingController(
      text: widget.event.date,
    );
    timeController = TextEditingController(
      text: widget.event.time,
    );

    // Set initial values
    selectedCity = widget.event.cityId;
    imageUrl = widget.event.image;
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
    });
  }

  Future<void> updateEvent() async {
    if (selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a city")),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      String finalImageUrl = imageUrl;

      // Upload new image if selected
      if (selectedImage != null) {
        finalImageUrl = await storageService.uploadImage(selectedImage!);
      }

      EventModel event = EventModel(
        id: widget.event.id,
        title: titleController.text.trim(),
        cityId: selectedCity!,
        image: finalImageUrl,
        description: descriptionController.text.trim(),
        date: dateController.text.trim(),
        time: timeController.text.trim(),
        location: locationController.text.trim(),
      );

      await eventService.updateEvent(event);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event Updated Successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Event"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ Changed to FutureBuilder
            FutureBuilder<List<CityModel>>(
              future: cityService.getCities(),
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
                  initialValue: selectedCity,
                  decoration: const InputDecoration(
                    labelText: "City",
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
                      selectedCity = value;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 15),

            // Title
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Event Title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Description
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Location
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: "Location",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Date
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: "Date",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Time
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: "Time",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Image preview
            if (selectedImage != null)
              Image.file(
                selectedImage!,
                height: 180,
                fit: BoxFit.cover,
              )
            else if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.broken_image,
                  size: 180,
                ),
              ),

            const SizedBox(height: 15),

            // Change Image button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text("Change Image"),
              ),
            ),

            const SizedBox(height: 25),

            // Update button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : updateEvent,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Update Event"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}