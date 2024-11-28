class Post {
  final int postId;
  final String title;
  final String body;
  final String createdAt;
  final int userId;
  final String? imageUrl1;
  final String? imageUrl2;
  final String? imageUrl3;
  final String? imageUrl4;
  final String? place;
  final String? thing;

  Post({
    required this.postId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.userId,
    this.imageUrl1,
    this.imageUrl2,
    this.imageUrl3,
    this.imageUrl4,
    this.place,
    this.thing,
  });

  // 장소와 물건 중 선택된 키워드만 리스트에 추가
  List<String> get keywords => [
    if (place != null) place!,
    if (thing != null) thing!,
  ];

  /// url 존재하는 이미지만 리스트에 추가
  List<String> get images => [
    if (imageUrl1 != null) imageUrl1!,
    if (imageUrl2 != null) imageUrl2!,
    if (imageUrl3 != null) imageUrl3!,
    if (imageUrl4 != null) imageUrl4!,
  ];
}
