// lib/screens/home/favorites_screen.dart
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "My Favorites",
          style: TextStyle(
            color: AppColors.dark,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.dark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete_sweep_rounded,
              color: AppColors.error,
            ),
            onPressed: () {
              // Clear all favorites
              _showClearAllDialog();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: favoriteService.getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Loading your favorites...",
                    style: TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 60,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading favorites',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: AppColors.white,
                      size: 18,
                    ),
                    label: const Text("Retry"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
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
                      color: AppColors.lightGrey.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border_rounded,
                      size: 80,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "No Favorites Found",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Start exploring and save your favorite places!",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.explore_rounded,
                      color: AppColors.white,
                      size: 18,
                    ),
                    label: const Text("Explore Now"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final favorites = snapshot.data!.docs;
          return Column(
            children: [
              // Results count
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${favorites.length} favorite${favorites.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.darkGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    var favorite = favorites[index];

                    return FutureBuilder<DocumentSnapshot>(
                      future: favoriteService.getAttraction(
                        favorite['attractionId'],
                      ),
                      builder: (context, attractionSnapshot) {
                        if (attractionSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.lightGrey,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGrey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 16,
                                        color: AppColors.lightGrey,
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: 80,
                                        height: 14,
                                        color: AppColors.lightGrey,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (attractionSnapshot.hasError ||
                            !attractionSnapshot.hasData ||
                            !attractionSnapshot.data!.exists) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppColors.error,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Attraction not available",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.dark,
                                        ),
                                      ),
                                      Text(
                                        "Tap to remove from favorites",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_rounded,
                                    color: AppColors.error,
                                    size: 24,
                                  ),
                                  onPressed: () async {
                                    await favoriteService.removeFavorite(
                                        favorite.id);
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            "Removed from favorites"),
                                        backgroundColor: AppColors.success,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }

                        var attraction = attractionSnapshot.data!.data()
                            as Map<String, dynamic>;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.lightGrey,
                              width: 1,
                            ),
                            boxShadow: AppColors.subtleShadow,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 60,
                                height: 60,
                                color: AppColors.lightGrey,
                                child: attraction['image'] != null &&
                                        attraction['image'].isNotEmpty
                                    ? Image.network(
                                        attraction['image'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.broken_image,
                                          color: AppColors.grey,
                                          size: 30,
                                        ),
                                        loadingBuilder: (_, child, progress) {
                                          if (progress == null) return child;
                                          return const Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Icon(
                                        Icons.place_rounded,
                                        color: AppColors.grey,
                                        size: 30,
                                      ),
                              ),
                            ),
                            title: Text(
                              attraction['name'] ?? 'Unknown Attraction',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.dark,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: AppColors.secondary,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  attraction['rating']?.toString() ?? '0.0',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.dark,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    attraction['cityId'] ?? 'City',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.favorite_rounded,
                                color: AppColors.error,
                                size: 28,
                              ),
                              onPressed: () async {
                                bool? confirm = await showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    backgroundColor: AppColors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: Row(
                                      children: [
                                        Icon(
                                          Icons.favorite_rounded,
                                          color: AppColors.error,
                                          size: 28,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "Remove Favorite",
                                          style: TextStyle(
                                            color: AppColors.dark,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Text(
                                      "Remove ${attraction['name'] ?? 'this'} from your favorites?",
                                      style: TextStyle(
                                        color: AppColors.darkGrey,
                                        fontSize: 15,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                            color: AppColors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.error,
                                          foregroundColor: AppColors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: const Text("Remove"),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await favoriteService.removeFavorite(
                                      favorite.id);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Removed ${attraction['name'] ?? 'attraction'} from favorites"),
                                      backgroundColor: AppColors.success,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            onTap: () {
                              // Navigate to attraction detail
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (_) => AttractionDetailScreen(
                              //       attraction: attraction,
                              //     ),
                              //   ),
                              // );
                            },
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

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: AppColors.error,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              "Clear All Favorites",
              style: TextStyle(
                color: AppColors.dark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to remove all items from your favorites?",
          style: TextStyle(
            color: AppColors.darkGrey,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: AppColors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Clear all favorites logic
              await favoriteService.clearAllFavorites();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("All favorites cleared"),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Clear All"),
          ),
        ],
      ),
    );
  }
}