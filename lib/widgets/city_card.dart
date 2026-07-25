import 'package:app/screens/home/city_detail_screen.dart';
import 'package:flutter/material.dart';
// lib/widgets/city_card.dart
class CityCard extends StatelessWidget {
  final String image;
  final String city;
  final String cityId;

  const CityCard({
    super.key,
    required this.image,
    required this.city,
    required this.cityId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CityDetailScreen(
              cityId: cityId,
              cityName: city,
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
              child: Image.network(
                _getCityImageUrl(city), // ✅ Using network image
                height: 140,
                width: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 140,
                  width: 160,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.location_city, color: Colors.grey, size: 40),
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

  String _getCityImageUrl(String cityName) {
    // ✅ Use placeholder images from the internet
    switch (cityName.toLowerCase()) {
      case 'karachi':
        return 'https://picsum.photos/seed/karachi/200/200';
      case 'lahore':
        return 'https://picsum.photos/seed/lahore/200/200';
      case 'islamabad':
        return 'https://picsum.photos/seed/islamabad/200/200';
      case 'hunza':
        return 'https://picsum.photos/seed/hunza/200/200';
      default:
        return 'https://picsum.photos/seed/city/200/200';
    }
  }
}