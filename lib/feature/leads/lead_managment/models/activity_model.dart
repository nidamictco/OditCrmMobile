import 'package:cloud_firestore/cloud_firestore.dart';

class LeadStaffHandler {
  final String staffId;
  final String staffName;
  final String phone;         // from STAFF collection lookup
  final int activityCount;    // number of follow-ups they created
  final bool isCurrentAssignee;

  const LeadStaffHandler({
    required this.staffId,
    required this.staffName,
    required this.phone,
    required this.activityCount,
    required this.isCurrentAssignee,
  });
}

class FollowupEntry {
  final String date;
  final String time;
  final String agent;
  final String calledDate;
  final String callStatus;
  final String tags;
  final String remark;
  final String status;
  final String products;

  const FollowupEntry({
    required this.date,
    required this.time,
    required this.agent,
    required this.calledDate,
    required this.callStatus,
    required this.tags,
    required this.remark,
    required this.status,
    required this.products,
  });
}

class ActivityEntry {
  final String agent;
  final String description;
  final String dateTime;

  const ActivityEntry({
    required this.agent,
    required this.description,
    required this.dateTime,
  });
}


enum ActivityType {
  leadCreated,
  statusChanged,
  followupAdded,
  categoryChanged,
  priorityChanged,
  staffAssigned,
  costUpdated,
  remarkUpdated,
  leadDeleted,
  unknown,
  followupDeleted,
}

class ActivityModel {
  final String id;
  final ActivityType type;
  final String changedBy;      
  final String changedById;
  final DateTime changedAt;
  final String? previousValue;
  final String? newValue;
  final String description; 
  final String? leadId;
  final String? leadName;
  final String? leadPhone;
    

  const ActivityModel({
    required this.id,
    required this.type,
    required this.changedBy,
    required this.changedById,
    required this.changedAt,
    this.previousValue,
    this.newValue,
    required this.description,
    this.leadId,
    this.leadName,
    this.leadPhone,
  });

  factory ActivityModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ActivityModel(
      id: id,
      type: _parseType(data['type'] as String? ?? ''),
      changedBy: data['changedBy'] as String? ?? '',
      changedById: data['changedById'] as String? ?? '',
      changedAt: (data['changedAt'] as Timestamp).toDate(),
      previousValue: data['previousValue'] as String?,
      newValue: data['newValue'] as String?,
      description: data['description'] as String? ?? '',
      leadId: data['leadId'] as String?,
      leadName: data['leadName'] as String?,
      leadPhone: data['leadPhone'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'type': type.name,
    'changedBy': changedBy,
    'changedById': changedById,
    'changedAt': Timestamp.fromDate(changedAt),
    'previousValue': previousValue,
    'newValue': newValue,
    'description': description,
    'leadId':leadId,
    'leadName': leadName,
    'leadPhone': leadPhone,
  };

  static ActivityType _parseType(String raw) {
    return ActivityType.values.firstWhere(
          (e) => e.name == raw,
      orElse: () => ActivityType.unknown,
    );
  }
}


class LeadCategoryTableRow {
  final String category;
  final int newCount;
  final int followUpCount;
  final int rejectedCount;
  final int closedCount;

  const LeadCategoryTableRow({
    required this.category,
    this.newCount = 0,
    this.followUpCount = 0,
    this.rejectedCount = 0,
    this.closedCount = 0,
  });
}
