import 'package:flutter/material.dart';
import '../DbConn.dart';
import '../PostCard.dart';
import '../Post.dart';

class MyComment extends StatefulWidget {
  final int userId; // 현재 사용자의 ID
  final String postType; // 게시물의 유형

  const MyComment({required this.userId, required this.postType, Key? key}) : super(key: key);

  @override
  _MyCommentState createState() => _MyCommentState();
}

enum SortOption { newest, oldest } // 정렬 기준: 최신순, 오래된 순

class _MyCommentState extends State<MyComment> {
  late Future<List<Post>> _postsFuture;
  SortOption _sortOption = SortOption.newest; // 기본 정렬 옵션: 최신순

  @override
  void initState() {
    super.initState();
    // 댓글 단 게시물 가져오기
    _postsFuture = _fetchPostsWithMyComments();
  }

  /// 댓글 단 게시물 가져오기
  Future<List<Post>> _fetchPostsWithMyComments() async {
    try {
      return await DbConn.fetchPostsWithMyComments(
        userId: widget.userId,
        postType: widget.postType,
      );
    } catch (e) {
      print("Error fetching posts with my comments: $e");
      return [];
    }
  }

  List<Post> _sortPosts(List<Post> posts) {
    if (_sortOption == SortOption.newest) {
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 최신순
    } else if (_sortOption == SortOption.oldest) {
      posts.sort((a, b) => a.createdAt.compareTo(b.createdAt)); // 오래된 순
    }
    return posts;
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
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // 뒤로 가기
                  },
                  child: const ImageIcon(
                    AssetImage('assets/icons/ic_back.png'),
                  ),
                ),
                const SizedBox(width: 98),
                const Text(
                  '댓글 단 글',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10), // "댓글 단 글"과 정렬 버튼 사이의 여백
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(), // 최소 크기 제한 제거
                  icon: const Icon(Icons.sort, size: 18),
                  onPressed: () {
                    setState(() {
                      // 정렬 옵션 변경
                      _sortOption = _sortOption == SortOption.newest
                          ? SortOption.oldest
                          : SortOption.newest;
                    });
                  },
                ),
                Text(
                  '${_sortOption == SortOption.newest ? "오래된 순" : "최신 순"}',
                  style: const TextStyle(fontSize: 14, color: Colors.black, fontFamily: 'Neo'),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height - 150, // 화면 높이에 맞게 설정
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
                    final posts = _sortPosts(snapshot.data!); // 정렬된 게시물
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
