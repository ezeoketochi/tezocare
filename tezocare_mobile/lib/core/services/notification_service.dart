import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';

class NotificationService {
  final Dio _dio;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  Map<String, dynamic>? _pendingNavigationData;
  final ValueNotifier<RemoteMessage?> pendingForegroundNotification =
      ValueNotifier(null);

  NotificationService({required Dio dio}) : _dio = dio;

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
    try {
      await _dio.patch(
        ApiConstants.fcmToken,
        data: {'fcm_token': token, 'device_type': 'android'},
      );
    } catch (_) {}
  }

  void initialize() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _pendingNavigationData = message.data;
    });
  }

  Future<void> handlePostLogin() async {
    await requestPermission();
    final token = await getToken();
    if (token != null) {
      await uploadToken(token);
    }
    _messaging.onTokenRefresh.listen((t) => uploadToken(t));
    FirebaseMessaging.onMessage.listen((message) {
      pendingForegroundNotification.value = message;
    });
  }

  Map<String, dynamic>? consumePendingNavigation() {
    final data = _pendingNavigationData;
    _pendingNavigationData = null;
    return data;
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}
