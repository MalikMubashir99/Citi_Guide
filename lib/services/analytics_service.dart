// lib/services/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static FirebaseAnalytics get analytics => _analytics;

  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // Screen Tracking
  static Future<void> setCurrentScreen(String screenName) async {
    await _analytics.setCurrentScreen(screenName: screenName);
  }

  // Event Tracking
  static Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  // ✅ Login Event
  static Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  // ✅ Sign Up Event
  static Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  // ✅ View Item Event
  static Future<void> logViewItem({
    required String itemName,
    required String itemType,
    String? itemId,
  }) async {
    await _analytics.logViewItemList(
      itemListName: itemName,
      itemListId: itemType,
    );
    
    if (itemId != null) {
      await _analytics.logSelectItem(
        itemListId: itemType,
        itemListName: itemName,
        items: [
          AnalyticsEventItem(
            itemId: itemId,
            itemName: itemName,
          ),
        ],
      );
    }
  }

  // ✅ Add to Favorites Event
  static Future<void> logAddToFavorites({
    required String itemId,
    required String itemName,
    required String itemType,
    double price = 0,
  }) async {
    await _analytics.logAddToWishlist(
      currency: 'PKR',
      value: price,
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemName: itemName,
          itemCategory: itemType,
        ),
      ],
    );
  }

  // ✅ Search Event
  static Future<void> logSearch(String searchTerm) async {
    await _analytics.logSearch(searchTerm: searchTerm);
  }

  // ✅ Share Event
  static Future<void> logShare({
    required String contentType,
    required String contentId,
    required String method,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: contentId,
      method: method,
    );
  }

  // ✅ Add to Cart
  static Future<void> logAddToCart({
    required String itemId,
    required String itemName,
    required String itemType,
    required double price,
    required int quantity,
  }) async {
    await _analytics.logAddToCart(
      currency: 'PKR',
      value: price * quantity,
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemName: itemName,
          itemCategory: itemType,
          price: price,
          quantity: quantity,
        ),
      ],
    );
  }

  // ✅ Begin Checkout (Fixed - removed itemCount)
  static Future<void> logBeginCheckout({
    required double totalValue,
    required String currency,
  }) async {
    await _analytics.logBeginCheckout(
      currency: currency,
      value: totalValue,
    );
  }

  // ✅ Purchase
  static Future<void> logPurchase({
    required String transactionId,
    required double totalValue,
    required String currency,
    required List<AnalyticsEventItem> items,
  }) async {
    await _analytics.logPurchase(
      transactionId: transactionId,
      currency: currency,
      value: totalValue,
      items: items,
    );
  }

  // ✅ App Open
  static Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  // ✅ Notification Received
  static Future<void> logNotificationReceived(String notificationId) async {
    await _analytics.logEvent(
      name: 'notification_received',
      parameters: {
        'notification_id': notificationId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ✅ Notification Tapped
  static Future<void> logNotificationTapped(String notificationId) async {
    await _analytics.logEvent(
      name: 'notification_tapped',
      parameters: {
        'notification_id': notificationId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ✅ Rating Event
  static Future<void> logRating({
    required String itemId,
    required String itemName,
    required double rating,
  }) async {
    await _analytics.logEvent(
      name: 'item_rating',
      parameters: {
        'item_id': itemId,
        'item_name': itemName,
        'rating': rating,
      },
    );
  }

  // ✅ Profile Update
  static Future<void> logProfileUpdate() async {
    await _analytics.logEvent(name: 'profile_update');
  }

  // ✅ Password Reset
  static Future<void> logPasswordReset() async {
    await _analytics.logEvent(name: 'password_reset');
  }

  // ✅ Error Logging
  static Future<void> logError({
    required String errorMessage,
    required String errorCode,
    String? screenName,
  }) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_message': errorMessage,
        'error_code': errorCode,
        'screen_name': screenName ?? 'unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ✅ Enable/Disable Analytics
  static Future<void> setAnalyticsEnabled(bool enabled) async {
    await _analytics.setAnalyticsCollectionEnabled(enabled);
  }

  // ✅ Set User Properties
  static Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // ✅ Reset Analytics Data
  static Future<void> resetAnalyticsData() async {
    await _analytics.resetAnalyticsData();
  }
}