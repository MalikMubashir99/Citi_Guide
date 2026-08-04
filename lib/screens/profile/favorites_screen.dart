// lib/screens/profile/favorites_screen.dart
import 'package:app/model/attraction_model.dart';
import 'package:app/model/hotel_model.dart';
import 'package:app/model/restaurant_model.dart';
import 'package:app/screens/home/attraction_details.dart';
import 'package:app/screens/home/hotel_detail_screen.dart';
import 'package:app/screens/home/restaurant_detail_screen.dart';
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
    } catch (_) {}

    try {
      var doc = await favoriteService.getHotel(itemId);
      if (doc.exists) {
        return {'type': 'hotel', 'data': doc.data() as Map<String, dynamic>};
      }
    } catch (_) {}

    try {
      var doc = await favoriteService.getRestaurant(itemId);
      if (doc.exists) {
        return {'type': 'restaurant', 'data': doc.data() as Map<String, dynamic>};
      }
    } catch (_) {}

    return null;
  }

  // ─── Navigation ──────────────────────────────────────────────────────────────

  void _navigateToDetail(String type, String itemId, Map<String, dynamic> data) {
    Widget screen;
    switch (type) {
      case 'attraction':
        screen = AttractionDetailScreen(
          attraction: AttractionModel.fromFirestore(data, itemId),
        );
        break;
      case 'hotel':
        screen = HotelDetailScreen(
          hotel: HotelModel.fromFirestore(data, itemId),
        );
        break;
      case 'restaurant':
        screen = RestaurantDetailScreen(
          restaurant: RestaurantModel.fromFirestore(data, itemId),
        );
        break;
      default:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // ─── Remove dialog ──────────────────────────────────────────────────────────

  void _showRemoveDialog(String name, String favoriteId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Remove Favorite",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: _AppColors.dark,
          ),
        ),
        content: Text(
          "Remove '$name' from your favorites?",
          style: GoogleFonts.poppins(color: _AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(
                color: _AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _AppColors.error,
              foregroundColor: _AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Remove",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await favoriteService.removeFavorite(favoriteId);
      if (!mounted) return;
      _showRemovedSnackBar();
    }
  }

  void _showRemovedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Removed from favorites",
          style: GoogleFonts.poppins(
            color: _AppColors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: _AppColors.dark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      appBar: AppBar(
        title: Text(
          "Favorites",
          style: GoogleFonts.poppins(
            color: _AppColors.dark,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: _AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _AppColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: _AppColors.lightGrey,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: favoriteService.getFavorites(),
        builder: (context, snapshot) {
          // ── Loading State ──
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: _AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Loading favorites...",
                    style: GoogleFonts.poppins(
                      color: _AppColors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          // ── Error State ──
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _AppColors.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        size: 36,
                        color: _AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Something went wrong",
                      style: GoogleFonts.poppins(
                        color: _AppColors.dark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: _AppColors.grey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() {}),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(
                          "Try Again",
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _AppColors.primary,
                          foregroundColor: _AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ── Empty State ──
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: _AppColors.lightGrey.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 48,
                        color: _AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "No Favorites Yet",
                      style: GoogleFonts.poppins(
                        color: _AppColors.dark,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Start exploring and save your\nfavorite places to find them here.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: _AppColors.grey,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          // ── Favorites List (vertical, full‑width cards) ──────────────────
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  "${docs.length} saved ${docs.length == 1 ? 'place' : 'places'}",
                  style: GoogleFonts.poppins(
                    color: _AppColors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var favorite = docs[index];
                    final itemId = favorite['attractionId'];

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _getItemDetails(itemId),
                      builder: (context, itemSnapshot) {
                        if (itemSnapshot.connectionState == ConnectionState.waiting) {
                          return _buildShimmerCard();
                        }

                        if (itemSnapshot.hasError ||
                            !itemSnapshot.hasData ||
                            itemSnapshot.data == null) {
                          return _buildUnavailableCard(favorite);
                        }

                        final item = itemSnapshot.data!;
                        final data = item['data'];
                        final type = item['type'];
                        final name = data['name'] ?? data['title'] ?? 'Unknown';
                        final image = data['image'] ?? '';
                        final rating = (data['rating'] ?? 0).toDouble();

                        // ✅ Fix: Show a user‑friendly location label
                        // If there's a 'cityName' field, use it; otherwise fallback to type.
                        final location = data['cityName'] ?? _getDefaultLocation(type);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildFullWidthCard(
                            name: name,
                            image: image,
                            rating: rating,
                            location: location,
                            type: type,
                            favoriteId: favorite.id,
                            itemId: itemId,
                            data: data,
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

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _getDefaultLocation(String type) {
    switch (type) {
      case 'hotel': return 'Hotel';
      case 'restaurant': return 'Restaurant';
      case 'event': return 'Event';
      default: return 'Attraction';
    }
  }

  // ─── Full‑Width Card (like home screen) ──────────────────────────────────

  Widget _buildFullWidthCard({
    required String name,
    required String image,
    required double rating,
    required String location,
    required String type,
    required String favoriteId,
    required String itemId,
    required Map<String, dynamic> data,
  }) {
    return GestureDetector(
      onTap: () => _navigateToDetail(type, itemId, data),
      child: Container(
        decoration: BoxDecoration(
          color: _AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _AppColors.lightGrey.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image (left) ──
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
                        child: const Icon(Icons.broken_image, color: _AppColors.grey),
                      ),
                    )
                  : Container(
                      width: 120,
                      height: 130,
                      color: _AppColors.lightGrey,
                      child: const Icon(Icons.place_rounded, color: _AppColors.grey),
                    ),
            ),
            // ── Info (right) ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _AppColors.dark,
                            ),
                          ),
                        ),
                        // Remove button (small heart)
                        GestureDetector(
                          onTap: () => _showRemoveDialog(name, favoriteId),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: _AppColors.error,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  Widget _buildUnavailableCard(QueryDocumentSnapshot favorite) {
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
            child: Text(
              "Item not available",
              style: GoogleFonts.poppins(
                color: _AppColors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: _AppColors.error),
            onPressed: () => _showRemoveDialog('this item', favorite.id),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      height: 130,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AppColors.lightGrey.withOpacity(0.5)),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _AppColors.primary,
        ),
      ),
    );
  }
}