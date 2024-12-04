class Report {
  final int id;
  final int userId;
  final int reportId;
  final String reason;
  final String reportedAt;
  final String type;

  Report({
    required this.id,
    required this.userId,
    required this.reportId,
    required this.reason,
    required this.reportedAt,
    required this.type,
  });
}
