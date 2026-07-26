// lib/services/hotel_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/hotel_model.dart';

class HotelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = "hotels";

  // ============================================================
  // ✅ PUBLIC METHODS (For Users)
  // ============================================================

  // ✅ Get all hotels (For Users)
  Future<List<HotelModel>> getAllHotels() async {
    try {
      print('🟢 Fetching all hotels from Firestore...');
      print('📁 Collection name: $collection');

      final QuerySnapshot snapshot = await _firestore
          .collection(collection)
          .get();

      print('🟢 Found ${snapshot.docs.length} hotels in Firestore');

      if (snapshot.docs.isEmpty) {
        print('⚠️ No hotels found in Firestore collection');
        return [];
      }

      final List<HotelModel> hotels = [];
      for (var doc in snapshot.docs) {
        try {
          final hotel = HotelModel.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
          hotels.add(hotel);
        } catch (e) {
          print('❌ Error parsing document ${doc.id}: $e');
        }
      }

      print('✅ Successfully parsed ${hotels.length} hotels');
      return hotels;
    } catch (e) {
      print('❌ Error fetching hotels: $e');
      return [];
    }
  }

  // ✅ Get hotels by city (Stream - For Users)
  Stream<List<HotelModel>> getHotelsByCity(String cityId) {
    print('🟢 Fetching hotels for city: $cityId');

    return _firestore
        .collection(collection)
        .where("cityId", isEqualTo: cityId)
        .snapshots()
        .map((snapshot) {
          print('🟢 Found ${snapshot.docs.length} hotels for city: $cityId');

          if (snapshot.docs.isEmpty) {
            print('⚠️ No hotels found for city: $cityId');
          }

          final hotels = snapshot.docs
              .map((doc) {
                try {
                  return HotelModel.fromFirestore(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );
                } catch (e) {
                  print('❌ Error parsing hotel ${doc.id}: $e');
                  return null;
                }
              })
              .where((hotel) => hotel != null)
              .cast<HotelModel>()
              .toList();

          print('✅ Parsed ${hotels.length} hotels for city: $cityId');
          return hotels;
        });
  }

  // ✅ Get single hotel by ID (For Users)
  Future<HotelModel?> getHotelById(String id) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(collection)
          .doc(id)
          .get();

      if (!doc.exists) return null;

      return HotelModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      print('❌ Error fetching hotel: $e');
      return null;
    }
  }

  // ✅ Get hotels by rating (For Users)
  Future<List<HotelModel>> getHotelsByRating(double minRating) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(collection)
          .where('rating', isGreaterThanOrEqualTo: minRating)
          .orderBy('rating', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return HotelModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      print('❌ Error fetching hotels by rating: $e');
      return [];
    }
  }

  // ✅ Get featured hotels (For Users)
  Future<List<HotelModel>> getFeaturedHotels() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(collection)
          .where('isFeatured', isEqualTo: true)
          .orderBy('rating', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) {
        return HotelModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      print('❌ Error fetching featured hotels: $e');
      return [];
    }
  }
}
