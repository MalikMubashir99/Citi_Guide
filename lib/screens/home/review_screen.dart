import 'package:flutter/material.dart';
import 'package:app/model/attraction_model.dart';
import 'package:app/model/review_model.dart';
import 'package:app/services/review_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewScreen extends StatefulWidget {
  final AttractionModel attraction;

  const ReviewScreen({super.key, required this.attraction});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final ReviewService reviewService = ReviewService();

  final TextEditingController commentController = TextEditingController();

  double rating = 5;

  Future<void> submitReview() async {
    if (commentController.text.trim().isEmpty) {
      return;
    }

    await reviewService.addReview(
      attractionId: widget.attraction.id,
      userName: "User",
      rating: rating,
      comment: commentController.text.trim(),
    );

    commentController.clear();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Review Added")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reviews")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              widget.attraction.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const Text("Rate this attraction", style: TextStyle(fontSize: 18)),

            const SizedBox(height: 10),

            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              allowHalfRating: true,
              itemCount: 5,

              itemBuilder: (context, index) {
                return const Icon(Icons.star, color: Colors.amber);
              },

              onRatingUpdate: (value) {
                rating = value;
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: commentController,

              maxLines: 4,

              decoration: const InputDecoration(
                labelText: "Write your review",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: submitReview,

                child: const Text("Submit Review"),
              ),
            ),

            const SizedBox(height: 30),

            const Divider(),

            const SizedBox(height: 10),

            const Text(
              "User Reviews",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            buildReviews(),
          ],
        ),
      ),
    );
  }

  Widget buildReviews() {
    return StreamBuilder<List<ReviewModel>>(
      stream: reviewService.getReviews(widget.attraction.id),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No Reviews Yet");
        }

        return Column(
          children: snapshot.data!.map((review) {
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),

                title: Text(review.userName),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        Text(review.rating.toString()),
                      ],
                    ),
                    Text(review.comment),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
