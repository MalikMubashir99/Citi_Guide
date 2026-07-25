import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap; // ✅ Add this

  const CategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 85,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }
}