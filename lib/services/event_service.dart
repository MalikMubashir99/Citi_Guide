import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String collection = "events";

    Future<List<EventModel>> getAllEvents() async {
    QuerySnapshot snapshot = await _firestore
        .collection(collection)
        .get();

    return snapshot.docs.map((doc) {
      return EventModel.fromFirestore(
        doc.data() as Map<String, dynamic>, // ✅ Cast
        doc.id,
      );
    }).toList();
  }

  // Add Event
  Future<void> addEvent(EventModel event) async {
    await _firestore.collection(collection).add(event.toMap());
  }

  // Update Event
  Future<void> updateEvent(EventModel event) async {
    await _firestore.collection(collection).doc(event.id).update(event.toMap());
  }

  // Delete Event
  Future<void> deleteEvent(String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }

  // Get Events
  Stream<List<EventModel>> getEvents() {
    return _firestore.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return EventModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get Events By City
  Stream<List<EventModel>> getEventsByCity(String cityId) {
    return _firestore
        .collection(collection)
        .where('cityId', isEqualTo: cityId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return EventModel.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }

  // Get Single Event
  Future<EventModel?> getEvent(String id) async {
    final doc = await _firestore.collection(collection).doc(id).get();

    if (!doc.exists) return null;

    return EventModel.fromFirestore(doc.data()!, doc.id);
  }
}
