enum ActivityType {
  transfer,
  followupUpdate,
  statusChange,
  schedule,
  leadCreated,
}

class ActivityModel {
  final String staffName;
  final String activityText;
  final String date;
  final ActivityType type;

  const ActivityModel({
    required this.staffName,
    required this.activityText,
    required this.date,
    required this.type,
  });
}
