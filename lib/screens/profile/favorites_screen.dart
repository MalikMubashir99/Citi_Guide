// lib/screens/profile/favorites_screen.dart
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

  // ✅ Get item details (attraction, hotel, or restaurant)
  Future<Map<String, dynamic>?> _getItemDetails(String itemId) async {
    // Try attraction first
    try {
      var doc = await favoriteService.getAttraction(itemId);
      if (doc.exists) {
        return {'type': 'attraction', 'data': doc.data() as Map<String, dynamic>};
      }
    } catch (_) {}

    // Try hotel
    try {
      var doc = await favoriteService.getHotel(itemId);
      if (doc.exists) {
        return {'type': 'hotel', 'data': doc.data() as Map<String, dynamic>};
      }
    } catch (_) {}

    // Try restaurant
    try {
      var doc = await favoriteService.getRestaurant(itemId);
      if (doc.exists) {
        return {'type': 'restaurant', 'data': doc.data() as Map<String, dynamic>};
      }
    } catch (_) {}

    return null;
  }

  // ✅ Get icon based on type
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorites"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: favoriteService.getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 10),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No Favorites Found",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Start exploring and save your favorite places!",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var favorite = snapshot.data!.docs[index];
              final itemId = favorite['attractionId'];

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getItemDetails(itemId),
                builder: (context, itemSnapshot) {
                  if (itemSnapshot.connectionState == ConnectionState.waiting) {
                    return const Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: CircularProgressIndicator(),
                        ),
                        title: Text("Loading..."),
                      ),
                    );
                  }

                  if (itemSnapshot.hasError || !itemSnapshot.hasData || itemSnapshot.data == null) {
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.delete_outline, color: Colors.grey),
                        ),
                        title: const Text("Item not available"),
                        subtitle: const Text("Tap to remove"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await favoriteService.removeFavorite(favorite.id);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Removed from favorites"),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }

                  final item = itemSnapshot.data!;
                  final data = item['data'];
                  final type = item['type'];
                  final name = data['name'] ?? data['title'] ?? 'Unknown';
                  final image = data['image'] ?? '';
                  final rating = data['rating'] ?? 0;

                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: image.isNotEmpty
                            ? NetworkImage(image)
                            : null,
                        backgroundColor: Colors.grey.shade200,
                        onBackgroundImageError: (_, __) => const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                        child: image.isEmpty
                            ? Icon(
                                _getIconForType(type),
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor(type).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              type.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getTypeColor(type),
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () async {
                          bool? confirm = await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Remove Favorite"),
                              content: Text(
                                "Remove $name from favorites?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Remove"),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await favoriteService.removeFavorite(favorite.id);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Removed from favorites"),
                              ),
                            );
                          }
                        },
                      ),
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

  Color _getTypeColor(String type) {
    switch (type) {
      case 'hotel':
        return Colors.purple;
      case 'restaurant':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}