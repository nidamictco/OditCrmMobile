class DashboardCountModel {
  final int newLeadCount;
  final int followUpCount;
  final int closedLeadCount;
  final int totalCalledCount;
  final int missedLeadCount;
  final int transferredCount;

  const DashboardCountModel({
    required this.newLeadCount,
    required this.followUpCount,
    required this.closedLeadCount,
    required this.totalCalledCount,
    required this.missedLeadCount,
    required this.transferredCount,
  });
}