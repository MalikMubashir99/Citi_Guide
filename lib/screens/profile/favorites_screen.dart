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
      appBar: AppBar(title: const Text("My Favorites")),
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
                    onPressed: () {},
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
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var favorite = snapshot.data!.docs[index];

              return FutureBuilder<DocumentSnapshot>(
                future: favoriteService.getAttraction(favorite['attractionId']),
                builder: (context, attractionSnapshot) {
                  if (attractionSnapshot.connectionState ==
                      ConnectionState.waiting) {
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

                  if (attractionSnapshot.hasError) {
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: const ListTile(
                        leading: Icon(Icons.error),
                        title: Text("Error loading attraction"),
                      ),
                    );
                  }

                  if (!attractionSnapshot.hasData ||
                      !attractionSnapshot.data!.exists) {
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: const ListTile(
                        leading: Icon(Icons.delete_outline),
                        title: Text("Attraction no longer available"),
                        subtitle: Text("Swipe to remove"),
                      ),
                    );
                  }

                  var attraction =
                      attractionSnapshot.data!.data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          attraction['image'] ?? '',
                        ),
                        onBackgroundImageError: (_, _) => const Icon(
                          Icons.broken_image,
                        ),
                        child: attraction['image'] == null ||
                                attraction['image'].isEmpty
                            ? const Icon(Icons.place)
                            : null,
                      ),
                      title: Text(attraction['name'] ?? 'Unknown'),
                      subtitle: Text("⭐ ${attraction['rating'] ?? 0}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () async {
                          // ✅ Show confirmation dialog
                          bool? confirm = await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Remove Favorite"),
                              content: Text(
                                "Remove ${attraction['name'] ?? 'this'} from favorites?",
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
}