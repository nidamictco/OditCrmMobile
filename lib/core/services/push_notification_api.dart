import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:odit_crm_mobile/core/constant/push_notification_config.dart';

/// Thin HTTP client for the `odit-notify-server` push service.
///
/// Mirrors the contract implemented in `odit-notify-server/index.js`:
///   POST {baseUrl}/send-push
///   headers: { 'x-api-secret': <PUSH_API_SECRET> }
///   body:    { tokens: string[], title, body, data? }
class PushNotificationApi {
  PushNotificationApi._();

  /// Sends a push notification to one or more device tokens.
  ///
  /// This is best-effort: any network/server failure is logged and
  /// swallowed so it never breaks the calling flow (lead creation,
  /// transfer, etc.) — the Firestore notification record is already saved
  /// by the time this is called.
  static Future<void> sendPush({
    required List<String> tokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final cleanTokens = tokens.where((t) => t.trim().isNotEmpty).toList();
    if (cleanTokens.isEmpty) {
      log('[PushNotificationApi] no valid FCM token(s) to send to, skipping');
      return;
    }

    final uri = Uri.parse('${PushNotificationConfig.baseUrl}/send-push');

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'x-api-secret': PushNotificationConfig.apiSecret,
            },
            body: jsonEncode({
              'tokens': cleanTokens,
              'title': title,
              'body': body,
              if (data != null) 'data': data,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        log('[PushNotificationApi] send-push failed '
            '(${response.statusCode}): ${response.body}');
        return;
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      log('[PushNotificationApi] sent: ${result['successCount']} success, '
          '${result['failureCount']} failed, failedTokens: '
          '${result['failedTokens']}');
    } catch (e) {
      log('[PushNotificationApi] error calling send-push: $e');
    }
  }
}