import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/api_constants.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  final Dio _dio;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  Map<String, dynamic>? _pendingNavigationData;
  void Function(Map<String, dynamic>)? _onNavigateTap;

  NotificationService({required Dio dio}) : _dio = dio;

  void setNavigationHandler(void Function(Map<String, dynamic>) handler) {
    _onNavigateTap = handler;
  }

  Future<NotificationSettings> requestPermission() async {
    return _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('[FCM] getToken failed: $e');
      return null;
    }
  }

  Future<void> uploadToken(String token) async {
    debugPrint('[FCM DEBUG TOKEN] ---> $token');
    final deviceType = defaultTargetPlatform == TargetPlatform.iOS
        ? 'ios'
        : 'android';
    try {
      await _dio.patch(
        ApiConstants.fcmToken,
        data: {'fcm_token': token, 'device_type': deviceType},
      );
    } catch (e) {
      debugPrint('[FCM] uploadToken failed: $e');
    }
  }

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) {
          try {
            final data = jsonDecode(payload) as Map<String, dynamic>;
            _onNavigateTap?.call(data);
          } catch (_) {}
        }
      },
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Capture notification that launched the app from a terminated state
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null && initialMessage.data.isNotEmpty) {
        debugPrint('[FCM] App launched from terminated notification: ${initialMessage.data}');
        _pendingNavigationData = initialMessage.data;
      }
    } catch (e) {
      debugPrint('[FCM] getInitialMessage failed: $e');
    }

    // Listen for notification taps that open app from background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM] App opened from background notification: ${message.data}');
      _pendingNavigationData = message.data;
    });

    // Re-upload FCM token whenever it refreshes
    _messaging.onTokenRefresh.listen((t) {
      debugPrint('[FCM] Token refreshed, re-uploading');
      uploadToken(t);
    });

    // Show local notification for foreground messages
    FirebaseMessaging.onMessage.listen(_showLocalNotification);
  }

  Future<void> handlePostLogin() async {
    await requestPermission();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    final token = await getToken();
    if (token != null) {
      await uploadToken(token);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? 'TezoCare';
    final body = message.notification?.body ?? '';
    final data = message.data;

    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: data.isNotEmpty ? jsonEncode(data) : null,
    );
  }

  Map<String, dynamic>? consumePendingNavigation() {
    final data = _pendingNavigationData;
    _pendingNavigationData = null;
    return data;
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // The backend always includes a notification payload (title + body),
  // so the system displays it automatically. This handler is kept for
  // future data-only push support.
  debugPrint('[FCM] Background message: ${message.messageId}');
}
