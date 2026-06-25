import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String staffId;
  final String title;
  final String message;
  final DateTime? createdAt; // nullable — server timestamp can be null briefly
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.staffId,
    required this.title,
    required this.message,
    this.createdAt,
    required this.isRead,
  });

  Map<String, dynamic> toMap() {
    return {
      'staffId': staffId,
      'title': title,
      'message': message,
      'createdAt': createdAt,
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      staffId: map['staffId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(), // safe null check
      isRead: map['isRead'] ?? false,
    );
  }
}