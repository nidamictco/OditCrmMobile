import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:odit_crm_mobile/core/constant/firebase_constant.dart';
import 'package:odit_crm_mobile/core/services/push_notification_api.dart';
import '../model/notification_model.dart';

class NotificationRepo {
  final _db = FirebaseFirestore.instance;

  String _generateDateId(String prefix) {
    final now = DateTime.now();
    final datePart = DateFormat('yyyyMMdd').format(now);
    final id = now.millisecondsSinceEpoch.toString();
    return '$prefix-$datePart-$id';
  }

  // Future<void> create({
  //   required String staffId,
  //   required String title,
  //   required String message,
  // }) async {
  //   final String id = _generateDateId('NOTIF');
  //   await FirestorePath.companyCollection('NOTIFICATIONS').doc(id).set({
  //     'staffId': staffId,
  //     'title': title,
  //     'message': message,
  //     'createdAt': FieldValue.serverTimestamp(),
  //     'isRead': false,
  //   });
  // }
  // Future<void> createForAdmins({
  //   required String title,
  //   required String message,
  //   String? excludeStaffId,
  // }) async {
  //   try {
  //     // Fetch all admin users
  //     final snapshot = await FirestorePath.companyCollection('STAFF')
  //         .where('staffType', isEqualTo: 'Admin')
  //         .get();

  //     for (final doc in snapshot.docs) {
  //       final adminId = doc.id;

  //       // Skip if this admin is already the assigned staff (already notified above)
  //       if (excludeStaffId != null &&
  //           excludeStaffId.isNotEmpty &&
  //           adminId == excludeStaffId) {
  //         continue;
  //       }

  //       log('Creating admin notification for: $adminId');
  //       final String id = _generateDateId('NOTIF');
  //       await FirestorePath.companyCollection('NOTIFICATIONS').doc(id).set({
  //         'staffId': adminId,
  //         'title': title,
  //         'message': message,
  //         'createdAt': FieldValue.serverTimestamp(),
  //         'isRead': false,
  //       });
  //       log('Notification saved successfully');
  //     }
  //   } catch (e) {
  //     log('[NotificationRepo] createForAdmins error: $e');
  //   }
  // }
  Stream<List<NotificationModel>> streamByStaff(String staffId) {
    log('Listening for notifications of $staffId');
    return FirestorePath.companyCollection('NOTIFICATIONS')
        .where('staffId', isEqualTo: staffId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) {
            log('Received ${snapshot.docs.length} notifications');
            return snapshot.docs
                .map((doc) => NotificationModel.fromMap(doc.id, doc.data()))
                .toList();
          },
        )
        .handleError((error) { 
          log('[NotificationRepo] streamByStaff error: $error');
        });
  }

  // delete single notification by ID
  Future<void> deleteOne(String notificationId) async {
    await FirestorePath.companyCollection('NOTIFICATIONS').doc(notificationId).delete();
  }

  // delete all notifications for a staff member
  Future<void> deleteAll(String staffId) async {
    final snapshot = await FirestorePath.companyCollection('NOTIFICATIONS')
        .where('staffId', isEqualTo: staffId)
        .get();

    // batch delete for efficiency — Firestore batch limit is 500
    final batches = <WriteBatch>[];
    WriteBatch batch = _db.batch();
    int count = 0;

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
      count++;

      if (count == 500) {
        batches.add(batch);
        batch = _db.batch();
        count = 0;
      }
    }

    if (count > 0) batches.add(batch);

    for (final b in batches) {
      await b.commit();
    }
  }

  Future<void> create({
    required String staffId,
    required String title,
    required String message,
    Map<String, dynamic>? pushData,
  }) async {
    final String id = _generateDateId('NOTIF');
    await FirestorePath.companyCollection('NOTIFICATIONS').doc(id).set({
      'staffId': staffId,
      'title': title,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // Fire the actual push to the recipient's device(s). This is what
    // makes the notification show up on the phone — the Firestore write
    // above only creates the in-app notification-history record.
    final token = await getFcmTokenForStaff(staffId);
    if (token != null && token.isNotEmpty) {
      await PushNotificationApi.sendPush(
        tokens: [token],
        title: title,
        body: message,
        data: {'notificationId': id, ...?pushData},
      );
    } else {
      log('[NotificationRepo] no fcmToken for staff $staffId, skipping push');
    }
  }
Future<void> createForAdmins({
    required String title,
    required String message,
    String? excludeStaffId,
    Map<String, dynamic>? pushData,
  }) async {
    try {
      // Fetch all admin users
      final snapshot = await FirestorePath.companyCollection('STAFF')
          .where('staffType', isEqualTo: 'Admin')
          .get();

      final adminTokens = <String>[];

      for (final doc in snapshot.docs) {
        final adminId = doc.id;

        // Skip if this admin is already the assigned staff (already notified above)
        if (excludeStaffId != null &&
            excludeStaffId.isNotEmpty &&
            adminId == excludeStaffId) {
          continue;
        }

        log('Creating admin notification for: $adminId');
        final String id = _generateDateId('NOTIF');
        await FirestorePath.companyCollection('NOTIFICATIONS').doc(id).set({
          'staffId': adminId,
          'title': title,
          'message': message,
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
        });
        log('Notification saved successfully');

        final token = doc.data()['fcmToken'] as String?;
        if (token != null && token.isNotEmpty) {
          adminTokens.add(token);
        }
      }

      // Batch all admin devices into a single push call.
      if (adminTokens.isNotEmpty) {
        await PushNotificationApi.sendPush(
          tokens: adminTokens,
          title: title,
          body: message,
          data: pushData,
        );
      } else {
        log('[NotificationRepo] no admin fcmTokens found, skipping push');
      }
    } catch (e) {
      log('[NotificationRepo] createForAdmins error: $e');
    }
  }
  Future<String?> getFcmTokenForStaff(String staffId) async {
  final doc = await FirestorePath.companyCollection('STAFF').doc(staffId).get();
  return doc.data()?['fcmToken'] as String?;
}

   // in notification_repo.dart
Future<void> markAllRead(String staffId) async {
  final snapshot = await FirestorePath.companyCollection('NOTIFICATIONS')
      .where('staffId', isEqualTo: staffId)
      .where('isRead', isEqualTo: false)
      .get();

  final batch = _db.batch();
  for (final doc in snapshot.docs) {
    batch.update(doc.reference, {'isRead': true});
  }
  await batch.commit();
}

}