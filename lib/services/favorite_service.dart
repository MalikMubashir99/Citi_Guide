// lib/services/favorite_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Get attraction
  Future<DocumentSnapshot> getAttraction(String attractionId) {
    return _firestore.collection('attractions').doc(attractionId).get();
  }

  // ✅ Get hotel
  Future<DocumentSnapshot> getHotel(String hotelId) {
    return _firestore.collection('hotels').doc(hotelId).get();
  }

  // ✅ Check if favorite (works for both attraction and hotel)
  Future<bool> isFavorite(String itemId) async {
    try {
      var result = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .where('attractionId', isEqualTo: itemId)
          .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  // ✅ Check favorite (alternative)
  Future<QuerySnapshot> checkFavorite(String attractionId) {
    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .where('attractionId', isEqualTo: attractionId)
        .get();
  }

  // ✅ Add Favorite
  Future<void> addFavorite(String attractionId) async {
    await _firestore.collection('favorites').add({
      'userId': _auth.currentUser!.uid,
      'attractionId': attractionId,
      'createdAt': Timestamp.now(),
    });
  }

  // ✅ Remove Favorite by ID
  Future<void> removeFavorite(String favoriteId) async {
    await _firestore.collection('favorites').doc(favoriteId).delete();
  }

  // ✅ Remove Favorite by Attraction/Hotel ID
  Future<void> removeFavoriteByAttraction(String attractionId) async {
    var result = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .where('attractionId', isEqualTo: attractionId)
        .get();

    for (var doc in result.docs) {
      await doc.reference.delete();
    }
  }

  // ✅ Get User Favorites
  Stream<QuerySnapshot> getFavorites() {
    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .snapshots();
  }

  // ✅ Clear all favorites (from subcollection)
  Future<void> clearAllFavorites() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // ✅ If favorites are in subcollection
      final favorites = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      final batch = _firestore.batch();
      for (var doc in favorites.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error clearing favorites: $e');
    }
  }

  // ✅ Clear all favorites (from main collection)
  Future<void> clearAllFavoritesMain() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final favorites = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: user.uid)
          .get();

      final batch = _firestore.batch();
      for (var doc in favorites.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error clearing favorites: $e');
    }
  }

  Future<DocumentSnapshot> getRestaurant(String restaurantId) {
    return _firestore.collection('restaurants').doc(restaurantId).get();
  }
}
