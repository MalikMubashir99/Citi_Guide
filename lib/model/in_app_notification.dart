// lib/models/in_app_notification.dart
class InAppNotification {
  final String id;         
  final String type;       
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  bool isRead;

  InAppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.createdAt,
    this.isRead = false,
  });
}