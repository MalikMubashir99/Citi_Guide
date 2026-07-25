import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/city_model.dart';

class CityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // Add City
  Future<void> addCity({
    required String name,
    required String image,
    required String description,
  }) async {
    await _firestore.collection("cities").add({
      "name": name,
      "image": image,
      "description": description,
    });
  }
  Stream<List<CityModel>> getCities() {

  return FirebaseFirestore.instance
      .collection("cities")
      .snapshots()
      .map((snapshot) {

    return snapshot.docs.map((doc) {

      return CityModel.fromFirestore(
        doc.data(),
        doc.id,
      );

    }).toList();

  });

}

  
  Future<void> updateCity({
    required String id,

    required String name,

    required String image,

    required String description,
  }) async {
    await FirebaseFirestore.instance.collection('cities').doc(id).update({
      "name": name,

      "image": image,

      "description": description,
    });
  }

  Future<void> deleteCity(String id) async {

  await FirebaseFirestore.instance
      .collection("cities")
      .doc(id)
      .delete();

}
}
