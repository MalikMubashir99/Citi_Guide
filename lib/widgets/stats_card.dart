// lib/widgets/stats_card.dart
import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final int reviews;
  final int favorites;
  final int cities;

  const StatsCard({
    super.key,
    required this.reviews,
    required this.favorites,
    required this.cities,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          label: 'Reviews',
          count: reviews,
          icon: Icons.comment_rounded,
          color: Colors.blue,
        ),
        _buildStatItem(
          label: 'Favorites',
          count: favorites,
          icon: Icons.favorite_rounded,
          color: Colors.red,
        ),
        _buildStatItem(
          label: 'Cities',
          count: cities,
          icon: Icons.location_city_rounded,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String label,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}