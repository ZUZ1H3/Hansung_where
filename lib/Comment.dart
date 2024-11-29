class Comment {
  final int id;                // 댓글 ID
  final int postId;            // 게시글 ID
  final int userId;            // 작성자 ID
  final String body;           // 내용
  final String createdAt;      // 작성 시간
  final String type;           // 유형 (댓글 or 답글)
  final int? parentCommentId;  // 상위 댓글 ID, 최상위 댓글일 경우 null

  // 생성자
  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.body,
    required this.createdAt,
    required this.type,
    this.parentCommentId,
  });
}
