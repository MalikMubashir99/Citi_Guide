// lib/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // ✅ Static method
  static Future<void> initialize() async {
    try {
      if (kIsWeb) {
        await _messaging.requestPermission();
        final token = await _messaging.getToken();
        debugPrint('FCM Token: $token');
        
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('Got a message whilst in the foreground!');
          debugPrint('Message data: ${message.data}');
        });
        
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          debugPrint('A new onMessageOpenedApp event was published!');
        });
      } else {
        NotificationSettings settings = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        
        debugPrint('User granted permission: ${settings.authorizationStatus}');
        
        final token = await _messaging.getToken();
        debugPrint('FCM Token: $token');
        
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('Got a message whilst in the foreground!');
          debugPrint('Message data: ${message.data}');
        });
        
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          debugPrint('A new onMessageOpenedApp event was published!');
        });
      }
    } catch (e) {
      debugPrint('Notification Service Error: $e');
    }
  }
}