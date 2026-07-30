// lib/widgets/bottom_nav_bar.dart
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
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: "Home",
            ),
            _navItem(
              index: 1,
              icon: Icons.search_rounded,
              selectedIcon: Icons.search_rounded,
              label: "Search",
            ),
            _navItem(
              index: 2,
              icon: Icons.map_outlined,
              selectedIcon: Icons.map_rounded,
              label: "Map",
            ),
            _navItem(
              index: 3,
              icon: Icons.favorite_border_rounded,
              selectedIcon: Icons.favorite_rounded,
              label: "Saved",
            ),
            _navItem(
              index: 4,
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
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
    required IconData selectedIcon,
    required String label,
  }) {
    final bool selected = currentIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => onTap(index),
      splashColor: Colors.blue.withValues(alpha: 0.1),
      highlightColor: Colors.blue.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.blue.withValues(alpha: 0.12)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                selected ? selectedIcon : icon,
                size: 24,
                color: selected ? Colors.blue : Colors.grey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}