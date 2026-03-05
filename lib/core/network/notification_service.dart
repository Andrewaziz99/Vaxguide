import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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

    // Initialize timezone database for scheduled notifications
    tz.initializeTimeZones();

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

    // Create Android notification channel with custom sound
    // NOTE: Channel ID changed to v2 to ensure custom sound takes effect
    // (Android caches channel settings; old channels keep the default sound)
    const androidChannel = AndroidNotificationChannel(
      'vaccine_alerts_channel_v2',
      'تنبيهات اللقاحات',
      description: 'إشعارات تنبيهات اللقاحات الجديدة',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('alert_sound'),
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    // Create dose reminder notification channel with custom sound
    const doseReminderChannel = AndroidNotificationChannel(
      'dose_reminders_channel_v2',
      'تذكير بجرعات التطعيم',
      description: 'إشعارات تذكير بمواعيد الجرعات القادمة',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('alert_sound'),
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(doseReminderChannel);

    // Clean up old channels (they used default sound)
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.deleteNotificationChannel(channelId: 'vaccine_alerts_channel');
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.deleteNotificationChannel(channelId: 'dose_reminders_channel');

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
          'vaccine_alerts_channel_v2',
          'تنبيهات اللقاحات',
          channelDescription: 'إشعارات تنبيهات اللقاحات الجديدة',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          sound: const RawResourceAndroidNotificationSound('alert_sound'),
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(
            notification.body ?? '',
            contentTitle: notification.title,
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'alert_sound.wav',
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

  // ══════════════════════════════════════════
  // DOSE REMINDERS
  // ══════════════════════════════════════════

  /// Schedule a local notification to remind the user about the next dose.
  /// [vaccineId] + [doseNumber] are used to create a unique notification ID.
  Future<void> scheduleDoseReminder({
    required String vaccineId,
    required String vaccineName,
    required int nextDoseNumber,
    required String nextDoseLabel,
    required DateTime scheduledDate,
  }) async {
    // Generate a stable notification ID from vaccineId + dose number
    final notifId = (vaccineId.hashCode + nextDoseNumber) & 0x7FFFFFFF;

    // Schedule at 9:00 AM on the reminder day
    final scheduledDateTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      9,
      0,
    );

    // Don't schedule if the date is in the past
    if (scheduledDateTime.isBefore(DateTime.now())) {
      debugPrint('🔔 Dose reminder date is in the past, skipping.');
      return;
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDateTime, tz.local);

    await _localNotifications.zonedSchedule(
      id: notifId,
      title: '💉 موعد $nextDoseLabel',
      body:
          'حان موعد تلقي $nextDoseLabel من لقاح "$vaccineName". لا تنسَ زيارة أقرب مركز صحي.',
      scheduledDate: tzScheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'dose_reminders_channel_v2',
          'تذكير بجرعات التطعيم',
          channelDescription: 'إشعارات تذكير بمواعيد الجرعات القادمة',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          sound: RawResourceAndroidNotificationSound('alert_sound'),
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'alert_sound.wav',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );

    debugPrint(
      '🔔 Dose reminder scheduled: $vaccineName dose $nextDoseNumber on $scheduledDate',
    );
  }

  /// Cancel a previously scheduled dose reminder.
  Future<void> cancelDoseReminder({
    required String vaccineId,
    required int doseNumber,
  }) async {
    final notifId = (vaccineId.hashCode + doseNumber) & 0x7FFFFFFF;
    await _localNotifications.cancel(id: notifId);
    debugPrint('🔔 Dose reminder cancelled: id=$notifId');
  }
}
