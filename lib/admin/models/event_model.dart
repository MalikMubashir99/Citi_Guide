// lib/admin/models/event_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventModel {
  String id;
  String title;
  String cityId;
  String image;
  String description;
  String date;
  String time;
  String location;

  EventModel({
    required this.id,
    required this.title,
    required this.cityId,
    required this.image,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
  });

  factory EventModel.fromFirestore(Map<String, dynamic> data, String id) {
    // ✅ Handle both String and DocumentReference for cityId
    String cityIdValue;
    final cityIdData = data['cityId'];
    
    if (cityIdData is DocumentReference) {
      cityIdValue = cityIdData.id;
    } else {
      cityIdValue = cityIdData?.toString() ?? '';
    }

    return EventModel(
      id: id,
      title: data['title']?.toString() ?? 'Unknown Event',
      cityId: cityIdValue,
      image: data['image']?.toString() ?? '',
      description: data['description']?.toString() ?? 'No description available',
      date: data['date']?.toString() ?? '',
      time: data['time']?.toString() ?? '',
      location: data['location']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'cityId': cityId,
      'image': image,
      'description': description,
      'date': date,
      'time': time,
      'location': location,
    };
  }

  // ✅ Copy with method for updates
  EventModel copyWith({
    String? id,
    String? title,
    String? cityId,
    String? image,
    String? description,
    String? date,
    String? time,
    String? location,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      cityId: cityId ?? this.cityId,
      image: image ?? this.image,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
    );
  }

  // ✅ Validation method
  String? validate() {
    if (title.trim().isEmpty) return 'Event title is required';
    if (cityId.trim().isEmpty) return 'City ID is required';
    if (description.trim().isEmpty) return 'Description is required';
    if (image.trim().isEmpty) return 'Image URL is required';
    if (date.trim().isEmpty) return 'Date is required';
    if (time.trim().isEmpty) return 'Time is required';
    if (location.trim().isEmpty) return 'Location is required';
    return null;
  }

  // ✅ Helper methods
  String get formattedDate {
    try {
      // Try to parse and format date
      return date;
    } catch (_) {
      return date;
    }
  }

  String get statusLabel {
    // Check if event is upcoming, ongoing, or past
    try {
      final eventDate = DateTime.parse(date);
      final now = DateTime.now();
      
      if (eventDate.isAfter(now)) {
        return '🟢 Upcoming';
      } else if (eventDate.day == now.day && 
                 eventDate.month == now.month && 
                 eventDate.year == now.year) {
        return '🟡 Today';
      } else {
        return '🔴 Past';
      }
    } catch (_) {
      return '📅 Event';
    }
  }

  Color get statusColor {
    try {
      final eventDate = DateTime.parse(date);
      final now = DateTime.now();
      
      if (eventDate.isAfter(now)) {
        return Colors.green;
      } else if (eventDate.day == now.day && 
                 eventDate.month == now.month && 
                 eventDate.year == now.year) {
        return Colors.orange;
      } else {
        return Colors.red;
      }
    } catch (_) {
      return Colors.blue;
    }
  }
}