// lib/widgets/search_bar_widget.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSearch;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.subtleShadow,
        border: Border.all(
          color: AppColors.lightGrey,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: "Search destination...",
          hintStyle: TextStyle(
            color: AppColors.grey,
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          suffixIcon: IconButton(
            icon: Icon(Icons.close, color: AppColors.grey),
            onPressed: () {
              controller.clear();
              if (onSearch != null) onSearch!();
            },
          ),
        ),
        onSubmitted: (_) {
          if (onSearch != null) onSearch!();
        },
      ),
    );
  }
}