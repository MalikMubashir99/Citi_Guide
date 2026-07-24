import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add Review
  Future<void> addReview({
    required String attractionId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    await _firestore.collection('reviews').add({
      'userId': _auth.currentUser!.uid,
      'attractionId': attractionId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.now(),
    });
  }

  /// Get Reviews of Attraction
  Stream<List<ReviewModel>> getReviews(String attractionId) {
    return _firestore
        .collection('reviews')
        .where('attractionId', isEqualTo: attractionId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReviewModel.fromFirestore(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }

  /// Delete Review
  Future<void> deleteReview(String reviewId) async {
    await _firestore
        .collection('reviews')
        .doc(reviewId)
        .delete();
  }

  /// Calculate Average Rating
  Future<double> getAverageRating(String attractionId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('attractionId', isEqualTo: attractionId)
        .get();

    if (snapshot.docs.isEmpty) {
      return 0;
    }

    double total = 0;

    for (var doc in snapshot.docs) {
      total += (doc['rating'] as num).toDouble();
    }

    return total / snapshot.docs.length;
  }

  Future<int> getReviewCount(String attractionId) async {
  var snapshot = await FirebaseFirestore.instance
      .collection('reviews')
      .where('attractionId', isEqualTo: attractionId)
      .get();

  return snapshot.docs.length;
}
}