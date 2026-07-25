import 'package:app/model/attraction_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttractionService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collection = "attractions";

  // Get attractions by city
  Future<List<AttractionModel>> getAttractions(String cityId) async {
    // First try: query with String ID
    QuerySnapshot snapshot = await firestore
        .collection(collection)
        .where('cityId', isEqualTo: cityId)
        .get();

    // If no results, try with DocumentReference (for backward compatibility)
    if (snapshot.docs.isEmpty) {
      DocumentReference cityRef = firestore.collection('cities').doc(cityId);
      snapshot = await firestore
          .collection(collection)
          .where('cityId', isEqualTo: cityRef)
          .get();
    }

    return snapshot.docs.map((doc) {
      return AttractionModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  // Get all attractions
  Future<List<AttractionModel>> getAllAttractions() async {
    QuerySnapshot snapshot = await firestore
        .collection(collection)
        .get();

    return snapshot.docs.map((doc) {
      return AttractionModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  // Add Attraction
  Future<void> addAttraction(AttractionModel attraction) async {
    await firestore
        .collection(collection)
        .add(attraction.toMap());
  }

  // Update Attraction
  Future<void> updateAttraction(AttractionModel attraction) async {
    await firestore
        .collection(collection)
        .doc(attraction.id)
        .update(attraction.toMap());
  }

  // Delete Attraction
  Future<void> deleteAttraction(String id) async {
    await firestore
        .collection(collection)
        .doc(id)
        .delete();
  }

  // Get Single Attraction
  Future<AttractionModel?> getAttraction(String id) async {
    final doc = await firestore
        .collection(collection)
        .doc(id)
        .get();

    if (!doc.exists) return null;

    return AttractionModel.fromFirestore(
      doc.data()!,
      doc.id,
    );
  }
}