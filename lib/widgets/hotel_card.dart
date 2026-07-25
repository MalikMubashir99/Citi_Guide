import 'package:app/screens/home/hotel_detail_screen.dart';
import 'package:flutter/material.dart';
import '../model/hotel_model.dart';

class HotelCard extends StatelessWidget {
  final HotelModel hotel;

  const HotelCard({
    super.key,
    required this.hotel,
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
              builder: (_) => HotelDetailScreen(hotel: hotel),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            hotel.image.isEmpty
                ? Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.hotel,
                        size: 70,
                      ),
                    ),
                  )
                : Image.network(
                    hotel.image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 70,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    hotel.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildRatingStars(hotel.rating),
                      const SizedBox(width: 5),
                      Text(
                        hotel.rating.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
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