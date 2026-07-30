// lib/widgets/search_bar_widget.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSearch;
  final ValueChanged<String>? onChanged;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onSearch,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56, // Slightly reduced for better proportions
      decoration: BoxDecoration(
        color: AppColors.surface, // Pure white for consistency
        borderRadius: BorderRadius.circular(16), // Matched to global standard
        border: Border.all(
          color: AppColors.lightGrey.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: AppColors.subtleShadow,
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: AppColors.dark,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: "Search destination...",
          hintStyle: const TextStyle(
            color: AppColors.grey,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded, // Outlined/rounded variant
            color: AppColors.secondaryDark, // Deep Gold hint to match CustomTextField
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          // ✅ Conditionally show clear button based on text length
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink(); // Hide if empty
              }
              return IconButton(
                icon: const Icon(
                  Icons.close_rounded, // Rounded variant
                  color: AppColors.grey,
                  size: 20,
                ),
                onPressed: () {
                  controller.clear();
                  if (onSearch != null) onSearch!();
                  // Trigger onChanged with empty string to update UI immediately
                  if (onChanged != null) onChanged!('');
                },
              );
            },
          ),
        ),
        onChanged: onChanged,
        onSubmitted: (_) {
          if (onSearch != null) onSearch!();
        },
      ),
    );
  }
}