// lib/widgets/home_app_bar.dart
import 'dart:convert';
import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  final String userName;
  final String? profileImage;

  const HomeAppBar({
    super.key,
    required this.userName,
    this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting = "Good Morning";

    if (hour >= 12 && hour < 17) {
      greeting = "Good Afternoon";
    } else if (hour >= 17) {
      greeting = "Good Evening";
    }

    return Row(
      children: [
        // ✅ Dynamic Profile Image with Golden Ring
        Container(
          padding: const EdgeInsets.all(3), // Creates the ring width
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.goldenGradient, // Matches profile screens
            boxShadow: AppColors.warmGlow,
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primarySurface, // Warm tint fallback
            backgroundImage: _getImageProvider(profileImage),
            child: profileImage == null || profileImage!.isEmpty
                ? Icon(
                    Icons.person_rounded,
                    color: AppColors.grey,
                    size: 28,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$greeting 👋",
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName.isNotEmpty ? userName : "Guest",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        
        // ✅ Notification Bell
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.lightGrey.withValues(alpha: 0.6),
              width: 1,
            ),
            boxShadow: AppColors.subtleShadow, // Lifted off background
          ),
          child: Stack(
            clipBehavior: Clip.none, // Allow dot to overflow
            children: [
              Icon(
                Icons.notifications_none_rounded,
                color: AppColors.dark,
                size: 24,
              ),
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.error, // Burnt sienna instead of pure red
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surface, // White border to separate from bell
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  // ✅ Get image provider
  ImageProvider? _getImageProvider(String? image) {
    if (image == null || image.isEmpty) return null;

    try {
      if (image.length > 100 && !image.startsWith('http')) {
        String imageData = image;
        if (imageData.startsWith('data:image')) {
          imageData = imageData.split(',').last;
        }
        final bytes = base64Decode(imageData);
        return MemoryImage(bytes);
      }

      if (image.startsWith('http')) {
        return NetworkImage(image);
      }

      return null;
    } catch (e) {
      return null; // Removed print statement for clean production code
    }
  }
}