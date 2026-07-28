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

  // ✅ Get restaurant
  Future<DocumentSnapshot> getRestaurant(String restaurantId) {
    return _firestore.collection('restaurants').doc(restaurantId).get();
  }

 Future<DocumentSnapshot> getEvent(String eventId) {
  print('📂 Getting event: $eventId');
  return _firestore.collection('events').doc(eventId).get();
}
  // ✅ Check if favorite
  Future<bool> isFavorite(String itemId) async {
    try {
      print('🔍 Checking favorite for: $itemId');
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return false;
      }

      var result = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: user.uid)
          .where('attractionId', isEqualTo: itemId)
          .get();

      print('📊 Found ${result.docs.length} favorites');
      return result.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error checking favorite: $e');
      return false;
    }
  }

  // ✅ Add Favorite
  Future<void> addFavorite(String attractionId) async {
    try {
      print('❤️ Adding favorite: $attractionId');
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return;
      }

      await _firestore.collection('favorites').add({
        'userId': user.uid,
        'attractionId': attractionId,
        'createdAt': Timestamp.now(),
      });
      print('✅ Favorite added successfully');
    } catch (e) {
      print('❌ Error adding favorite: $e');
      rethrow;
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

  // ✅ Remove Favorite by ID
  Future<void> removeFavorite(String favoriteId) async {
    await _firestore.collection('favorites').doc(favoriteId).delete();
  }

  // ✅ Remove Favorite by Attraction/Hotel/Restaurant/Event ID
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

  // ✅ Get all favorite item details with type detection
  Future<List<Map<String, dynamic>>> getAllFavoriteItems() async {
    try {
      final favorites = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .get();

      List<Map<String, dynamic>> items = [];

      for (var doc in favorites.docs) {
        final itemId = doc['attractionId'];
        if (itemId == null) continue;

        // Try attraction
        try {
          final attraction = await getAttraction(itemId);
          if (attraction.exists) {
            items.add({
              'id': itemId,
              'type': 'attraction',
              'data': attraction.data() as Map<String, dynamic>,
              'favoriteId': doc.id,
            });
            continue;
          }
        } catch (_) {}

        // Try hotel
        try {
          final hotel = await getHotel(itemId);
          if (hotel.exists) {
            items.add({
              'id': itemId,
              'type': 'hotel',
              'data': hotel.data() as Map<String, dynamic>,
              'favoriteId': doc.id,
            });
            continue;
          }
        } catch (_) {}

        // Try restaurant
        try {
          final restaurant = await getRestaurant(itemId);
          if (restaurant.exists) {
            items.add({
              'id': itemId,
              'type': 'restaurant',
              'data': restaurant.data() as Map<String, dynamic>,
              'favoriteId': doc.id,
            });
            continue;
          }
        } catch (_) {}

        // Try event
        try {
          final event = await getEvent(itemId);
          if (event.exists) {
            items.add({
              'id': itemId,
              'type': 'event',
              'data': event.data() as Map<String, dynamic>,
              'favoriteId': doc.id,
            });
            continue;
          }
        } catch (_) {}
      }

      return items;
    } catch (e) {
      print('Error getting all favorites: $e');
      return [];
    }
  }

  // ✅ Clear all favorites (from subcollection)
  Future<void> clearAllFavorites() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

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
}
