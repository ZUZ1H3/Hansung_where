class NoticePost {
  final int noticeId;
  final String title;
  final String body;
  final String createdAt;
  final int? managerId;

  NoticePost({
    required this.noticeId,
    required this.title,
    required this.body,
    required this.createdAt,
    this.managerId,
  });
}
