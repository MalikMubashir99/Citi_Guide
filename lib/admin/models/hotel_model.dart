// lib/admin/models/admin_hotel_model.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HotelModel {
  String id;
  String cityId;
  String name;
  String description;
  String image;
  double rating;
  String phone;
  String website;

  // ✅ Additional fields for admin management
  bool isFeatured;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;
  int views;
  int bookings;

  HotelModel({
    required this.id,
    required this.cityId,
    required this.name,
    required this.description,
    required this.image,
    required this.rating,
    required this.phone,
    required this.website,
    this.isFeatured = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.views = 0,
    this.bookings = 0,
  });

  // ✅ Factory method to create from Firestore
  factory HotelModel.fromFirestore(Map<String, dynamic> data, String id) {
    // Handle cityId (could be String or DocumentReference)
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
      name: data['name']?.toString() ?? 'Unknown Hotel',
      description: data['description']?.toString() ?? 'No description available',
      image: data['image']?.toString() ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      phone: data['phone']?.toString() ?? '',
      website: data['website']?.toString() ?? '',
      isFeatured: data['isFeatured'] ?? false,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      views: data['views'] ?? 0,
      bookings: data['bookings'] ?? 0,
    );
  }

  // ✅ Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'cityId': cityId,
      'name': name,
      'description': description,
      'image': image,
      'rating': rating,
      'phone': phone,
      'website': website,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'views': views,
      'bookings': bookings,
    };
  }

  // ✅ Copy with method for updates
  HotelModel copyWith({
    String? id,
    String? cityId,
    String? name,
    String? description,
    String? image,
    double? rating,
    String? phone,
    String? website,
    bool? isFeatured,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? views,
    int? bookings,
  }) {
    return HotelModel(
      id: id ?? this.id,
      cityId: cityId ?? this.cityId,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      views: views ?? this.views,
      bookings: bookings ?? this.bookings,
    );
  }

  // ✅ Validation method
  String? validate() {
    if (name.trim().isEmpty) return 'Hotel name is required';
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
    if (!isActive) return 'Inactive';
    if (isFeatured) return '⭐ Featured';
    return 'Active';
  }

  Color get statusColor {
    if (!isActive) return AppColors.error;
    if (isFeatured) return AppColors.secondary;
    return AppColors.success;
  }
}