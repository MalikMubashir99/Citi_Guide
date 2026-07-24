import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/restaurant_model.dart';

class RestaurantService {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<RestaurantModel>> getRestaurants(String cityId) async {

    QuerySnapshot snapshot = await firestore
        .collection('restaurants')
        .where('cityId', isEqualTo: cityId)
        .get();

    return snapshot.docs.map((doc) {
      return RestaurantModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }
}