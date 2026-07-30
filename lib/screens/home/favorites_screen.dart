import 'package:app/core/constants/app_colors.dart';
import 'package:app/services/favorite_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoriteService favoriteService = FavoriteService();

  Future<Map<String, dynamic>?> _getItemDetails(String itemId) async {
    // Try attraction
    try {
      var doc = await favoriteService.getAttraction(itemId);
      if (doc.exists) {
        return {'type': 'attraction', 'data': doc.data() as Map<String, dynamic>};
      }
    } catch (e) {
      debugPrint('Attraction error: $e');
    }

    // Try hotel
    try {
      var doc = await favoriteService.getHotel(itemId);
      if (doc.exists) {
        return {'type': 'hotel', 'data': doc.data() as Map<String, dynamic>};
      }
    } catch (e) {
      debugPrint('Hotel error: $e');
    }

    // Try restaurant
    try {
      var doc = await favoriteService.getRestaurant(itemId);
      if (doc.exists) {
        return {'type': 'restaurant', 'data': doc.data() as Map<String, dynamic>};
      }
    } catch (e) {
      debugPrint('Restaurant error: $e');
    }

    return null;
  }

  // ✅ Themed icons based on type
  IconData _getIconForType(String type) {
    switch (type) {
      case 'hotel': return Icons.hotel_rounded;
      case 'restaurant': return Icons.restaurant_rounded;
      case 'event': return Icons.event_rounded;
      default: return Icons.place_rounded;
    }
  }

  // ✅ Earthy theme colors based on type
  Color _getColorForType(String type) {
    switch (type) {
      case 'hotel': return AppColors.info;       // Dusty Blue
      case 'restaurant': return AppColors.accent; // Terracotta
      case 'event': return AppColors.success;    // Sage Green
      default: return AppColors.primary;         // Rich Cognac
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Warm Linen
      appBar: AppBar(
        title: Text(
          "My Favorites",
          style: GoogleFonts.poppins(
            color: AppColors.dark,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: favoriteService.getFavorites(),
        builder: (context, snapshot) {
          // Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // Error State
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
                        color: AppColors.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error_outline_rounded, size: 60, color: AppColors.error),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading favorites',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.error),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
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

          // Empty State
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border_rounded, size: 80, color: AppColors.grey),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "No Favorites Found",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Start exploring and save your favorite places!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // List State
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var favorite = snapshot.data!.docs[index];
              final itemId = favorite['attractionId'];

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getItemDetails(itemId),
                builder: (context, itemSnapshot) {
                  // Item Loading State
                  if (itemSnapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5), width: 1),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 56, height: 56,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          ),
                          SizedBox(width: 16),
                          Text("Loading...", style: TextStyle(color: AppColors.grey)),
                        ],
                      ),
                    );
                  }

                  // Unavailable/Deleted Item State
                  if (itemSnapshot.hasError || !itemSnapshot.hasData || itemSnapshot.data == null) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5), width: 1),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.lightGrey.withValues(alpha: 0.5),
                          child: Icon(Icons.delete_outline_rounded, color: AppColors.grey),
                        ),
                        title: Text(
                          "Item not available",
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.darkGrey),
                        ),
                        subtitle: Text("Tap to remove", style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                          onPressed: () async {
                            await favoriteService.removeFavorite(favorite.id);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Removed from favorites", style: GoogleFonts.poppins(color: AppColors.white)),
                                backgroundColor: AppColors.dark,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }

                  // Valid Item State
                  final item = itemSnapshot.data!;
                  final data = item['data'];
                  final type = item['type'];
                  final name = data['name'] ?? data['title'] ?? 'Unknown';
                  final image = data['image'] ?? '';
                  final rating = (data['rating'] ?? 0).toDouble();
                  final typeColor = _getColorForType(type);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface, // Pure white
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.7), width: 1),
                    ),
                    child: Row(
                      children: [
                        // Image/Avatar
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.lightGrey,
                          backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
                          onBackgroundImageError: (_, __) {},
                          child: image.isEmpty
                              ? Icon(_getIconForType(type), color: typeColor, size: 24)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: AppColors.secondary, size: 16), // Warm Sand star
                                  const SizedBox(width: 3),
                                  Text(
                                    rating > 0 ? rating.toStringAsFixed(1) : 'N/A',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: AppColors.darkGrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: typeColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      type.toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: typeColor,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Remove button
                        IconButton(
                          icon: const Icon(Icons.favorite_rounded, color: AppColors.error, size: 28), // Burnt Sienna
                          onPressed: () async {
                            bool? confirm = await showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: AppColors.surface,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: Text("Remove Favorite", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.dark)),
                                content: Text("Remove $name from favorites?", style: GoogleFonts.poppins(color: AppColors.darkGrey)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text("Cancel", style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w600)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error, // Flat Burnt Sienna
                                      foregroundColor: AppColors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: Text("Remove", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await favoriteService.removeFavorite(favorite.id);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("$name removed", style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w500)),
                                  backgroundColor: AppColors.dark,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}