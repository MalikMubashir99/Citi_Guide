import 'package:app/admin/models/attraction_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttractionService {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  Stream<List<AttractionModel>> getAttractions() {
    return firestore
        .collection("attractions")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AttractionModel.fromFirestore(
          doc.data(),
          doc.id,
        );
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
    await firestore.collection("attractions").add({
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
      .collection("attractions")
      .doc(attraction.id)
      .update(attraction.toMap());  // ✅ toMap() is now defined
}

  Future<void> deleteAttraction(String id) async {
    await firestore
        .collection("attractions")
        .doc(id)
        .delete();
  }
}