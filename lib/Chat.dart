class Message {
  final int messageId;         // 채팅 ID
  final int senderId;          // 사용자 ID
  final int receiverId;        // 대화 사용자 ID
  final int postId;            // 해당 게시물 ID
  final String message;        // 내용
  final String createdAt;      // 작성 시간
  final String? senderProfileId;    // sender 의 프로필 id 값
  final String? receiverProfileId;  // receiver 의 프로필 id 값

  // 생성자
  Message({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.postId,
    required this.message,
    required this.createdAt,
    this.senderProfileId,
    this.receiverProfileId,
  });
}
