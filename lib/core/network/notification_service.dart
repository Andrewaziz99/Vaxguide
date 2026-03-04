import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level function required for background message handling.
/// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔔 Background message: ${message.messageId}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Call once from main() after Firebase.initializeApp().
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // 1. Request permission (iOS & Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('🔔 Notification permission: ${settings.authorizationStatus}');

    // 2. Subscribe all users to the "vaccine_alerts" topic
    await _messaging.subscribeToTopic('vaccine_alerts');
    debugPrint('🔔 Subscribed to topic: vaccine_alerts');

    // 3. Initialize local notifications (for foreground display)
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'vaccine_alerts_channel',
      'تنبيهات اللقاحات',
      description: 'إشعارات تنبيهات اللقاحات الجديدة',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    // 4. Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 5. Handle notification taps when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // 6. Check if the app was opened from a terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    // Log FCM token for debugging
    final token = await _messaging.getToken();
    debugPrint('🔔 FCM Token: $token');
  }

  /// Show a local notification when a message arrives while app is in foreground.
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('🔔 Foreground message: ${message.notification?.title}');

    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'vaccine_alerts_channel',
          'تنبيهات اللقاحات',
          channelDescription: 'إشعارات تنبيهات اللقاحات الجديدة',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(
            notification.body ?? '',
            contentTitle: notification.title,
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
    );
  }

  /// Called when user taps a notification while app is in background.
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('🔔 Notification tap (background): ${message.data}');
    // The alert detail will be visible on the home screen already
    // via the real-time Firestore stream.
  }

  /// Called when user taps a local notification (foreground).
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('🔔 Local notification tap: ${response.payload}');
  }
}
