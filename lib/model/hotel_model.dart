// lib/model/hotel_model.dart
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

  factory HotelModel.fromFirestore(Map<String, dynamic> data, String id) {
    // ✅ Add debugging to see what data is coming
    print('🔍 Parsing hotel data for ID: $id');
    print('📦 Data: $data');
    
    // ✅ Handle both String and DocumentReference for cityId
    String cityIdValue;
    final cityIdData = data['cityId'];
    
    if (cityIdData is DocumentReference) {
      cityIdValue = cityIdData.id;
    } else {
      cityIdValue = cityIdData?.toString() ?? '';
    }

    // ✅ Handle null values with fallbacks
    final hotel = HotelModel(
      id: id,
      cityId: cityIdValue,
      name: data['name']?.toString() ?? 'Unknown Hotel',
      description: data['description']?.toString() ?? 'No description available',
      image: data['image']?.toString() ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      phone: data['phone']?.toString() ?? '',
      website: data['website']?.toString() ?? '',
    );
    
    print('✅ Parsed hotel: ${hotel.name}');
    return hotel;
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