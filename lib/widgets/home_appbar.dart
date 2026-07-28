// lib/widgets/home_app_bar.dart
import 'dart:convert';
import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  final String userName;
  final String? profileImage; // ✅ Add this

  const HomeAppBar({
    super.key,
    required this.userName,
    this.profileImage, // ✅ Optional
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
        // ✅ Dynamic Profile Image
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: _getImageProvider(profileImage),
            child: profileImage == null || profileImage!.isEmpty
                ? const Icon(
                    Icons.person,
                    color: Colors.grey,
                    size: 30,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 15),
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.lightGrey,
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              Icon(
                Icons.notifications_none_rounded,
                color: AppColors.dark,
                size: 26,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
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
      // ✅ Check if it's Base64
      if (image.length > 100 && !image.startsWith('http')) {
        String imageData = image;
        if (imageData.startsWith('data:image')) {
          imageData = imageData.split(',').last;
        }
        final bytes = base64Decode(imageData);
        return MemoryImage(bytes);
      }

      // ✅ If it's a URL
      if (image.startsWith('http')) {
        return NetworkImage(image);
      }

      return null;
    } catch (e) {
      print('❌ Error loading profile image: $e');
      return null;
    }
  }
}