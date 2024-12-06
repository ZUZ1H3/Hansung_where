import 'package:flutter/material.dart';
import '../DbConn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../PostCard.dart';
import '../Post.dart';

// userId를 가져옴
Future<int> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  final studentId = prefs.getString('studentId');
  return int.tryParse(studentId ?? '') ?? 0; // 기본값 설정
}

// 사용자의 게시물을 가져오는 함수
Future<List<Post>> _fetchPosts() async {
  try {
    final userId = await getUserId(); // 비동기로 userId 가져오기
    return await DbConn.fetchMyPosts(
      userId: userId, // 가져온 userId 전달
    );
  } catch (e) {
    print("Error fetching posts with my comments: $e");
    return [];
  }
}

class MyPost extends StatefulWidget {
  @override
  _MyPostState createState() => _MyPostState();
}

enum SortOption { newest, oldest } // 정렬 기준: 최신순, 오래된 순

class _MyPostState extends State<MyPost> {
  SortOption _sortOption = SortOption.newest;

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
                const SizedBox(width: 100),
                const Text(
                  '내 게시글',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    constraints: const BoxConstraints(), // 최소 크기 제한 제거
                    icon: const Icon(Icons.sort, size: 18), // 아이콘 크기 설정
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
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height - 150, // 화면 높이에 맞게 설정
              child: FutureBuilder<List<Post>>(
                future: _fetchPosts(), // 게시물 가져오기
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    ); // 로딩 중
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('오류 발생: ${snapshot.error}'),
                    ); // 오류 처리
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('게시물이 없습니다.'), // 게시물이 없을 때 메시지
                    );
                  } else {
                    final posts = _sortPosts(snapshot.data!); // 정렬된 게시물
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 5), // 상하단 여백 최소화
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5), // 게시물 간 여백 조정
                          child: PostCard(
                            post: posts[index],
                            type: '55', // 사용자의 게시물 타입 전달
                          ),
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
