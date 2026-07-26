// lib/admin/services/city_service.dart
import 'package:app/admin/models/city_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = "cities";

  // ✅ Get all cities as Stream
  Stream<List<CityModel>> getCities() {
    return _firestore
        .collection(collection)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return CityModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // ✅ Get all cities as Future
  Future<List<CityModel>> getAllCities() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(collection)
          .get();
      
      return snapshot.docs.map((doc) {
        return CityModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      print('❌ Error fetching cities: $e');
      return [];
    }
  }

  // ✅ Get city by ID
  Future<CityModel?> getCityById(String id) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(collection)
          .doc(id)
          .get();
      
      if (!doc.exists) return null;
      
      return CityModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      print('❌ Error fetching city: $e');
      return null;
    }
  }

  // ✅ Add city
  Future<String> addCity(CityModel city) async {
    try {
      final docRef = await _firestore
          .collection(collection)
          .add(city.toMap());
      
      print('✅ City added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error adding city: $e');
      rethrow;
    }
  }

  // ✅ Update city
  Future<void> updateCity(CityModel city) async {
    try {
      await _firestore
          .collection(collection)
          .doc(city.id)
          .update(city.toMap());
      
      print('✅ City updated: ${city.id}');
    } catch (e) {
      print('❌ Error updating city: $e');
      rethrow;
    }
  }

  // ✅ Delete city
  Future<void> deleteCity(String id) async {
    try {
      await _firestore
          .collection(collection)
          .doc(id)
          .delete();
      
      print('✅ City deleted: $id');
    } catch (e) {
      print('❌ Error deleting city: $e');
      rethrow;
    }
  }

  // ✅ Search cities
  Future<List<CityModel>> searchCities(String query) async {
    try {
      final allCities = await getAllCities();
      
      return allCities.where((city) {
        return city.name.toLowerCase().contains(query.toLowerCase()) ||
            city.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      print('❌ Error searching cities: $e');
      return [];
    }
  }

  // ✅ Get cities count
  Future<int> getCitiesCount() async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .count()
          .get();
      
      return snapshot.count ?? 0;
    } catch (e) {
      print('❌ Error getting cities count: $e');
      return 0;
    }
  }

  // ✅ Validate city
  static String? validateCity(CityModel city) {
    if (city.name.trim().isEmpty) {
      return 'City name is required';
    }
    if (city.image.trim().isEmpty) {
      return 'City image is required';
    }
    if (city.description.trim().isEmpty) {
      return 'City description is required';
    }
    return null;
  }
}