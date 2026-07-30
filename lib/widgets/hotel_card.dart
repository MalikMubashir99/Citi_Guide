import 'package:app/model/hotel_model.dart';
import 'package:app/screens/home/hotel_detail_screen.dart';
import 'package:flutter/material.dart';

class HotelCard extends StatelessWidget {
  final HotelModel hotel;

  const HotelCard({super.key, required this.hotel});

  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    List<Widget> stars = [];

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(const Icon(
          Icons.star_rounded,
          color: Color(0xFFF59E0B), // Amber/Gold
          size: 13,
        ));
      } else if (i == fullStars && hasHalfStar) {
        stars.add(const Icon(
          Icons.star_half_rounded,
          color: Color(0xFFF59E0B), // Amber/Gold
          size: 13,
        ));
      } else {
        stars.add(const Icon(
          Icons.star_outline_rounded,
          color: Color(0xFFE2E8F0), // Light Grey
          size: 13,
        ));
      }
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }

  // ✅ Placeholder Widget
  Widget _buildPlaceholder({bool isLoading = false}) {
    return Container(
      height: 120,
      width: double.infinity,
      color: const Color(0xFFFDF6F0), // Warm off-white
      child: isLoading
          ? const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF2563EB), // Primary Blue
                ),
              ),
            )
          : const Icon(
              Icons.hotel_outlined,
              size: 36,
              color: Color(0xFF64748B), // Grey
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE2E8F0).withOpacity(0.5),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000), // Black with 10% opacity
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HotelDetailScreen(hotel: hotel),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: hotel.image.isEmpty
                      ? _buildPlaceholder()
                      : Image.network(
                          hotel.image,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return _buildPlaceholder(isLoading: true);
                          },
                        ),
                ),
                
                // Content Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        hotel.name,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A), // Dark
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 12,
                            color: Color(0xFF2563EB), // Primary Blue
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              hotel.cityId,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF334155), // Dark Grey
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      
                      // Description
                      Text(
                        hotel.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF334155), // Dark Grey
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Bottom Row (Rating & Phone) - FIXED
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Rating - Wrapped in Flexible to prevent overflow
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildRatingStars(hotel.rating),
                                const SizedBox(width: 4),
                                Text(
                                  hotel.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A), // Dark
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Phone Tag - Keep as is or wrap in Flexible if needed
                          if (hotel.phone.isNotEmpty)
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFF2563EB).withOpacity(0.15),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.phone_rounded,
                                      size: 10,
                                      color: Color(0xFF2563EB), // Primary Blue
                                    ),
                                    const SizedBox(width: 3),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 65),
                                      child: Text(
                                        hotel.phone,
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: Color(0xFF2563EB), // Primary Blue
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}