class TargetReportModel {
  final String id;
  final String groupName;
  final double targetAmount;
  final double achievedAmount;
  final String fromDate;
  final String toDate;

  const TargetReportModel({
    required this.id,
    required this.groupName,
    required this.targetAmount,
    required this.achievedAmount,
    required this.fromDate,
    required this.toDate,
  });
}
