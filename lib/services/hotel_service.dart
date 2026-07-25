import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/hotel_model.dart';

class HotelService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final String collection = "hotels";

  // Get All Hotels
  Stream<List<HotelModel>> getHotels() {
    return _firestore
        .collection(collection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return HotelModel.fromFirestore(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }

  // Get Hotels By City
  Stream<List<HotelModel>> getHotelsByCity(
      String cityId) {
    return _firestore
        .collection(collection)
        .where("cityId", isEqualTo: cityId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return HotelModel.fromFirestore(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }

  // Add Hotel
  Future<void> addHotel(HotelModel hotel) async {
    await _firestore.collection(collection).add(
          hotel.toMap(),
        );
  }

  // Update Hotel
  Future<void> updateHotel(HotelModel hotel) async {
    await _firestore
        .collection(collection)
        .doc(hotel.id)
        .update(
          hotel.toMap(),
        );
  }

  // Delete Hotel
  Future<void> deleteHotel(String id) async {
    await _firestore
        .collection(collection)
        .doc(id)
        .delete();
  }
}