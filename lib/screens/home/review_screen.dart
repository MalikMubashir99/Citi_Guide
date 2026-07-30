// lib/screens/home/review_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: const Color(0xFFFFFFFF),
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> submitReview() async {
    if (commentController.text.trim().isEmpty) {
      _showSnackBar("Please write a review", const Color(0xFFBC4749));
      return;
    }

    setState(() => isLoading = true);

    try {
      final alreadyReviewed = await reviewService.hasUserReviewed(widget.attraction.id);
      
      if (alreadyReviewed) {
        if (!mounted) return;
        _showSnackBar("⚠️ You have already reviewed this attraction", const Color(0xFFE09F3E));
        setState(() => isLoading = false);
        return;
      }

      await reviewService.addReview(
        attractionId: widget.attraction.id,
        userName: userName,
        rating: rating,
        comment: commentController.text.trim(),
      );

      if (!mounted) return;
      commentController.clear();
      setState(() => rating = 5);

      _showSnackBar("✅ Review Added Successfully!", const Color(0xFF6A994E));
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Error: $e", const Color(0xFFBC4749));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Warm Linen
      appBar: AppBar(
        title: Text(
          "Reviews",
          style: GoogleFonts.poppins(
            color: const Color(0xFF2C221E),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: const Color(0xFFFDFBF7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2C221E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Attraction Name Card (Flat)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF), // Pure white
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE6E1DC).withValues(alpha: 0.7), width: 1),
                // Removed shadow for flat design
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rate & Review",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF8C827E),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.attraction.name,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C221E),
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
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE6E1DC).withValues(alpha: 0.7), width: 1),
              ),
              child: Column(
                children: [
                  Text(
                    "How would you rate this attraction?",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C221E),
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
                      return const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFD4A373), // Warm Sand
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
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF5C524E),
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
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE6E1DC).withValues(alpha: 0.7), width: 1),
              ),
              child: TextField(
                controller: commentController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Write your review",
                  labelStyle: GoogleFonts.poppins(
                    color: const Color(0xFF5C524E),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  hintText: "Share your experience...",
                  hintStyle: GoogleFonts.poppins(
                    color: const Color(0xFF8C827E),
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFA0522D),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  filled: true,
                  fillColor: const Color(0xFFFFFFFF),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Submit Button (Flat)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA0522D),
                  foregroundColor: const Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0, // Flat design
                ),
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Submitting...",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFFFFFF),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, color: Color(0xFFFFFFFF), size: 20),
                          const SizedBox(width: 10),
                          Text(
                            "Submit Review",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFFFFFF),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // User Reviews Section Header
            Row(
              children: [
                Container(
                  width: 4,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA0522D),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "User Reviews",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C221E),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
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
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFA0522D)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline_rounded, size: 40, color: Color(0xFFBC4749)),
                const SizedBox(height: 8),
                Text(
                  'Error loading reviews',
                  style: GoogleFonts.poppins(color: const Color(0xFFBC4749), fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE6E1DC).withValues(alpha: 0.7), width: 1),
            ),
            child: Column(
              children: [
                const Icon(Icons.chat_bubble_outline_rounded, size: 60, color: Color(0xFF8C827E)),
                const SizedBox(height: 12),
                Text(
                  "No Reviews Yet",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C221E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Be the first to review this attraction!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF8C827E),
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
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE6E1DC).withValues(alpha: 0.7), width: 1),
                // Removed shadow for flat design
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFFA0522D).withValues(alpha: 0.1),
                        child: Text(
                          review.userName.isNotEmpty
                              ? review.userName[0].toUpperCase()
                              : 'U',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: const Color(0xFFA0522D),
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
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2C221E),
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
                                    color: const Color(0xFFD4A373), // Warm Sand
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  review.rating.toStringAsFixed(1),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2C221E),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _getTimeAgo(review.createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF8C827E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    review.comment,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF5C524E),
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

  String _getTimeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    
    DateTime dateTime;
    
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
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