import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../DbConn.dart';
import '../PostCard.dart';
import '../Post.dart';

class MyComment extends StatefulWidget {
  final int userId; // 현재 사용자의 ID
  final String postType; // 게시물의 유형 (예: "found" 또는 "lost")
  const MyComment({required this.userId, required this.postType, Key? key}) : super(key: key);

  @override
  _MyCommentState createState() => _MyCommentState();
}

class _MyCommentState extends State<MyComment> {
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    // 댓글 단 게시물 가져오기
    _postsFuture = DbConn.fetchPostsWithMyComments(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // 뒤로 가기
                  },
                  child: const ImageIcon(
                    AssetImage('assets/icons/ic_back.png'),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  '댓글 단 글',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Post>>(
                future: _postsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('오류: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('댓글 단 게시물이 없습니다.'));
                  } else {
                    final posts = snapshot.data!;
                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return PostCard(
                          post: posts[index],
                          type: widget.postType, // 외부에서 전달된 type 사용
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
