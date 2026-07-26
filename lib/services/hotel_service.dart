// lib/services/hotel_service.dart
import 'package:app/model/hotel_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HotelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = "hotels";

  // ✅ Get all hotels
  Future<List<HotelModel>> getAllHotels() async {
    try {
      print('🟢 Fetching all hotels from Firestore...');
      
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
          print('❌ Error parsing hotel document ${doc.id}: $e');
        }
      }
      
      print('✅ Successfully parsed ${hotels.length} hotels');
      return hotels;
    } catch (e) {
      print('❌ Error fetching hotels: $e');
      return [];
    }
  }

  // ✅ Get hotels by city
  Stream<List<HotelModel>> getHotelsByCity(String cityId) {
    return _firestore
        .collection(collection)
        .where("cityId", isEqualTo: cityId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return HotelModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // ✅ Add hotel
  Future<void> addHotel(HotelModel hotel) async {
    try {
      await _firestore.collection(collection).add(hotel.toMap());
      print('✅ Hotel added successfully');
    } catch (e) {
      print('❌ Error adding hotel: $e');
      rethrow;
    }
  }

  // ✅ Update hotel
  Future<void> updateHotel(HotelModel hotel) async {
    try {
      await _firestore
          .collection(collection)
          .doc(hotel.id)
          .update(hotel.toMap());
      print('✅ Hotel updated successfully');
    } catch (e) {
      print('❌ Error updating hotel: $e');
      rethrow;
    }
  }

  // ✅ Delete hotel
  Future<void> deleteHotel(String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
      print('✅ Hotel deleted successfully');
    } catch (e) {
      print('❌ Error deleting hotel: $e');
      rethrow;
    }
  }
}