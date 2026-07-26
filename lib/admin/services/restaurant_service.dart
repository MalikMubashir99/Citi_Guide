// lib/admin/services/restaurant_service.dart
import 'package:app/admin/models/restaurant_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = "restaurants";

  // ✅ Get all restaurants with real-time updates
  Stream<List<RestaurantModel>> getRestaurants() {
    return _firestore
        .collection(collection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return RestaurantModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // ✅ Get all restaurants (Future)
  Future<List<RestaurantModel>> getAllRestaurants() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(collection)
          .orderBy('name')
          .get();
      
      return snapshot.docs.map((doc) {
        return RestaurantModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      print('❌ Error fetching restaurants: $e');
      return [];
    }
  }

  // ✅ Get restaurant by ID
  Future<RestaurantModel?> getRestaurantById(String id) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(collection)
          .doc(id)
          .get();
      
      if (!doc.exists) return null;
      
      return RestaurantModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      print('❌ Error fetching restaurant: $e');
      return null;
    }
  }

  // ✅ Add restaurant
  Future<String> addRestaurant(RestaurantModel restaurant) async {
    try {
      final docRef = await _firestore
          .collection(collection)
          .add(restaurant.toMap());
      
      print('✅ Restaurant added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error adding restaurant: $e');
      rethrow;
    }
  }

  // ✅ Update restaurant
  Future<void> updateRestaurant(RestaurantModel restaurant) async {
    try {
      await _firestore
          .collection(collection)
          .doc(restaurant.id)
          .update(restaurant.toMap());
      
      print('✅ Restaurant updated: ${restaurant.id}');
    } catch (e) {
      print('❌ Error updating restaurant: $e');
      rethrow;
    }
  }

  // ✅ Delete restaurant
  Future<void> deleteRestaurant(String id) async {
    try {
      await _firestore
          .collection(collection)
          .doc(id)
          .delete();
      
      print('✅ Restaurant deleted: $id');
    } catch (e) {
      print('❌ Error deleting restaurant: $e');
      rethrow;
    }
  }

  // ✅ Get restaurants by city
  Future<List<RestaurantModel>> getRestaurantsByCity(String cityId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(collection)
          .where('cityId', isEqualTo: cityId)
          .orderBy('name')
          .get();
      
      return snapshot.docs.map((doc) {
        return RestaurantModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      print('❌ Error fetching restaurants by city: $e');
      return [];
    }
  }

  // ✅ Search restaurants
  Future<List<RestaurantModel>> searchRestaurants(String query) async {
    try {
      final allRestaurants = await getAllRestaurants();
      
      return allRestaurants.where((restaurant) {
        return restaurant.name.toLowerCase().contains(query.toLowerCase()) ||
            restaurant.description.toLowerCase().contains(query.toLowerCase()) ||
            restaurant.cityId.toLowerCase().contains(query.toLowerCase()) ||
            restaurant.phone.contains(query);
      }).toList();
    } catch (e) {
      print('❌ Error searching restaurants: $e');
      return [];
    }
  }

  // ✅ Get restaurants count
  Future<int> getRestaurantsCount() async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .count()
          .get();
      
      return snapshot.count ?? 0;
    } catch (e) {
      print('❌ Error getting restaurants count: $e');
      return 0;
    }
  }

  // ✅ Get restaurant statistics
  Future<Map<String, dynamic>> getRestaurantStats() async {
    try {
      final allRestaurants = await getAllRestaurants();
      
      if (allRestaurants.isEmpty) {
        return {
          'total': 0,
          'averageRating': 0.0,
          'cities': [],
        };
      }
      
      final total = allRestaurants.length;
      final avgRating = allRestaurants.map((r) => r.rating).reduce((a, b) => a + b) / total;
      final cities = allRestaurants.map((r) => r.cityId).toSet().toList();
      
      return {
        'total': total,
        'averageRating': avgRating,
        'cities': cities,
      };
    } catch (e) {
      print('❌ Error getting restaurant stats: $e');
      return {
        'total': 0,
        'averageRating': 0.0,
        'cities': [],
      };
    }
  }

  // ✅ Validate restaurant
  static String? validateRestaurant(RestaurantModel restaurant) {
    if (restaurant.name.trim().isEmpty) {
      return 'Restaurant name is required';
    }
    if (restaurant.cityId.trim().isEmpty) {
      return 'City ID is required';
    }
    if (restaurant.description.trim().isEmpty) {
      return 'Description is required';
    }
    if (restaurant.image.trim().isEmpty) {
      return 'Image URL is required';
    }
    if (restaurant.rating < 0 || restaurant.rating > 5) {
      return 'Rating must be between 0 and 5';
    }
    return null;
  }
}