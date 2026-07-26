// lib/screens/home/review_screen.dart
import 'package:app/core/constants/app_colors.dart';
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

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> _getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
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
      if (mounted) setState(() {});
    }
  }

  Future<void> submitReview() async {
    if (commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please write a review"),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("✅ Review Added Successfully!"),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Reviews",
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Attraction Name Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.lightGrey,
                  width: 1,
                ),
                boxShadow: AppColors.subtleShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rate & Review",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.attraction.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Rating Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.lightGrey,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "How would you rate this attraction?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RatingBar.builder(
                    initialRating: 5,
                    minRating: 1,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 40,
                    itemBuilder: (context, index) {
                      return Icon(
                        Icons.star_rounded,
                        color: AppColors.secondary,
                      );
                    },
                    onRatingUpdate: (value) {
                      setState(() {
                        rating = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getRatingLabel(rating),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Comment Field
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.lightGrey,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: commentController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Write your review",
                  labelStyle: TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  hintText: "Share your experience...",
                  hintStyle: TextStyle(
                    color: AppColors.grey,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  filled: true,
                  fillColor: AppColors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                ),
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Submitting...",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.send_rounded,
                            color: AppColors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Submit Review",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // User Reviews Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "User Reviews",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            buildReviews(),
          ],
        ),
      ),
    );
  }

  String _getRatingLabel(double rating) {
    if (rating >= 4.8) return "🌟 Excellent!";
    if (rating >= 4.0) return "😊 Very Good";
    if (rating >= 3.0) return "👍 Good";
    if (rating >= 2.0) return "👎 Fair";
    return "😞 Poor";
  }

  Widget buildReviews() {
    return StreamBuilder<List<ReviewModel>>(
      stream: reviewService.getReviews(widget.attraction.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: AppColors.error,
                ),
                const SizedBox(height: 8),
                Text(
                  'Error loading reviews',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.lightGrey,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 60,
                  color: AppColors.grey,
                ),
                const SizedBox(height: 12),
                Text(
                  "No Reviews Yet",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Be the first to review this attraction!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: snapshot.data!.map((review) {
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
                boxShadow: AppColors.subtleShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          review.userName.isNotEmpty
                              ? review.userName[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.userName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.dark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                ...List.generate(
                                  5,
                                  (index) => Icon(
                                    index < review.rating.floor()
                                        ? Icons.star_rounded
                                        : index < review.rating
                                            ? Icons.star_half_rounded
                                            : Icons.star_outline_rounded,
                                    color: AppColors.secondary,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  review.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.dark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _getTimeAgo(review.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    review.comment,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ✅ Fixed: Now handles both Timestamp and DateTime
  String _getTimeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    
    DateTime dateTime;
    
    // Handle Timestamp
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } 
    // Handle DateTime
    else if (timestamp is DateTime) {
      dateTime = timestamp;
    }
    // Handle Map or other types
    else {
      return 'Recently';
    }
    
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    
    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()}y ago';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}mo ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}