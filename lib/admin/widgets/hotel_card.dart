// lib/admin/widgets/hotel_card.dart
import 'package:flutter/material.dart';
import '../../admin/models/hotel_model.dart';
import '../../core/constants/app_colors.dart';

class HotelCard extends StatelessWidget {
  final HotelModel hotel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HotelCard({
    super.key,
    required this.hotel,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey, width: 1),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              color: AppColors.lightGrey,
              child: hotel.image.isNotEmpty
                  ? Image.network(
                      hotel.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.broken_image,
                        color: AppColors.grey,
                        size: 30,
                      ),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                    )
                  : Icon(
                      Icons.hotel_rounded,
                      color: AppColors.grey,
                      size: 40,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hotel.cityId,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hotel.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  hotel.phone.isNotEmpty ? hotel.phone : 'No phone',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit_rounded, color: AppColors.primary),
                onPressed: onEdit,
                tooltip: 'Edit',
              ),
              IconButton(
                icon: Icon(Icons.delete_rounded, color: AppColors.error),
                onPressed: onDelete,
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }
}