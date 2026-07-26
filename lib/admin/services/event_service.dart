// lib/admin/services/event_service.dart
import 'package:app/admin/models/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = "events";

  // ✅ Get all events as Stream
  Stream<List<EventModel>> getEvents() {
    return _firestore
        .collection(collection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return EventModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // ✅ Get events by city (Future)
  Future<List<EventModel>> getEventsByCity(String cityId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(collection)
          .where('cityId', isEqualTo: cityId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return EventModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      print('❌ Error fetching events by city: $e');
      return [];
    }
  }

  // ✅ Get all events (Future)
  Future<List<EventModel>> getAllEvents() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(collection)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return EventModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      print('❌ Error fetching events: $e');
      return [];
    }
  }

  // ✅ Get event by ID
  Future<EventModel?> getEventById(String id) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(collection)
          .doc(id)
          .get();
      
      if (!doc.exists) return null;
      
      return EventModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      print('❌ Error fetching event: $e');
      return null;
    }
  }

  // ✅ Add event
  Future<String> addEvent(EventModel event) async {
    try {
      final docRef = await _firestore
          .collection(collection)
          .add(event.toMap());
      
      print('✅ Event added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error adding event: $e');
      rethrow;
    }
  }

  // ✅ Update event
  Future<void> updateEvent(EventModel event) async {
    try {
      await _firestore
          .collection(collection)
          .doc(event.id)
          .update(event.toMap());
      
      print('✅ Event updated: ${event.id}');
    } catch (e) {
      print('❌ Error updating event: $e');
      rethrow;
    }
  }

  // ✅ Delete event
  Future<void> deleteEvent(String id) async {
    try {
      await _firestore
          .collection(collection)
          .doc(id)
          .delete();
      
      print('✅ Event deleted: $id');
    } catch (e) {
      print('❌ Error deleting event: $e');
      rethrow;
    }
  }

  // ✅ Search events
  Future<List<EventModel>> searchEvents(String query) async {
    try {
      final allEvents = await getAllEvents();
      
      return allEvents.where((event) {
        return event.title.toLowerCase().contains(query.toLowerCase()) ||
            event.description.toLowerCase().contains(query.toLowerCase()) ||
            event.location.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      print('❌ Error searching events: $e');
      return [];
    }
  }

  // ✅ Get events count
  Future<int> getEventsCount() async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .count()
          .get();
      
      return snapshot.count ?? 0;
    } catch (e) {
      print('❌ Error getting events count: $e');
      return 0;
    }
  }

  // ✅ Get upcoming events
  Future<List<EventModel>> getUpcomingEvents() async {
    try {
      final allEvents = await getAllEvents();
      final now = DateTime.now();
      
      return allEvents.where((event) {
        try {
          final eventDate = DateTime.parse(event.date);
          return eventDate.isAfter(now);
        } catch (_) {
          return false;
        }
      }).toList();
    } catch (e) {
      print('❌ Error fetching upcoming events: $e');
      return [];
    }
  }

  // ✅ Validate event
  static String? validateEvent(EventModel event) {
    if (event.title.trim().isEmpty) {
      return 'Event title is required';
    }
    if (event.cityId.trim().isEmpty) {
      return 'City ID is required';
    }
    if (event.description.trim().isEmpty) {
      return 'Description is required';
    }
    if (event.image.trim().isEmpty) {
      return 'Image URL is required';
    }
    if (event.date.trim().isEmpty) {
      return 'Date is required';
    }
    if (event.time.trim().isEmpty) {
      return 'Time is required';
    }
    if (event.location.trim().isEmpty) {
      return 'Location is required';
    }
    return null;
  }
}