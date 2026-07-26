// lib/admin/widgets/city_tile.dart
import 'package:app/admin/models/city_model.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CityTile extends StatelessWidget {
  final CityModel city;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CityTile({
    super.key,
    required this.city,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey, width: 1),
        boxShadow: AppColors.subtleShadow,
      ),
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 50,
            height: 50,
            color: AppColors.lightGrey,
            child: city.image.isNotEmpty
                ? Image.network(
                    city.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.broken_image,
                      color: AppColors.grey,
                      size: 30,
                    ),
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        width: 50,
                        height: 50,
                        color: AppColors.lightGrey,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Icon(
                    Icons.location_city_rounded,
                    color: AppColors.grey,
                    size: 30,
                  ),
          ),
        ),
        title: Text(
          city.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.dark,
          ),
        ),
        subtitle: Text(
          city.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.darkGrey,
            fontSize: 13,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_rounded, color: AppColors.primary, size: 20),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: Icon(Icons.delete_rounded, color: AppColors.error, size: 20),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}