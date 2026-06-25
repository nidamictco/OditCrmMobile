import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

class NotificationService {
  static Future<void> show({
    required String title,
    required String body,
  }) async {

    if (!kIsWeb) return;

    if (html.Notification.permission != 'granted') {
      await html.Notification.requestPermission();
    }

    if (html.Notification.permission == 'granted') {
      html.window.alert('$title\n$body');
    }
  }
}