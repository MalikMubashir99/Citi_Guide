// lib/widgets/attraction_card.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import '../model/attraction_model.dart';
import '../screens/home/attraction_details.dart';

class AttractionCard extends StatelessWidget {
  final AttractionModel attraction;

  const AttractionCard({
    super.key, 
    required this.attraction,
  });

  Widget _buildRatingStars(double rating) {
    // ✅ Handle null/empty rating
    if (rating == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_outline_rounded,
            color: AppColors.grey,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'No rating',
            style: TextStyle(
              fontSize: 12,
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
        stars.add(Icon(
          Icons.star_rounded,
          color: AppColors.secondary,
          size: 16,
        ));
      } else if (i == fullStars && hasHalfStar) {
        stars.add(Icon(
          Icons.star_half_rounded,
          color: AppColors.secondary,
          size: 16,
        ));
      } else {
        stars.add(Icon(
          Icons.star_outline_rounded,
          color: AppColors.secondary.withValues(alpha: 0.4),
          size: 16,
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
    // ✅ Handle null attraction
    if (attraction == null) {
      return const SizedBox.shrink();
    }

    // ✅ Get safe values with fallbacks
    final String imageUrl = attraction.image ?? '';
    final String name = attraction.name ?? 'Unknown';
    final String description = attraction.description ?? 'No description available';
    final double rating = attraction.rating ?? 0.0;
    final String cityId = attraction.cityId ?? '';

    return SizedBox(
      width: 280,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        elevation: 3,
        shadowColor: Colors.brown.shade900.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            // ✅ Check if attraction has valid data before navigating
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
              // ✅ Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: imageUrl.isEmpty
                    ? Container(
                        height: 160,
                        width: double.infinity,
                        color: AppColors.lightGrey,
                        child: Icon(
                          Icons.landscape_rounded,
                          size: 50,
                          color: AppColors.grey,
                        ),
                      )
                    : Image.network(
                        imageUrl,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 160,
                          width: double.infinity,
                          color: AppColors.lightGrey,
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: AppColors.grey,
                          ),
                        ),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 160,
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
              // ✅ Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.darkGrey,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // ✅ Rating Row - Fixed
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildRatingStars(rating),
                        const SizedBox(width: 6),
                        if (rating > 0)
                          Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark,
                            ),
                          ),
                        const Spacer(),
                        // ✅ City Badge
                        if (cityId.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 12,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  cityId,
                                  style: TextStyle(
                                    fontSize: 10,
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