// lib/widgets/city_card.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:app/screens/home/city_detail_screen.dart';
import 'package:flutter/material.dart';

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
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: image.isNotEmpty
                  ? Image.network(
                      image,
                      height: 140,
                      width: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 140,
                        width: 160,
                        color: AppColors.lightGrey,
                        child: const Icon(
                          Icons.location_city,
                          color: Colors.grey,
                          size: 40,
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
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 140,
                      width: 160,
                      color: AppColors.lightGrey,
                      child: const Icon(
                        Icons.location_city,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            Text(
              city,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}