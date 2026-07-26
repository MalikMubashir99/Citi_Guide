// lib/services/restaurant_service.dart
import 'package:app/model/restaurant_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = "restaurants";

  // ✅ Get all restaurants
  Future<List<RestaurantModel>> getAllRestaurants() async {
    try {
      print('🟢 Fetching all restaurants from Firestore...');
      
      final QuerySnapshot snapshot = await _firestore
          .collection(collection)
          .get();
      
      print('🟢 Found ${snapshot.docs.length} restaurants in Firestore');
      
      if (snapshot.docs.isEmpty) {
        print('⚠️ No restaurants found in Firestore collection');
        return [];
      }
      
      final List<RestaurantModel> restaurants = [];
      for (var doc in snapshot.docs) {
        try {
          final restaurant = RestaurantModel.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
          restaurants.add(restaurant);
        } catch (e) {
          print('❌ Error parsing restaurant document ${doc.id}: $e');
        }
      }
      
      print('✅ Successfully parsed ${restaurants.length} restaurants');
      return restaurants;
    } catch (e) {
      print('❌ Error fetching restaurants: $e');
      return [];
    }
  }

  // ✅ Get restaurants by city
  Stream<List<RestaurantModel>> getRestaurantsByCity(String cityId) {
    return _firestore
        .collection(collection)
        .where('cityId', isEqualTo: cityId)
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

  // ✅ Add restaurant
  Future<void> addRestaurant(RestaurantModel restaurant) async {
    try {
      await _firestore.collection(collection).add(restaurant.toMap());
      print('✅ Restaurant added successfully');
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
      print('✅ Restaurant updated successfully');
    } catch (e) {
      print('❌ Error updating restaurant: $e');
      rethrow;
    }
  }

  // ✅ Delete restaurant
  Future<void> deleteRestaurant(String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
      print('✅ Restaurant deleted successfully');
    } catch (e) {
      print('❌ Error deleting restaurant: $e');
      rethrow;
    }
  }
}