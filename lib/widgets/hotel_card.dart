// lib/widgets/hotel_card.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:app/model/hotel_model.dart';
import 'package:app/screens/home/hotel_detail_screen.dart';
import 'package:flutter/material.dart';

class HotelCard extends StatelessWidget {
  final HotelModel hotel;

  const HotelCard({super.key, required this.hotel});

  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    List<Widget> stars = [];

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(
          Icon(
            Icons.star_rounded,
            color: AppColors.secondary,
            size: 14, // ✅ Reduced size
          ),
        );
      } else if (i == fullStars && hasHalfStar) {
        stars.add(
          Icon(Icons.star_half_rounded, color: AppColors.secondary, size: 14),
        );
      } else {
        stars.add(
          Icon(
            Icons.star_outline_rounded,
            color: AppColors.secondary.withValues(alpha: 0.5),
            size: 14,
          ),
        );
      }
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        elevation: 2,
        shadowColor: Colors.brown.shade900.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: InkWell(
          onTap: () {
            // ✅ Add debug print
            print('🟢 Tapped on hotel: ${hotel.name}');

            // ✅ Correct navigation
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HotelDetailScreen(hotel: hotel),
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: hotel.image.isEmpty
                    ? Container(
                        height: 120, // ✅ Reduced from 140
                        width: 200, // ✅ Match SizedBox width
                        color: AppColors.lightGrey,
                        child: Icon(
                          Icons.hotel_rounded,
                          size: 40,
                          color: AppColors.grey,
                        ),
                      )
                    : Image.network(
                        hotel.image,
                        height: 120, // ✅ Reduced from 140
                        width: 200, // ✅ Match SizedBox width
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 120,
                          width: 200,
                          color: AppColors.lightGrey,
                          child: Icon(
                            Icons.broken_image,
                            size: 40,
                            color: AppColors.grey,
                          ),
                        ),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 120,
                            width: 200,
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
              // Content
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: TextStyle(
                        fontSize: 13, // ✅ Reduced from 14
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 10,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            hotel.cityId,
                            style: TextStyle(
                              fontSize: 10, // ✅ Reduced from 11
                              color: AppColors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hotel.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10, // ✅ Reduced from 11
                        color: AppColors.darkGrey,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildRatingStars(hotel.rating),
                        const SizedBox(width: 4),
                        Text(
                          hotel.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 10, // ✅ Reduced from 11
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark,
                          ),
                        ),
                        const Spacer(),
                        if (hotel.phone.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.phone_rounded,
                                  size: 8,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  hotel.phone,
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}
