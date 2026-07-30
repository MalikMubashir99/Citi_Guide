// lib/widgets/restaurant_card.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:app/model/restaurant_model.dart';
import 'package:app/screens/home/restaurant_detail_screen.dart';
import 'package:flutter/material.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantCard({super.key, required this.restaurant});

  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    List<Widget> stars = [];

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(const Icon(
          Icons.star_rounded,
          color: AppColors.warning, // Marigold color for stars
          size: 13,
        ));
      } else if (i == fullStars && hasHalfStar) {
        stars.add(const Icon(
          Icons.star_half_rounded,
          color: AppColors.warning,
          size: 13,
        ));
      } else {
        stars.add(const Icon(
          Icons.star_outline_rounded,
          color: AppColors.lightGrey,
          size: 13,
        ));
      }
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }

  // ✅ Unified Placeholder Widget
  Widget _buildPlaceholder({bool isLoading = false}) {
    return Container(
      height: 120,
      width: double.infinity,
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
          : const Icon(
              Icons.restaurant_outlined, // Outlined icon
              size: 36,
              color: AppColors.grey,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210, // Unified width with Hotel & Attraction cards
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.lightGrey.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: AppColors.subtleShadow, // Warm shadow instead of stark black
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: restaurant.image.isEmpty
                      ? _buildPlaceholder()
                      : Image.network(
                          restaurant.image,
                          height: 120,
                          width: double.infinity, // Properly fills container
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return _buildPlaceholder(isLoading: true);
                          },
                        ),
                ),
                
                // Content Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              restaurant.cityId,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.darkGrey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      
                      // Description
                      Text(
                        restaurant.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.darkGrey,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Rating Row
                      Row(
                        children: [
                          _buildRatingStars(restaurant.rating),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark,
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
      ),
    );
  }
}