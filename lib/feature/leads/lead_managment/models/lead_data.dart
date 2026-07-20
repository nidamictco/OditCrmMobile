import 'package:flutter/material.dart';

class LeadData {
  final String id;
  final String name;
  final String phone;
  final String assignedTo;
  final String category;
  final String subCategory;
  final String categoryId;
  final String subCategoryId;
  final String source;
  final String sourceId;
  final String priority;

  // Business stage code (NEW / FOLLOWUP / TRANSFERRED / CLOSED, etc).
  // LeadFilter and every existing filtering/counting rule reads THIS field.
  // Never localize or humanize this one.
  final String status;

  // NEW — human-readable Lead Stage name for UI display only
  // (e.g. "Follow Up" instead of "FOLLOWUP"). Falls back to `status`
  // when empty, so any existing call site that doesn't pass it keeps working.
  final String statusName;

  final String statusId;
  final int notificationCount;
  bool isExpanded;
  final DateTime? createdAt;

  LeadData({
    required this.id,
    required this.name,
    required this.phone,
    required this.assignedTo,
    required this.category,
    required this.categoryId,
    required this.subCategory,
    required this.subCategoryId,
    required this.status,
    this.statusName = '', // NEW — optional, defaults so old call sites don't break
    required this.statusId,
    required this.notificationCount,
    required this.source,
    required this.sourceId,
    required this.priority,
    this.isExpanded = true,
    this.createdAt,
  });

  // NEW — convenience getter: always resolves to something displayable.
  String get displayStatus => statusName.isEmpty ? status : statusName;
}