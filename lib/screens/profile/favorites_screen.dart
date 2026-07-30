// lib/screens/profile/favorites_screen.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/favorite_service.dart';

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

  IconData _getIconForType(String type) {
    switch (type) {
      case 'hotel':
        return Icons.hotel_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'hotel':
        return AppColors.secondaryDark; // Deep Gold
      case 'restaurant':
        return AppColors.accent; // Terracotta
      default:
        return AppColors.primary; // Cognac
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'hotel':
        return 'Hotel';
      case 'restaurant':
        return 'Restaurant';
      default:
        return 'Attraction';
    }
  }

  void _showRemoveDialog(String name, String favoriteId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  color: AppColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Remove Favorite",
                style: TextStyle(
                  color: AppColors.dark,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Remove \"$name\" from your favorites?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.darkGrey,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkGrey,
                        side: const BorderSide(color: AppColors.lightGrey),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Remove"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
        content: Row(
          children: [
            const Icon(Icons.heart_broken, color: AppColors.white, size: 18),
            const SizedBox(width: 10),
            const Text("Removed from favorites"),
          ],
        ),
        backgroundColor: AppColors.darkGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Favorites",
          style: TextStyle(
            color: AppColors.dark,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.dark),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.lightGrey,
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
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Loading favorites...",
                    style: TextStyle(
                      color: AppColors.grey,
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
                        color: AppColors.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        size: 36,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Something went wrong",
                      style: TextStyle(
                        color: AppColors.dark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() {}),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text("Try Again"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
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
                        color: AppColors.secondaryLight.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 48,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "No Favorites Yet",
                      style: TextStyle(
                        color: AppColors.dark,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Start exploring and save your\nfavorite places to find them here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.darkGrey,
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

          // ── Favorites Grid ──
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  "${docs.length} saved ${docs.length == 1 ? 'place' : 'places'}",
                  style: const TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.74,
                  ),
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
                        final location = data['location'] ?? data['city'] ?? _getTypeLabel(type);
                        final price = data['price'] ?? '';

                        return _buildFavoriteCard(
                          name: name,
                          image: image,
                          rating: rating,
                          location: location,
                          price: price,
                          type: type,
                          favoriteId: favorite.id,
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

  // ── Vertical Grid Favorite Card ──
  Widget _buildFavoriteCard({
    required String name,
    required String image,
    required double rating,
    required String location,
    required String price,
    required String type,
    required String favoriteId,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.lightGrey.withValues(alpha: 0.6),
        ),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Heart Icon Overlay
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    color: AppColors.primarySurface,
                    image: image.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(image),
                            fit: BoxFit.cover,
                            onError: (_, __) {},
                          )
                        : null,
                  ),
                  child: image.isEmpty
                      ? Icon(
                          _getIconForType(type),
                          color: _getTypeColor(type).withValues(alpha: 0.6),
                          size: 32,
                        )
                      : null,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _showRemoveDialog(name, favoriteId),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: AppColors.error,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info Section
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.dark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.warning,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: AppColors.darkGrey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (price.isNotEmpty)
                      Text(
                        price,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Unavailable Item Card ──
  Widget _buildUnavailableCard(QueryDocumentSnapshot favorite) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.lightGrey.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.lightGrey.withValues(alpha: 0.3),
              ),
              child: const Icon(
                Icons.hide_source_rounded,
                color: AppColors.grey,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Not available",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.darkGrey,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                await favoriteService.removeFavorite(favorite.id);
                if (!mounted) return;
                _showRemovedSnackBar();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Remove",
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Loading Shimmer Card ──
  Widget _buildShimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.lightGrey.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                color: AppColors.lightGrey.withValues(alpha: 0.4),
              ),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 60,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}