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

  // ✅ Unified Placeholder Widget
  Widget _buildPlaceholder({bool isLoading = false}) {
    return Container(
      height: 140,
      width: 160,
      color: AppColors.primarySurface, // Warm ultra-light tint
      child: isLoading
          ? Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
              ),
            )
          : Icon(
              Icons.location_city_outlined, // Outlined icon for modern look
              color: AppColors.grey, // Warm grey
              size: 36,
            ),
    );
  }

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
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      splashColor: AppColors.primary.withValues(alpha: 0.1), // Warm cognac ripple
      child: Container(
        // ✅ Fixed width to match the image so the tile looks uniform
        width: 160, 
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Image with Subtle Warm Shadow
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppColors.subtleShadow, // Warm drop shadow
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: image.isNotEmpty
                    ? Image.network(
                        image,
                        height: 140,
                        width: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return _buildPlaceholder(isLoading: true);
                        },
                      )
                    : _buildPlaceholder(),
              ),
            ),
            const SizedBox(height: 10),
            
            // ✅ City Name
            Text(
              city,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
                letterSpacing: 0.2,
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