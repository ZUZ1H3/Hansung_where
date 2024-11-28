class Post {
  final String title;
  final String body;
  final String createdAt;
  final String? imageUrl1;
  final String? place;
  final String? thing;

  Post({
    required this.title,
    required this.body,
    required this.createdAt,
    this.imageUrl1,
    this.place,
    this.thing,
  });
}
