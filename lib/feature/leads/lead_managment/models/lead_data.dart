import 'package:flutter/material.dart';

class LeadData {
  final String id;
  final String name;
  final String phone;
  final String assignedTo;
  final String category;
  final String source;
  final String priority;
  final String status;
  final int notificationCount;
  bool isExpanded;
  final DateTime? createdAt;

  LeadData({
    required this.id,
    required this.name,
    required this.phone,
    required this.assignedTo,
    required this.category,
    required this.status,
    required this.notificationCount,
    required this.source,
    required this.priority,
    this.isExpanded = true,
    this.createdAt,
  });
}
