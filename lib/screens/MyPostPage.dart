import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../DbConn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../PostCard.dart';
import '../Post.dart';

class MyPost extends StatefulWidget {
  @override
  _MyPostState createState() => _MyPostState();
}

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

class _MyPostState extends State<MyPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '내 게시글',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Post>>(
        future: _fetchPosts(), // 게시물 가져오기
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // 로딩 중
          } else if (snapshot.hasError) {
            return Center(
              child: Text('오류 발생: ${snapshot.error}'),
            ); // 오류 처리
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('게시물이 없습니다.'), // 게시물이 없을 때 메시지
            );
          } else {
            final posts = snapshot.data!; // 게시물 데이터 가져오기
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostCard(
                  post: posts[index],
                  type: '55', // 사용자의 게시물 타입 전달
                );
              },
            );
          }
        },
      ),
    );
  }
}
