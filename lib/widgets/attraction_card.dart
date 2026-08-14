// lib/widgets/attraction_card.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:app/model/attraction_model.dart';
import 'package:app/screens/home/attraction_details.dart';
import 'package:flutter/material.dart';

class AttractionCard extends StatelessWidget {
  final AttractionModel attraction;

  const AttractionCard({
    super.key,
    required this.attraction,
  });

  Widget _buildRatingStars(double rating) {
    if (rating == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_outline_rounded,
            color: AppColors.grey,
            size: 13,
          ),
          const SizedBox(width: 4),
          const Text(
            'No rating',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.grey,
            ),
          ),
        ],
      );
    }

    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    List<Widget> stars = [];

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(const Icon(
          Icons.star_rounded,
          color: AppColors.warning,
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: stars,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = attraction.image ?? '';
    final String name = attraction.name ?? 'Unknown';
    final String description = attraction.description ?? 'No description available';
    final double rating = attraction.rating ?? 0.0;
    final String cityId = attraction.cityId ?? '';

    return SizedBox(
      width: 230,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.lightGrey.withValues(alpha: 0.6),
            width: 1,
          ),
          boxShadow: AppColors.subtleShadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {
              if (attraction.id.isEmpty) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AttractionDetailScreen(attraction: attraction),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image Section ──
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: imageUrl.isEmpty
                      ? Container(
                          height: 130,
                          width: double.infinity,
                          color: AppColors.primarySurface,
                          child: const Icon(
                            Icons.landscape_outlined,
                            size: 36,
                            color: AppColors.grey,
                          ),
                        )
                      : Image.network(
                          imageUrl,
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 130,
                            width: double.infinity,
                            color: AppColors.primarySurface,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              size: 36,
                              color: AppColors.grey,
                            ),
                          ),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              height: 130,
                              width: double.infinity,
                              color: AppColors.primarySurface,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                
                // ── Content Section ──
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        name,
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
                      
                      // Description
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.darkGrey,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Bottom Row (Rating & Location Tag)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Rating
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildRatingStars(rating),
                              if (rating > 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.dark,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          
                          // Location Tag
                          if (cityId.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    size: 9,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 3),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 60),
                                    child: Text(
                                      cityId,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
        ),
      ),
    );
  }
}