import 'package:app/screens/home/review_screen.dart';
import 'package:app/services/favorite_service.dart';
import 'package:app/services/review_service.dart';
import 'package:flutter/material.dart';
import '../../model/attraction_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AttractionDetailScreen extends StatefulWidget {
  final AttractionModel attraction;

  const AttractionDetailScreen({super.key, required this.attraction});

  @override
  State<AttractionDetailScreen> createState() => _AttractionDetailScreenState();
}

class _AttractionDetailScreenState extends State<AttractionDetailScreen> {
  final FavoriteService favoriteService = FavoriteService();
  final ReviewService reviewService = ReviewService();

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadFavorite();
  }

  Future<void> openGoogleMaps() async {
    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${widget.attraction.latitude},${widget.attraction.longitude}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> loadFavorite() async {
    bool favorite = await favoriteService.isFavorite(widget.attraction.id);

    setState(() {
      isFavorite = favorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.attraction.name),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () async {
              if (isFavorite) {
                await favoriteService.removeFavoriteByAttraction(
                  widget.attraction.id,
                );
              } else {
                await favoriteService.addFavorite(widget.attraction.id);
              }

              await loadFavorite();
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.attraction.image,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.attraction.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  FutureBuilder<double>(
                    future: reviewService.getAverageRating(
                      widget.attraction.id,
                    ),
                    builder: (context, ratingSnapshot) {
                      return FutureBuilder<int>(
                        future: reviewService.getReviewCount(
                          widget.attraction.id,
                        ),
                        builder: (context, countSnapshot) {
                          if (!ratingSnapshot.hasData ||
                              !countSnapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          return Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),

                              const SizedBox(width: 5),

                              Text(
                                ratingSnapshot.data!.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 18),
                              ),

                              const SizedBox(width: 10),

                              Text("(${countSnapshot.data} Reviews)"),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.attraction.description,
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text("Opening Hours"),
                    subtitle: Text(widget.attraction.openingHours),
                  ),

                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text("Phone"),
                    subtitle: Text(widget.attraction.phone),
                  ),

                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text("Website"),
                    subtitle: Text(widget.attraction.website),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: openGoogleMaps,
                      icon: const Icon(Icons.map),
                      label: const Text("Open in Google Maps"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ReviewScreen(attraction: widget.attraction),
                          ),
                        );
                      },
                      icon: const Icon(Icons.rate_review),
                      label: const Text("Write Review"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
