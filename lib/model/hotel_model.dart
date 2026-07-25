import 'package:cloud_firestore/cloud_firestore.dart';

class HotelModel {
  String id;
  String cityId;
  String name;
  String description;
  String image;
  double rating;
  String phone;
  String website;

  HotelModel({
    required this.id,
    required this.cityId,
    required this.name,
    required this.description,
    required this.image,
    required this.rating,
    required this.phone,
    required this.website,
  });

  factory HotelModel.fromFirestore(
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

    return HotelModel(
      id: id,
      cityId: cityIdValue,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      phone: data['phone'] ?? '',
      website: data['website'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cityId': cityId,
      'name': name,
      'description': description,
      'image': image,
      'rating': rating,
      'phone': phone,
      'website': website,
    };
  }
}