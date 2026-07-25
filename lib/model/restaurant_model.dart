import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel {
  String id;
  String name;
  String cityId;
  String image;
  String description;
  double rating;
  String phone;
  double latitude;
  double longitude;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.cityId,
    required this.image,
    required this.description,
    required this.rating,
    required this.phone,
    required this.latitude,
    required this.longitude,
  });

  factory RestaurantModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    // ✅ Handle both String and DocumentReference for cityId
    String cityIdValue;
    final cityIdData = data['cityId'];
    
    if (cityIdData is DocumentReference) {
      cityIdValue = cityIdData.id;
    } else {
      cityIdValue = cityIdData?.toString() ?? '';
    }

    return RestaurantModel(
      id: id,
      name: data['name'] ?? '',
      cityId: cityIdValue,
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      phone: data['phone'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cityId': cityId,
      'image': image,
      'description': description,
      'rating': rating,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}