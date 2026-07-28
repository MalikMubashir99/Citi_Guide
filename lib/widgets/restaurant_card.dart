// lib/widgets/restaurant_card.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:app/model/restaurant_model.dart';
import 'package:app/screens/home/restaurant_detail_screen.dart';
import 'package:flutter/material.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantCard({super.key, required this.restaurant});

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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
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
                child: restaurant.image.isEmpty
                    ? Container(
                        height: 120,
                        width: 200,
                        color: AppColors.lightGrey,
                        child: Icon(
                          Icons.restaurant_rounded,
                          size: 40,
                          color: AppColors.grey,
                        ),
                      )
                    : Image.network(
                        restaurant.image,
                        height: 120,
                        width: 200,
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
                      restaurant.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
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
                            restaurant.cityId,
                            style: TextStyle(
                              fontSize: 10,
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
                      restaurant.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.darkGrey,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < restaurant.rating.floor()
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: AppColors.secondary,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          restaurant.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 10,
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
    );
  }
}