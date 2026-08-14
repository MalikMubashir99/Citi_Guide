// lib/services/stats_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;

  Future<Map<String, int>> getUserStats() async {
    if (userId == null) {
      print('❌ No user logged in');
      return {'reviews': 0, 'favorites': 0, 'cities': 0};
    }

    try {
      print('📊 Fetching stats for user: $userId');

      // 1. Reviews count
      final reviewsQuery = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .get();
      final reviewCount = reviewsQuery.docs.length;
      print('✅ Reviews found: $reviewCount');

      // 2. Favorites – try multiple structures

      // Try Option A: subcollection
      final favSub = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();
      int favoriteCount = favSub.docs.length;
      print('🔍 Favorites (subcollection): $favoriteCount');

      // If subcollection is empty, try Option B: top‑level collection with userId field
      if (favoriteCount == 0) {
        final favTop = await _firestore
            .collection('favorites')
            .where('userId', isEqualTo: userId)
            .get();
        favoriteCount = favTop.docs.length;
        print('🔍 Favorites (top‑level with userId): $favoriteCount');
      }

      // If still 0, try Option C: array in user document
      if (favoriteCount == 0) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final data = userDoc.data();
        if (data != null && data.containsKey('favorites')) {
          final favs = data['favorites'];
          if (favs is List) {
            favoriteCount = favs.length;
            print('🔍 Favorites (array in user doc): $favoriteCount');
          }
        }
      }

      // 3. Cities count – total number of cities in the app (or user’s visited cities)
      // Option A: total cities in app
      final citiesSnapshot = await _firestore.collection('cities').get();
      int cityCount = citiesSnapshot.docs.length;
      print('✅ Cities (total): $cityCount');

      // Option B: if you store visited cities in user document as array
      // final userDoc = await _firestore.collection('users').doc(userId).get();
      // final visited = userDoc.data()?['visitedCities'] as List?;
      // cityCount = visited?.length ?? 0;

      return {
        'reviews': reviewCount,
        'favorites': favoriteCount,
        'cities': cityCount,
      };
    } catch (e) {
      print('❌ Error fetching stats: $e');
      return {'reviews': 0, 'favorites': 0, 'cities': 0};
    }
  }
}