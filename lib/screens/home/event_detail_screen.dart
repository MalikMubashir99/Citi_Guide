import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/event_model.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  // ✅ Pass context as parameter
  Future<void> openGoogleMaps(BuildContext context) async {
    if (event.location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location not available")),
      );
      return;
    }

    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(event.location)}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to open Google Maps")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            event.image.isEmpty
                ? Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.event,
                      size: 100,
                    ),
                  )
                : Image.network(
                    event.image,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 250,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text("Date"),
                    subtitle: Text(
                      event.date.isEmpty ? "Not available" : event.date,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text("Time"),
                    subtitle: Text(
                      event.time.isEmpty ? "Not available" : event.time,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text("Location"),
                    subtitle: Text(
                      event.location.isEmpty ? "Not available" : event.location,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.description.isEmpty ? "No description available" : event.description,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      // ✅ Pass context to method
                      onPressed: () => openGoogleMaps(context),
                      icon: const Icon(Icons.map),
                      label: const Text("Open in Google Maps"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}