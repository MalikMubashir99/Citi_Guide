// lib/services/in_app_notification_service.dart
import 'package:app/model/in_app_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/services/user_service.dart';

class InAppNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  // Get recent items from all collections
  Future<List<InAppNotification>> getRecentNotifications({int limitPerType = 5}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    // Get user's read list
    final user = await _userService.getUser();
    final readIds = user?.readNotifications ?? [];

    final futures = [
      _fetchRecent('cities', 'city', limitPerType),
      _fetchRecent('attractions', 'attraction', limitPerType),
      _fetchRecent('events', 'event', limitPerType),
      _fetchRecent('hotels', 'hotel', limitPerType),
    ];

    final results = await Future.wait(futures);
    List<InAppNotification> all = results.expand((list) => list).toList();

    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    for (var notif in all) {
      notif.isRead = readIds.contains(notif.id);
    }
    return all;
  }

  Future<List<InAppNotification>> _fetchRecent(String collection, String type, int limit) async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final name = data['name'] ?? data['title'] ?? 'Untitled';
        final cityId = data['cityId'] ?? data['city'] ?? '';
        return InAppNotification(
          id: doc.id,
          type: type,
          title: _getTitle(type, name),
          body: _getBody(type, name, cityId),
          data: {'id': doc.id, ...data},
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isRead: false,
        );
      }).toList();
    } catch (e) {
      print('Error fetching $collection: $e');
      return [];
    }
  }

  String _getTitle(String type, String name) {
    switch (type) {
      case 'city': return 'New city added!';
      case 'attraction': return 'New attraction!';
      case 'event': return 'Upcoming event!';
      case 'hotel': return 'New hotel available!';
      default: return 'New item added!';
    }
  }

  String _getBody(String type, String name, String city) {
    switch (type) {
      case 'city': return 'Explore $name now.';
      case 'attraction': return '$name is now available in $city.';
      case 'event': return '$name starts soon in $city.';
      case 'hotel': return '$name in $city – book your stay!';
      default: return name;
    }
  }

  // Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).update({
      'readNotifications': FieldValue.arrayUnion([notificationId]),
    });
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final notifications = await getRecentNotifications();
    final ids = notifications.map((n) => n.id).toList();
    if (ids.isEmpty) return;
    await _firestore.collection('users').doc(uid).update({
      'readNotifications': FieldValue.arrayUnion(ids),
    });
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    final notifications = await getRecentNotifications();
    return notifications.where((n) => !n.isRead).length;
  }
}