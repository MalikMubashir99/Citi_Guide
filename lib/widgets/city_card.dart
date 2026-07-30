// lib/widgets/city_card.dart
import 'package:app/screens/home/city_detail_screen.dart';
import 'package:flutter/material.dart';

class CityCard extends StatelessWidget {
  final String? image;
  final String city;
  final String cityId;

  const CityCard({
    super.key,
    this.image,
    required this.city,
    required this.cityId,
  });

  Widget _buildPlaceholder({bool isLoading = false}) {
    return Container(
      height: 140,
      width: 160,
      color: Colors.blue.shade50,
      child: isLoading
          ? Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.blue.withOpacity(0.6),
                ),
              ),
            )
          : const Icon(
              Icons.location_city_outlined,
              color: Colors.grey,
              size: 36,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CityDetailScreen(
              cityId: cityId,
              cityName: city,
              cityImage: image ?? '',
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      splashColor: Colors.blue.withOpacity(0.1),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: (image != null && image!.isNotEmpty)
                    ? Image.network(
                        image!,
                        height: 140,
                        width: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return _buildPlaceholder(isLoading: true);
                        },
                      )
                    : _buildPlaceholder(),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              city,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}