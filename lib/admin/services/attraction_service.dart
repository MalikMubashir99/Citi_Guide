// lib/admin/services/attraction_service.dart
import 'package:app/admin/models/attraction_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttractionService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collection = "attractions"; // ✅ Add this

  Stream<List<AttractionModel>> getAttractions() {
    return firestore.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AttractionModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> addAttraction({
    required String name,
    required String cityId,
    required String description,
    required String image,
    required double rating,
    required String openingHours,
    required String phone,
    required String website,
    required double latitude,
    required double longitude,
  }) async {
    await firestore.collection(collection).add({
      "name": name,
      "cityId": cityId,
      "description": description,
      "image": image,
      "rating": rating,
      "openingHours": openingHours,
      "phone": phone,
      "website": website,
      "latitude": latitude,
      "longitude": longitude,
    });
  }

  Future<void> updateAttraction(AttractionModel attraction) async {
    await firestore
        .collection(collection)
        .doc(attraction.id)
        .update(attraction.toMap());
  }

 Future<void> deleteAttraction(String id) async {
  try {
    print('🟢 Deleting attraction: $id');
    await firestore.collection(collection).doc(id).delete();
    print('✅ Attraction deleted successfully: $id');
  } catch (e) {
    print('❌ Error deleting attraction: $e');
    rethrow;
  }
}

  // ✅ Fixed: Use 'firestore' not '_firestore'
  Future<List<AttractionModel>> getAttractionsByCity(String cityId) async {
    try {
      final QuerySnapshot snapshot = await firestore
          .collection(collection)
          .where('cityId', isEqualTo: cityId)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) {
        return AttractionModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      print('❌ Error fetching attractions by city: $e');
      return [];
    }
  }

  // ✅ Add this if you need to get attraction by ID
  Future<AttractionModel?> getAttractionById(String id) async {
    try {
      final DocumentSnapshot doc = await firestore
          .collection(collection)
          .doc(id)
          .get();
      
      if (!doc.exists) return null;
      
      return AttractionModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      print('❌ Error fetching attraction: $e');
      return null;
    }
  }

  // ✅ Add this for counting attractions
  Future<int> getAttractionsCount() async {
    try {
      final snapshot = await firestore
          .collection(collection)
          .count()
          .get();
      
      return snapshot.count ?? 0;
    } catch (e) {
      print('❌ Error getting attractions count: $e');
      return 0;
    }
  }

  // ✅ Add this for searching attractions
  Future<List<AttractionModel>> searchAttractions(String query) async {
    try {
      final allAttractions = await getAttractions().first;
      
      return allAttractions.where((attraction) {
        return attraction.name.toLowerCase().contains(query.toLowerCase()) ||
            attraction.description.toLowerCase().contains(query.toLowerCase()) ||
            attraction.cityId.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      print('❌ Error searching attractions: $e');
      return [];
    }
  }
}