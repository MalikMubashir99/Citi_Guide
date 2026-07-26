// lib/widgets/hotel_card.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import '../screens/home/hotel_detail_screen.dart';
import '../model/hotel_model.dart';

class HotelCard extends StatelessWidget {
  final HotelModel hotel;

  const HotelCard({
    super.key,
    required this.hotel,
  });

  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    List<Widget> stars = [];

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(Icon(
          Icons.star_rounded,
          color: AppColors.secondary,
          size: 18,
        ));
      } else if (i == fullStars && hasHalfStar) {
        stars.add(Icon(
          Icons.star_half_rounded,
          color: AppColors.secondary,
          size: 18,
        ));
      } else {
        stars.add(Icon(
          Icons.star_outline_rounded,
          color: AppColors.secondary.withValues(alpha: 0.4),
          size: 18,
        ));
      }
    }
    return Row(children: stars);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 3,
      shadowColor: Colors.brown.shade900.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HotelDetailScreen(hotel: hotel),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: hotel.image.isEmpty
                      ? Container(
                          height: 200,
                          width: double.infinity,
                          color: AppColors.lightGrey,
                          child: Center(
                            child: Icon(
                              Icons.hotel_rounded,
                              size: 70,
                              color: AppColors.grey,
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
                            width: double.infinity,
                            color: AppColors.lightGrey,
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 70,
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              height: 200,
                              width: double.infinity,
                              color: AppColors.lightGrey,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // Gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: AppColors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hotel.rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Favorite button
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.favorite_border_rounded,
                        color: AppColors.error,
                        size: 22,
                      ),
                      onPressed: () {
                        // Toggle favorite
                      },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hotel.rating >= 4.5)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 12,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Premium',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'City ID: ${hotel.cityId}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.darkGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hotel.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildRatingStars(hotel.rating),
                      const SizedBox(width: 8),
                      Text(
                        hotel.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      ),
                      const Spacer(),
                      if (hotel.phone.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.lightGrey,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.phone_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                hotel.phone,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.darkGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
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