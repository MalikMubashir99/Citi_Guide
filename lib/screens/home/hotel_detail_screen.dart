import 'package:flutter/material.dart';
import '../../model/hotel_model.dart';
import 'package:url_launcher/url_launcher.dart';

class HotelDetailScreen extends StatelessWidget {
  final HotelModel hotel;

  const HotelDetailScreen({
    super.key,
    required this.hotel,
  });

  // ✅ Pass context as parameter
  Future<void> callHotel(BuildContext context) async {
    if (hotel.phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number not available")),
      );
      return;
    }

    final Uri url = Uri.parse("tel:${hotel.phone}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to make call")),
      );
    }
  }

  // ✅ Pass context as parameter
  Future<void> openWebsite(BuildContext context) async {
    if (hotel.website.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Website URL not available")),
      );
      return;
    }

    String urlString = hotel.website;
    if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
      urlString = 'https://$urlString';
    }

    final Uri url = Uri.parse(urlString);

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to open website")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hotel.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            hotel.image.isEmpty
                ? Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.hotel,
                      size: 100,
                    ),
                  )
                : Image.network(
                    hotel.image,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
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
                    hotel.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        hotel.rating.toString(),
                      ),
                    ],
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
                    hotel.description,
                  ),
                  const SizedBox(height: 25),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text("Phone"),
                    subtitle: Text(
                      hotel.phone.isEmpty ? "Not available" : hotel.phone,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text("Website"),
                    subtitle: Text(
                      hotel.website.isEmpty ? "Not available" : hotel.website,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      // ✅ Pass context to the method
                      onPressed: () => callHotel(context),
                      icon: const Icon(Icons.call),
                      label: const Text("Call Hotel"),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      // ✅ Pass context to the method
                      onPressed: () => openWebsite(context),
                      icon: const Icon(Icons.language),
                      label: const Text("Visit Website"),
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