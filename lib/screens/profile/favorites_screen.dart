import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/favorite_service.dart';

class FavoritesScreen extends StatelessWidget {
  FavoritesScreen({super.key});

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

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Favorites Found"));
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
                      child: ListTile(title: Text("Loading...")),
                    );
                  }

                  if (!attractionSnapshot.hasData ||
                      !attractionSnapshot.data!.exists) {
                    return const SizedBox();
                  }

                  var attraction =
                      attractionSnapshot.data!.data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.all(10),

                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(attraction['image']),
                      ),

                      title: Text(attraction['name']),

                      subtitle: Text("⭐ ${attraction['rating']}"),

                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          favoriteService.removeFavorite(favorite.id);
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
