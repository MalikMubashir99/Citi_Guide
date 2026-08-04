// lib/screens/home/favorites_screen.dart
import 'package:app/model/attraction_model.dart';
import 'package:app/model/hotel_model.dart';
import 'package:app/model/restaurant_model.dart';
import 'package:app/model/event_model.dart';
import 'package:app/screens/home/attraction_details.dart';
import 'package:app/screens/home/hotel_detail_screen.dart';
import 'package:app/screens/home/restaurant_detail_screen.dart';
import 'package:app/screens/home/event_detail_screen.dart';
import 'package:app/services/favorite_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Local Blue Theme ──────────────────────────────────────────────────────────
class _AppColors {
  static const Color background = Color(0xFFF8FAFC);
  static const Color white = Colors.white;
  static const Color dark = Color(0xFF0F172A);
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color error = Color(0xFFDC2626);
  static const Color lightGrey = Color(0xFFE2E8F0);
  static const Color grey = Color(0xFF64748B);
  static const Color star = Color(0xFFF59E0B);
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoriteService favoriteService = FavoriteService();

  Future<Map<String, dynamic>?> _getItemDetails(String itemId) async {
    try {
      var doc = await favoriteService.getAttraction(itemId);
      if (doc.exists) {
        return {'type': 'attraction', 'data': doc.data() as Map<String, dynamic>};
      }
    } catch (e) {}
    try {
      var doc = await favoriteService.getHotel(itemId);
      if (doc.exists) {
        return {'type': 'hotel', 'data': doc.data() as Map<String, dynamic>};
      }
    } catch (e) {}
    try {
      var doc = await favoriteService.getRestaurant(itemId);
      if (doc.exists) {
        return {'type': 'restaurant', 'data': doc.data() as Map<String, dynamic>};
      }
    } catch (e) {}
    return null;
  }

  // ─── Build card from map ──────────────────────────────────────────────────

  Widget _buildCardFromMap(Map<String, dynamic> data, String type, String favoriteId, String itemId) {
    final name = data['name'] ?? data['title'] ?? 'Unknown';
    final image = data['image'] ?? '';
    final cityId = data['cityId'] ?? '';
    final rating = (data['rating'] ?? 0).toDouble();

    Widget card = Container(
      decoration: BoxDecoration(
        color: _AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AppColors.lightGrey.withOpacity(0.5), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
            child: image.isNotEmpty
                ? Image.network(
                    image,
                    width: 120,
                    height: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120,
                      height: 130,
                      color: _AppColors.lightGrey,
                      child: Icon(_getIconForType(type), color: _AppColors.grey),
                    ),
                  )
                : Container(
                    width: 120,
                    height: 130,
                    color: _AppColors.lightGrey,
                    child: Icon(_getIconForType(type), color: _AppColors.grey),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _AppColors.dark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cityId.isNotEmpty ? cityId : _getDefaultLocation(type),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: _AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < rating.floor()
                              ? Icons.star_rounded
                              : i < rating
                                  ? Icons.star_half_rounded
                                  : Icons.star_border_rounded,
                          color: _AppColors.star,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _AppColors.dark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // Wrap with GestureDetector for navigation
    return GestureDetector(
      onTap: () => _navigateToDetail(type, itemId, data),
      child: card,
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'hotel': return Icons.hotel_rounded;
      case 'restaurant': return Icons.restaurant_rounded;
      case 'event': return Icons.event_rounded;
      default: return Icons.place_rounded;
    }
  }

  String _getDefaultLocation(String type) {
    switch (type) {
      case 'hotel': return 'Hotel';
      case 'restaurant': return 'Restaurant';
      case 'event': return 'Event';
      default: return 'Landmark';
    }
  }

  void _navigateToDetail(String type, String itemId, Map<String, dynamic> data) {
  Widget screen;
  switch (type) {
    case 'attraction':
      screen = AttractionDetailScreen(attraction: AttractionModel.fromFirestore(data, itemId));
      break;
    case 'hotel':
      screen = HotelDetailScreen(hotel: HotelModel.fromFirestore(data, itemId));
      break;
    case 'restaurant':
      screen = RestaurantDetailScreen(restaurant: RestaurantModel.fromFirestore(data, itemId));
      break;
    default:
      return;
  }
  Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}
  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      appBar: AppBar(
        title: Text("Favorites", style: GoogleFonts.poppins(color: _AppColors.dark, fontWeight: FontWeight.w600)),
        backgroundColor: _AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _AppColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: favoriteService.getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: _AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _AppColors.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error_outline_rounded, size: 60, color: _AppColors.error),
                    ),
                    const SizedBox(height: 16),
                    Text('Error loading favorites', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: _AppColors.error)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _AppColors.primary,
                        foregroundColor: _AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text("Retry", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _AppColors.lightGrey.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border_rounded, size: 80, color: _AppColors.grey),
                  ),
                  const SizedBox(height: 20),
                  Text("No Favorites Found", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: _AppColors.dark)),
                  const SizedBox(height: 8),
                  Text("Start exploring and save your favorite places!", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: _AppColors.grey)),
                ],
              ),
            );
          }

          final favorites = snapshot.data!.docs;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Text('${favorites.length} saved places', style: GoogleFonts.poppins(fontSize: 16, color: _AppColors.grey, fontWeight: FontWeight.w500)),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    var favorite = favorites[index];
                    final itemId = favorite['attractionId'];
                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _getItemDetails(itemId),
                      builder: (context, itemSnapshot) {
                        if (itemSnapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            height: 130,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: _AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _AppColors.lightGrey.withOpacity(0.5)),
                            ),
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: _AppColors.primary)),
                          );
                        }
                        if (itemSnapshot.hasError || !itemSnapshot.hasData || itemSnapshot.data == null) {
                          return _buildUnavailableItem(favorite.id);
                        }

                        final item = itemSnapshot.data!;
                        final data = item['data'];
                        final type = item['type'];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Stack(
                            children: [
                              _buildCardFromMap(data, type, favorite.id, itemId),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => _confirmRemove(favorite.id, data['name'] ?? 'item'),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: _AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close_rounded, color: _AppColors.white, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUnavailableItem(String favoriteId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AppColors.lightGrey.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.delete_outline_rounded, color: _AppColors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text("Item not available", style: GoogleFonts.poppins(color: _AppColors.grey, fontWeight: FontWeight.w500)),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: _AppColors.error),
            onPressed: () => _confirmRemove(favoriteId, 'this item'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemove(String favoriteId, String name) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Remove Favorite", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: _AppColors.dark)),
        content: Text("Remove '$name' from favorites?", style: GoogleFonts.poppins(color: _AppColors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: GoogleFonts.poppins(color: _AppColors.primary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _AppColors.error,
              foregroundColor: _AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text("Remove", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await favoriteService.removeFavorite(favoriteId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$name removed", style: GoogleFonts.poppins(color: _AppColors.white, fontWeight: FontWeight.w500)),
          backgroundColor: _AppColors.dark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}