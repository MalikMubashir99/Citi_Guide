// lib/admin/services/hotel_service.dart (Already exists)
import 'package:app/admin/models/hotel_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HotelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = "hotels";

  // ✅ Get all hotels with real-time updates
  Stream<List<HotelModel>> getHotelsStream() {
    return _firestore
        .collection(collection)
        .orderBy('name')
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

  // ✅ Get all hotels
  Future<List<HotelModel>> getAllHotels() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(collection)
          .orderBy('name')
          .get();
      
      return snapshot.docs.map((doc) {
        return HotelModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      print('❌ Error fetching hotels: $e');
      return [];
    }
  }

  // ✅ Get hotel by ID
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

  // ✅ Add hotel
  Future<String> addHotel(HotelModel hotel) async {
    try {
      final docRef = await _firestore
          .collection(collection)
          .add(hotel.toMap());
      
      print('✅ Hotel added with ID: ${docRef.id}');
      return docRef.id;
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
      
      print('✅ Hotel updated: ${hotel.id}');
    } catch (e) {
      print('❌ Error updating hotel: $e');
      rethrow;
    }
  }

  // ✅ Delete hotel
  Future<void> deleteHotel(String id) async {
    try {
      await _firestore
          .collection(collection)
          .doc(id)
          .delete();
      
      print('✅ Hotel deleted: $id');
    } catch (e) {
      print('❌ Error deleting hotel: $e');
      rethrow;
    }
  }

  // ✅ Get hotels by city
  Future<List<HotelModel>> getHotelsByCity(String cityId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(collection)
          .where('cityId', isEqualTo: cityId)
          .orderBy('name')
          .get();
      
      return snapshot.docs.map((doc) {
        return HotelModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      print('❌ Error fetching hotels by city: $e');
      return [];
    }
  }

  // ✅ Search hotels
  Future<List<HotelModel>> searchHotels(String query) async {
    try {
      final allHotels = await getAllHotels();
      
      return allHotels.where((hotel) {
        return hotel.name.toLowerCase().contains(query.toLowerCase()) ||
            hotel.description.toLowerCase().contains(query.toLowerCase()) ||
            hotel.cityId.toLowerCase().contains(query.toLowerCase()) ||
            hotel.phone.contains(query);
      }).toList();
    } catch (e) {
      print('❌ Error searching hotels: $e');
      return [];
    }
  }

  // ✅ Get hotels count
  Future<int> getHotelsCount() async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .count()
          .get();
      
      return snapshot.count ?? 0;
    } catch (e) {
      print('❌ Error getting hotels count: $e');
      return 0;
    }
  }

  // ✅ Get hotel statistics
  Future<Map<String, dynamic>> getHotelStats() async {
    try {
      final allHotels = await getAllHotels();
      
      if (allHotels.isEmpty) {
        return {
          'total': 0,
          'averageRating': 0.0,
          'cities': [],
        };
      }
      
      final total = allHotels.length;
      final avgRating = allHotels.map((h) => h.rating).reduce((a, b) => a + b) / total;
      final cities = allHotels.map((h) => h.cityId).toSet().toList();
      
      return {
        'total': total,
        'averageRating': avgRating,
        'cities': cities,
      };
    } catch (e) {
      print('❌ Error getting hotel stats: $e');
      return {
        'total': 0,
        'averageRating': 0.0,
        'cities': [],
      };
    }
  }

  // ✅ Validate hotel
  static String? validateHotel(HotelModel hotel) {
    if (hotel.name.trim().isEmpty) {
      return 'Hotel name is required';
    }
    if (hotel.cityId.trim().isEmpty) {
      return 'City ID is required';
    }
    if (hotel.description.trim().isEmpty) {
      return 'Description is required';
    }
    if (hotel.image.trim().isEmpty) {
      return 'Image URL is required';
    }
    if (hotel.rating < 0 || hotel.rating > 5) {
      return 'Rating must be between 0 and 5';
    }
    return null;
  }
}