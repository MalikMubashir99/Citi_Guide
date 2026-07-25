import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/restaurant_model.dart';

class RestaurantService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final String collection = "restaurants";

  // Add Restaurant
  Future<void> addRestaurant(
      RestaurantModel restaurant) async {
    await _firestore
        .collection(collection)
        .add(restaurant.toMap());
  }

  // Update Restaurant
  Future<void> updateRestaurant(
      RestaurantModel restaurant) async {
    await _firestore
        .collection(collection)
        .doc(restaurant.id)
        .update(restaurant.toMap());
  }

  // Delete Restaurant
  Future<void> deleteRestaurant(
      String id) async {
    await _firestore
        .collection(collection)
        .doc(id)
        .delete();
  }

  // Get All Restaurants
  Stream<List<RestaurantModel>>
      getRestaurants() {
    return _firestore
        .collection(collection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return RestaurantModel.fromFirestore(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }

  // Get Restaurants By City
  Stream<List<RestaurantModel>>
      getRestaurantsByCity(String cityId) {
    return _firestore
        .collection(collection)
        .where(
          'cityId',
          isEqualTo: cityId,
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return RestaurantModel.fromFirestore(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }

  // Get Single Restaurant
  Future<RestaurantModel?> getRestaurant(
      String id) async {
    final doc = await _firestore
        .collection(collection)
        .doc(id)
        .get();

    if (!doc.exists) return null;

    return RestaurantModel.fromFirestore(
      doc.data()!,
      doc.id,
    );
  }
}