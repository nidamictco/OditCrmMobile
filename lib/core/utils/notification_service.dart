import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odit_crm_mobile/core/constant/firebase_constant.dart';
import 'package:odit_crm_mobile/feature/general_settings/data/general_setting_repo.dart';
import 'package:odit_crm_mobile/feature/general_settings/model/general_settings_model.dart';

/// Must be a top-level (or static) function — required by FCM for background isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase.initializeApp() must be called here too, since this runs in
  // a separate isolate with no prior app state.
  // If your main.dart already does `WidgetsFlutterBinding.ensureInitialized()`
  // + `Firebase.initializeApp()`, mirror that minimal init here.
  log('[FCM][Background] message: ${message.messageId}, data: ${message.data}');
  // NOTE: We intentionally do NOT show a local notification here.
  // On Android, a `notification` payload from FCM is auto-displayed by the
  // OS tray when the app is backgrounded/terminated — no local-notif call needed.
  // We only need this handler registered so onMessageOpenedApp / getInitialMessage
  // resolve correctly later.
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

static String? _currentStaffId;

  static const _channel = AndroidNotificationChannel(
    'high_importance_channel', // must match AndroidManifest meta-data below
    'High Importance Notifications',
    description: 'Used for important CRM notifications.',
    importance: Importance.high,
  );

  static bool _initialized = false;

  /// Call once from main.dart after Firebase.initializeApp().
  static Future<void> initialize({
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    if (_initialized) return;
    _initialized = true;

    // ── Local notifications setup (foreground display only) ────────────
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false, // we request via FirebaseMessaging below
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    // Initialize local notifications plugin (required for foreground display)
    await _localPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) {
          _handleNavigationFromPayloadString(payload, navigatorKey);
        }
      },
    );

   if (Platform.isAndroid) {
  await _localPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_channel);
}

    // ── Register background handler (must be top-level function) ───────
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // ── Request permission (Android 13+, iOS) ───────────────────────────
    await requestPermission();

    // ── Foreground messages ──────────────────────────────────────────────
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log('[FCM][Foreground] ${message.messageId}, data: ${message.data}');
      await _showForegroundIfAllowed(message);
    });

    // ── App opened from background via notification tap ────────────────
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('[FCM][onMessageOpenedApp] data: ${message.data}');
      _handleNavigationFromData(message.data, navigatorKey);
    });

    // ── App launched (terminated -> opened) via notification tap ───────
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      log('[FCM][getInitialMessage] data: ${initialMessage.data}');
      // Delay slightly so the navigator/router is mounted before we push.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNavigationFromData(initialMessage.data, navigatorKey);
      });
    }

    // ── Token refresh listener ───────────────────────────────────────────
    // FIX: use _currentStaffId (not the token) as the staff document ID
    _fcm.onTokenRefresh.listen((newToken) {
      log('[FCM] token refreshed: $newToken');
      final staffId = _currentStaffId;
      if (staffId != null && staffId.isNotEmpty) {
        _saveToken(staffId, newToken);
      }
    });
  }

  static Future<NotificationSettings> requestPermission() {
    return _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  /// Fetch current device token and persist to STAFF/{staffId}.fcmToken.
  static Future<void> registerTokenAfterLogin(String staffId) async {
    _currentStaffId = staffId; 
    try {
      final token = await _fetchFcmToken();
      if (token == null) {
        log('[FCM] token unavailable for staff $staffId (APNs not ready?)');
        return;
      }
      await _saveToken(staffId, token);
      log('[FCM] token saved for staff $staffId: $token');
    } catch (e) {
      log('[FCM] registerTokenAfterLogin error: $e');
    }
  }

  static Future<void> saveTokenForCurrentStaff(String? staffId) async {
    if (staffId == null || staffId.isEmpty) return;
    final token = await _fetchFcmToken();
    if (token == null) return;
    await _saveToken(staffId, token);
  }

  /// Fetches the FCM token. On iOS the FCM token is only available *after*
  /// the APNs token has been assigned by Apple, which can lag a few seconds
  /// on a real device. We wait for the APNs token first, otherwise
  /// `getToken()` returns null and the device never registers for pushes.
  static Future<String?> _fetchFcmToken() async {
    if (Platform.isIOS) {
      String? apnsToken = await _fcm.getAPNSToken();
      // Retry: the APNs token may not be ready immediately after launch.
      for (var i = 0; i < 5 && apnsToken == null; i++) {
        await Future.delayed(const Duration(seconds: 2));
        apnsToken = await _fcm.getAPNSToken();
      }
      if (apnsToken == null) {
        log('[FCM][iOS] APNs token still null — cannot fetch FCM token. '
            'Check APNs key in Firebase console + Push Notifications capability.');
        return null;
      }
      log('[FCM][iOS] APNs token acquired: $apnsToken');
    }
    return _fcm.getToken();
  }

//   static Future<void> _saveToken(String staffId, String token) async {
//     // await FirestorePath.companyCollection('STAFF').doc(staffId).update({
//     //   'fcmToken': token,
//     // });
//     await FirestorePath.companyCollection('STAFF').doc(staffId).set(
//   {'fcmToken': token},
//   SetOptions(merge: true),
// );
//   }
static Future<void> _saveToken(String staffId, String token) async {
  final staffCollection = FirestorePath.companyCollection('STAFF');

  // Prevent token collisions: if this exact device token is still
  // sitting on a DIFFERENT staff doc (e.g. logout didn't clear it,
  // or multiple accounts were tested on one device), strip it from
  // that doc first so only the current owner keeps it.
  final stale = await staffCollection
      .where('fcmToken', isEqualTo: token)
      .get();

  for (final doc in stale.docs) {
    if (doc.id != staffId) {
      await doc.reference.update({'fcmToken': FieldValue.delete()});
      log('[FCM] cleared stale token from previous owner ${doc.id}');
    }
  }

  await staffCollection.doc(staffId).set(
    {'fcmToken': token},
    SetOptions(merge: true),
  );
}

  /// Optional: call on logout so stale tokens don't receive pushes for
  /// a user who is no longer signed in on this device.
  static Future<void> clearTokenOnLogout(String staffId) async {
    try {
      await FirestorePath.companyCollection('STAFF').doc(staffId).update({
        'fcmToken': FieldValue.delete(),
      });
      await _fcm.deleteToken();
      _currentStaffId= null;
    } catch (e) {
      log('[FCM] clearTokenOnLogout error: $e');
    }
  }

  // ── Foreground display, gated by existing settings ──────────────────────
  static Future<void> _showForegroundIfAllowed(RemoteMessage message) async {
    final title = message.notification?.title ?? message.data['title'] ?? '';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    if (title.isEmpty && body.isEmpty) return;

     final staffId = _currentStaffId;
    GeneralSettingsModel settings;
     if (staffId == null || staffId.isEmpty) {
    settings = const GeneralSettingsModel(); // no staff context yet — safe fallback
  } else {
    try {
      settings = await GeneralSettingsRepository(staffId: staffId).fetchSettings();
    } catch (e) {
      settings = const GeneralSettingsModel(); // safe fallback
    }}

    if (!_isAllowed(title: title, type: message.data['type'], settings: settings)) {
      log('[FCM] foreground notification suppressed by settings: $title');
      return;
    }

    await show(
      title: title,
      body: body,
      payloadData: message.data,
    );
  }

  static bool _isAllowed({
    required String title,
    String? type,
    required GeneralSettingsModel settings,
  }) {
    final t = title.toLowerCase();
    final ty = (type ?? '').toLowerCase();

    if (t.contains('new lead') || ty == 'lead') return settings.newLead;
    if (t.contains('leads imported') || t.contains('import complete')) {
      return settings.newLead;
    }
    if (t.contains('transfer') || t.contains('transferred') || ty == 'transfer') {
      return settings.transferLead;
    }
    if (t.contains('facebook') || ty == 'facebook_lead') return settings.facebookLead;

    return true;
  }

  /// Displays a local (foreground) notification banner.
  static Future<void> show({
    required String title,
    required String body,
    Map<String, dynamic>? payloadData,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    // Encode data payload as a simple string so the local-notif callback
    // (which only gives us a String? payload) can still route navigation
    // if the user taps the foreground banner itself.
    final payloadString = payloadData == null
        ? null
        : payloadData.entries.map((e) => '${e.key}=${e.value}').join('&');

    // Show the foreground notification banner.
    await _localPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payloadString,
    );
  }

  // ── Navigation helpers ───────────────────────────────────────────────────
  static void _handleNavigationFromData(
    Map<String, dynamic> data,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    final type = data['type'];
    final leadId = data['leadId'];
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    switch (type) {
      case 'lead':
        if (leadId != null) {
          nav.pushNamed('/leadDetail', arguments: {'leadId': leadId});
        }
        break;
      case 'transfer':
        if (leadId != null) {
          nav.pushNamed('/leadDetail', arguments: {'leadId': leadId});
        }
        break;
      default:
        nav.pushNamed('/notifications');
    }
  }

  static void _handleNavigationFromPayloadString(
    String payload,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    final map = <String, dynamic>{};
    for (final part in payload.split('&')) {
      final kv = part.split('=');
      if (kv.length == 2) map[kv[0]] = kv[1];
    }
    _handleNavigationFromData(map, navigatorKey);
  }

  // FIX: use Flutter's built-in kIsWeb constant from 'package:flutter/foundation.dart'
  static bool kIsWebSafe() => kIsWeb;
}