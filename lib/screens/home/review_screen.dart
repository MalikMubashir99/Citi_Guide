import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app/model/attraction_model.dart';
import 'package:app/model/review_model.dart';
import 'package:app/services/review_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool isLoading = false;
  String userName = "User";

  @override
  void initState() {
    super.initState();
    _getUserName();
  }

  Future<void> _getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Try to get user name from Firestore
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data()?['name'] != null) {
          userName = doc.data()!['name'];
        } else {
          userName = user.displayName ?? user.email?.split('@').first ?? "User";
        }
      } catch (_) {
        userName = user.displayName ?? user.email?.split('@').first ?? "User";
      }
      setState(() {});
    }
  }

  Future<void> submitReview() async {
    if (commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write a review")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await reviewService.addReview(
        attractionId: widget.attraction.id,
        userName: userName,
        rating: rating,
        comment: commentController.text.trim(),
      );

      if (!mounted) return;

      commentController.clear();
      setState(() {
        rating = 5;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review Added")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
                setState(() {
                  rating = value;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Write your review",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : submitReview,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Submit Review"),
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

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                "No Reviews Yet\nBe the first to review!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          );
        }

        return Column(
          children: snapshot.data!.map((review) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: Text(
                    review.userName.isNotEmpty
                        ? review.userName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                title: Text(review.userName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              index < review.rating.floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          review.rating.toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Text(
                      review.comment,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}