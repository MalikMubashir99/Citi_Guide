import 'package:app/screens/home/city_detail_screen.dart';
import 'package:flutter/material.dart';

class CityCard extends StatelessWidget {
  final String image;
  final String city;
  final String cityId; // ✅ Add this

  const CityCard({
    super.key,
    required this.image,
    required this.city,
    required this.cityId,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CityDetailScreen(
              cityId: cityId,
              cityName: city,
              cityImage:image,
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                image,
                height: 140,
                width: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 140,
                  width: 160,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              city,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}