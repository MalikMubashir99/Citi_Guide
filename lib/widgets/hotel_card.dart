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
          color: Color(0xFFF59E0B),
          size: 12, // slightly smaller
        ));
      } else if (i == fullStars && hasHalfStar) {
        stars.add(const Icon(
          Icons.star_half_rounded,
          color: Color(0xFFF59E0B),
          size: 12,
        ));
      } else {
        stars.add(const Icon(
          Icons.star_outline_rounded,
          color: Color(0xFFE2E8F0),
          size: 12,
        ));
      }
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }

  Widget _buildPlaceholder({bool isLoading = false}) {
    return Container(
      height: 120,
      width: double.infinity,
      color: const Color(0xFFFDF6F0),
      child: isLoading
          ? const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF2563EB),
                ),
              ),
            )
          : const Icon(
              Icons.hotel_outlined,
              size: 36,
              color: Color(0xFF64748B),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230, 
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
              color: Color(0x1A000000),
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
                // Image
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
                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotel.name,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 12,
                            color: Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              hotel.cityId,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF334155),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hotel.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF334155),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // ✅ FIXED BOTTOM ROW
                      Row(
                        children: [
                          // Rating - takes 2/3 of space
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                _buildRatingStars(hotel.rating),
                                const SizedBox(width: 4),
                                Text(
                                  hotel.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Phone tag - takes 1/3 of space
                          if (hotel.phone.isNotEmpty)
                            Expanded(
                              flex: 1,
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
                                      color: Color(0xFF2563EB),
                                    ),
                                    const SizedBox(width: 3),
                                    Flexible(
                                      child: Text(
                                        hotel.phone,
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: Color(0xFF2563EB),
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