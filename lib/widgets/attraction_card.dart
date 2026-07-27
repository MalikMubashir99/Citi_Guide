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
          Icon(
            Icons.star_outline_rounded,
            color: AppColors.grey,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
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
        stars.add(Icon(
          Icons.star_rounded,
          color: AppColors.secondary,
          size: 14,
        ));
      } else if (i == fullStars && hasHalfStar) {
        stars.add(Icon(
          Icons.star_half_rounded,
          color: AppColors.secondary,
          size: 14,
        ));
      } else {
        stars.add(Icon(
          Icons.star_outline_rounded,
          color: AppColors.secondary.withValues(alpha: 0.4),
          size: 14,
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
    if (attraction == null) {
      return const SizedBox.shrink();
    }

    final String imageUrl = attraction.image ?? '';
    final String name = attraction.name ?? 'Unknown';
    final String description = attraction.description ?? 'No description available';
    final double rating = attraction.rating ?? 0.0;
    final String cityId = attraction.cityId ?? '';

    return SizedBox(
      width: 220, 
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        elevation: 2,
        shadowColor: Colors.brown.shade900.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
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
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: imageUrl.isEmpty
                    ? Container(
                        height: 130, // ✅ Reduced height
                        width: double.infinity,
                        color: AppColors.lightGrey,
                        child: Icon(
                          Icons.landscape_rounded,
                          size: 40,
                          color: AppColors.grey,
                        ),
                      )
                    : Image.network(
                        imageUrl,
                        height: 130, // ✅ Reduced height
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 130,
                          width: double.infinity,
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
                            height: 130,
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
              // Content
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.darkGrey,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // ✅ Fixed Row - using mainAxisSize: min and proper spacing
                    Wrap(
                      spacing: 4,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildRatingStars(rating),
                            const SizedBox(width: 4),
                            if (rating > 0)
                              Text(
                                rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.dark,
                                ),
                              ),
                          ],
                        ),
                        if (cityId.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 10,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  cityId,
                                  style: TextStyle(
                                    fontSize: 9,
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