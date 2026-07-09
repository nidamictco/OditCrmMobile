import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:odit_crm_mobile/app_log.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    if (kIsWeb) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
      defaultPresentBanner: true,
      defaultPresentList: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlatform =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlatform != null) {
      await androidPlatform.requestNotificationsPermission();

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );
      await androidPlatform.createNotificationChannel(channel);
    }

    final IOSFlutterLocalNotificationsPlugin? iosPlatform =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosPlatform != null) {
      final granted = await iosPlatform.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      log('[NotificationService] iOS permission granted: $granted');
    }
  }

  static Future<void> show({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) {
      if (html.Notification.permission != 'granted') {
        await html.Notification.requestPermission();
      }

      if (html.Notification.permission == 'granted') {
        html.window.alert('$title\n$body');
      }
      return;
    }

    if (Platform.isIOS) {
      final iosPlatform =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final permissions = await iosPlatform?.checkPermissions();
      log(
        '[NotificationService] iOS permissions — alert: ${permissions?.isAlertEnabled}, badge: ${permissions?.isBadgeEnabled}, sound: ${permissions?.isSoundEnabled}',
      );

      if (permissions?.isAlertEnabled != true) {
        log('[NotificationService] iOS alert permission not granted — skipping show');
        return;
      }
    }

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    repositoryLog('[NotificationService] showing notification — title: $title');

    await _flutterLocalNotificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }
}
