// lib/screens/profile/my_reviews_screen.dart
import 'package:app/model/review_model.dart';
import 'package:app/services/review_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Local Blue Theme ──────────────────────────────────────────────────────────
class _AppColors {
  static const Color background = Color(0xFFF8FAFC);
  static const Color white = Colors.white;
  static const Color dark = Color(0xFF0F172A);
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color error = Color(0xFFDC2626);
  static const Color lightGrey = Color(0xFFE2E8F0);
  static const Color grey = Color(0xFF64748B);
  static const Color star = Color(0xFFF59E0B);
}

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  final ReviewService reviewService = ReviewService();
  late Future<List<ReviewModel>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _reviewsFuture = Future.value([]);
      return;
    }
    _reviewsFuture = reviewService.getReviewsByUser(user.uid);
  }

  Future<void> _deleteReview(String reviewId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Delete Review",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: _AppColors.dark,
          ),
        ),
        content: Text(
          "Are you sure you want to delete this review?",
          style: GoogleFonts.poppins(color: _AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(
                color: _AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _AppColors.error,
              foregroundColor: _AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Delete",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await reviewService.deleteReview(reviewId);
      if (!mounted) return;
      setState(() {
        _loadReviews();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Review deleted",
            style: GoogleFonts.poppins(
              color: _AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: _AppColors.dark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      appBar: AppBar(
        title: Text(
          "My Reviews",
          style: GoogleFonts.poppins(
            color: _AppColors.dark,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: _AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _AppColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<ReviewModel>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _AppColors.primary,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 60,
                    color: _AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Error loading reviews",
                    style: GoogleFonts.poppins(
                      color: _AppColors.error,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final reviews = snapshot.data ?? [];

          if (reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _AppColors.lightGrey.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.rate_review_rounded,
                      size: 80,
                      color: _AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "No Reviews Yet",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: _AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You haven't written any reviews yet.",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _AppColors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // ─── Display reviews ──────────────────────────────────────────────
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  "${reviews.length} ${reviews.length == 1 ? 'review' : 'reviews'}",
                  style: GoogleFonts.poppins(
                    color: _AppColors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return _buildReviewCard(review);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _AppColors.lightGrey.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Rating & Date ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ...List.generate(
                    5,
                    (i) => Icon(
                      i < review.rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: _AppColors.star,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    review.rating.toStringAsFixed(1),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _AppColors.dark,
                    ),
                  ),
                ],
              ),
              Text(
                _formatDate(review.createdAt),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: _AppColors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // ── Comment ──────────────────────────────────────────────────────
          Text(
            review.comment,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: _AppColors.dark.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          // ── Delete button ────────────────────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => _deleteReview(review.id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Delete",
                  style: GoogleFonts.poppins(
                    color: _AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}