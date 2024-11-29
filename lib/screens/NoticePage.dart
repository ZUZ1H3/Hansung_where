import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'WriteNoticePage.dart';
import 'package:flutter/material.dart';
import '/NoticePost.dart';
import '/NoticePostCard.dart';
import '../DbConn.dart';

class NoticePage extends StatefulWidget {
  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // 뒤로 가기
                  },
                  child: const Icon(
                    Icons.arrow_back, // 뒤로 가기 아이콘을 Material 디자인 아이콘으로 변경
                    size: 24,
                  ),
                ),
                const Text(
                  '공지사항',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WriteNoticePage()), // 펜 아이콘 클릭 시 WriteNoticePage로 이동
                    );
                  },
                  child: Image.asset(
                    'assets/icons/ic_pen.png',
                    width: 18,
                    height: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildNoticePostList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticePostList() {
    return FutureBuilder<List<NoticePost>>(
      future: DbConn.fetchNoticePosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: \${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('공지사항이 없습니다.'));
        } else {
          List<NoticePost> noticePosts = snapshot.data!;

          return ListView.builder(
            itemCount: noticePosts.length,
            itemBuilder: (context, index) {
              return NoticePostCard(
                noticePost: noticePosts[index],
              );
            },
          );
        }
      },
    );
  }
}
