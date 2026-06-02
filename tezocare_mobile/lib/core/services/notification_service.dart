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
    } catch (_) {
      return null;
    }
  }

  Future<void> uploadToken(String token) async {
    debugPrint('[FCM DEBUG TOKEN] ---> $token');
    try {
      await _dio.patch(
        ApiConstants.fcmToken,
        data: {'fcm_token': token, 'device_type': 'android'},
      );
    } catch (_) {}
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

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _pendingNavigationData = message.data;
    });
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
    _messaging.onTokenRefresh.listen((t) => uploadToken(t));
    FirebaseMessaging.onMessage.listen(_showLocalNotification);
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
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}
