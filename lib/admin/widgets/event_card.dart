// lib/admin/widgets/event_card.dart
import 'package:app/admin/models/event_model.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';


class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventCard({
    super.key,
    required this.event,
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
              child: event.image.isNotEmpty
                  ? Image.network(
                      event.image,
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
                      Icons.event_rounded,
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
                  event.title,
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
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.date.isNotEmpty ? event.date : 'No date',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.cityId,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  event.location.isNotEmpty ? event.location : 'No location',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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