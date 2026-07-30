// lib/widgets/bottom_nav_bar.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.lightGrey.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withValues(alpha: 0.06), // Warm shadow instead of stark black
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(
              index: 0,
              icon: Icons.home_rounded,
              label: "Home",
            ),
            _navItem(
              index: 1,
              icon: Icons.favorite_rounded,
              label: "Favorites",
            ),
            _navItem(
              index: 2,
              icon: Icons.search_rounded,
              label: "Search",
            ),
            _navItem(
              index: 3,
              icon: Icons.map_rounded,
              label: "Map",
            ),
            _navItem(
              index: 4,
              icon: Icons.person_rounded,
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool selected = currentIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => onTap(index),
      splashColor: AppColors.primary.withValues(alpha: 0.1), // Cognac splash
      highlightColor: AppColors.primary.withValues(alpha: 0.05),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12) // Warm cognac tint
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                key: ValueKey(selected),
                size: 26, // Slightly reduced for a cleaner look with 5 items
                color: selected
                    ? AppColors.primary
                    : AppColors.grey,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11, // Slightly reduced to prevent crowding
                fontWeight: FontWeight.w600,
                color: selected
                    ? AppColors.primary
                    : AppColors.grey,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}