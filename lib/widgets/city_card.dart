// lib/widgets/city_card.dart
import 'package:flutter/material.dart';
import '../screens/home/city_detail_screen.dart';
import 'package:app/core/constants/app_colors.dart';


class CityCard extends StatelessWidget {
  final String image;
  final String city;
  final String cityId;
  final int? placesCount;

  const CityCard({
    super.key,
    required this.image,
    required this.city,
    required this.cityId,
    this.placesCount,
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    _getCityImageUrl(city),
                    height: 140,
                    width: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 140,
                      width: 160,
                      color: AppColors.lightGrey,
                      child: Icon(
                        Icons.location_city_rounded,
                        color: AppColors.grey,
                        size: 50,
                      ),
                    ),
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 140,
                        width: 160,
                        color: AppColors.lightGrey,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Gradient overlay for better text visibility
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                  ),
                ),
                // Places count badge
                if (placesCount != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${placesCount} places',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              city,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Explore ${city}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCityImageUrl(String cityName) {
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