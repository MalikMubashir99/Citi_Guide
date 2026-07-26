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
    return Row(children: stars);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shadowColor: Colors.brown.shade900.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AttractionDetailScreen(attraction: attraction),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: attraction.image.isEmpty
                  ? Container(
                      width: 120,
                      height: 120,
                      color: AppColors.lightGrey,
                      child: Icon(
                        Icons.landscape_rounded,
                        size: 50,
                        color: AppColors.grey,
                      ),
                    )
                  : Image.network(
                      attraction.image,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 120,
                        height: 120,
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
                          width: 120,
                          height: 120,
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attraction.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      attraction.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.darkGrey,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildRatingStars(attraction.rating),
                        const SizedBox(width: 6),
                        Text(
                          attraction.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                attraction.cityId,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
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
            ),
          ],
        ),
      ),
    );
  }
}