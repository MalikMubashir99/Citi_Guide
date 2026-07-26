// lib/model/restaurant_model.dart
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

  factory RestaurantModel.fromFirestore(Map<String, dynamic> data, String id) {
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
      name: data['name']?.toString() ?? 'Unknown Restaurant',
      cityId: cityIdValue,
      image: data['image']?.toString() ?? '',
      description: data['description']?.toString() ?? 'No description available',
      rating: (data['rating'] ?? 0).toDouble(),
      phone: data['phone']?.toString() ?? '',
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

  // ✅ Copy with method for updates
  RestaurantModel copyWith({
    String? id,
    String? name,
    String? cityId,
    String? image,
    String? description,
    double? rating,
    String? phone,
    double? latitude,
    double? longitude,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      cityId: cityId ?? this.cityId,
      image: image ?? this.image,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      phone: phone ?? this.phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  // ✅ Validation method
  String? validate() {
    if (name.trim().isEmpty) return 'Restaurant name is required';
    if (cityId.trim().isEmpty) return 'City ID is required';
    if (description.trim().isEmpty) return 'Description is required';
    if (image.trim().isEmpty) return 'Image URL is required';
    if (rating < 0 || rating > 5) return 'Rating must be between 0 and 5';
    return null;
  }

  // ✅ Helper methods
  String get ratingLabel {
    if (rating >= 4.5) return '⭐ Excellent';
    if (rating >= 4.0) return '😊 Very Good';
    if (rating >= 3.0) return '👍 Good';
    if (rating >= 2.0) return '👎 Fair';
    return '😞 Poor';
  }

  String get statusLabel {
    if (rating >= 4.5) return 'Popular';
    if (rating >= 3.0) return 'Good';
    return 'Standard';
  }
}