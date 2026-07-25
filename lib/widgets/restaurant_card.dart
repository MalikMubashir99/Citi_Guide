import 'package:app/model/restaurant_model.dart';
import 'package:app/screens/home/restaurant_detail_screen.dart';
import 'package:flutter/material.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantCard({
    super.key,
    required this.restaurant,
  });

  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor();
    List<Widget> stars = [];

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(const Icon(Icons.star, color: Colors.amber, size: 16));
      } else {
        stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 16));
      }
    }
    return Row(children: stars);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RestaurantDetailScreen(
                restaurant: restaurant,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Image with error handling
            restaurant.image.isEmpty
                ? Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.restaurant,
                      size: 80,
                      color: Colors.grey,
                    ),
                  )
                : Image.network(
                    restaurant.image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.broken_image,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    restaurant.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildRatingStars(restaurant.rating),
                      const SizedBox(width: 5),
                      Text(
                        restaurant.rating.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  // ✅ Add phone number if available
                  if (restaurant.phone.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          restaurant.phone,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}