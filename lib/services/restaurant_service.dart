// lib/services/restaurant_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/restaurant_model.dart';

class RestaurantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = "restaurants";

  // ✅ Get All Restaurants - KEEP THIS ONE (with debug prints)
  Future<List<RestaurantModel>> getAllRestaurants() async {
    try {
      print('🟢 Fetching all restaurants from Firestore...');
      
      QuerySnapshot snapshot = await _firestore
          .collection(collection)
          .get();
      
      print('🟢 Found ${snapshot.docs.length} restaurants in Firestore');
      
      if (snapshot.docs.isEmpty) {
        print('⚠️ No restaurants found in Firestore collection');
        return [];
      }
      
      // Log first restaurant data for debugging
      if (snapshot.docs.isNotEmpty) {
        print('🔍 First restaurant data: ${snapshot.docs.first.data()}');
      }
      
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

  // ✅ Get Restaurants By City - KEEP THIS ONE (with debug prints)
  Stream<List<RestaurantModel>> getRestaurantsByCity(String cityId) {
    print('🟢 Fetching restaurants for city: $cityId');
    
    return _firestore
        .collection(collection)
        .where('cityId', isEqualTo: cityId)
        .snapshots()
        .map((snapshot) {
          print('🟢 Found ${snapshot.docs.length} restaurants for city: $cityId');
          
          if (snapshot.docs.isEmpty) {
            print('⚠️ No restaurants found for city: $cityId');
          }
          
          return snapshot.docs.map((doc) {
            return RestaurantModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // ✅ Get All Restaurants as Stream
  Stream<List<RestaurantModel>> getRestaurants() {
    return _firestore
        .collection(collection)
        .snapshots()
        .map((snapshot) {
          print('🟢 Stream: Found ${snapshot.docs.length} restaurants');
          return snapshot.docs.map((doc) {
            return RestaurantModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // ✅ Add Restaurant
  Future<void> addRestaurant(RestaurantModel restaurant) async {
    try {
      await _firestore.collection(collection).add(restaurant.toMap());
      print('✅ Restaurant added successfully');
    } catch (e) {
      print('❌ Error adding restaurant: $e');
      rethrow;
    }
  }

  // ✅ Update Restaurant
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

  // ✅ Delete Restaurant
  Future<void> deleteRestaurant(String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
      print('✅ Restaurant deleted successfully');
    } catch (e) {
      print('❌ Error deleting restaurant: $e');
      rethrow;
    }
  }

  // ✅ Get Single Restaurant
  Future<RestaurantModel?> getRestaurant(String id) async {
    try {
      final doc = await _firestore.collection(collection).doc(id).get();

      if (!doc.exists) {
        print('⚠️ Restaurant not found: $id');
        return null;
      }

      return RestaurantModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      print('❌ Error fetching restaurant: $e');
      return null;
    }
  }
}