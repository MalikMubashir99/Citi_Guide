import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/restaurant_model.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
  });

  // ✅ Pass context as parameter
  Future<void> openGoogleMaps(BuildContext context) async {
    if (restaurant.latitude == 0 && restaurant.longitude == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location not available")),
      );
      return;
    }

    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${restaurant.latitude},${restaurant.longitude}",
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

  // ✅ Pass context as parameter
  Future<void> callRestaurant(BuildContext context) async {
    if (restaurant.phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number not available")),
      );
      return;
    }

    final Uri url = Uri.parse("tel:${restaurant.phone}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to make call")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            restaurant.image.isEmpty
                ? Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.restaurant,
                      size: 100,
                    ),
                  )
                : Image.network(
                    restaurant.image,
                    height: 250,
                    width: double.infinity,
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
                    restaurant.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        restaurant.rating.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                        ),
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
                    restaurant.description,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text("Phone"),
                    subtitle: Text(
                      restaurant.phone.isEmpty ? "Not available" : restaurant.phone,
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      // ✅ Pass context to method
                      onPressed: () => callRestaurant(context),
                      icon: const Icon(Icons.call),
                      label: const Text("Call Restaurant"),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      // ✅ Pass context to method
                      onPressed: () => openGoogleMaps(context),
                      icon: const Icon(Icons.location_on),
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