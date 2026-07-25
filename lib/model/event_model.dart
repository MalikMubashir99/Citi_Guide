import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory EventModel.fromFirestore(
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

    return EventModel(
      id: id,
      title: data['title'] ?? '',
      cityId: cityIdValue,
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      location: data['location'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'cityId': cityId, // Store as String
      'image': image,
      'description': description,
      'date': date,
      'time': time,
      'location': location,
    };
  }
}