import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> openNotificationSettings() async {
  if (Platform.isAndroid) {
    final packageInfo = await PackageInfo.fromPlatform();

    final intent = AndroidIntent(
      action: 'android.settings.APP_NOTIFICATION_SETTINGS',
      arguments: <String, dynamic>{
        'android.provider.extra.APP_PACKAGE': packageInfo.packageName,
      },
    );

    await intent.launch();
  } else {
    await openAppSettings();
  }
}