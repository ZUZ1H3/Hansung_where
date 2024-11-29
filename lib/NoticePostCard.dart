import 'package:flutter/material.dart';
import 'theme/colors.dart';
import 'NoticePost.dart';

class NoticePostCard extends StatelessWidget {
  final NoticePost noticePost;

  const NoticePostCard({Key? key, required this.noticePost}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {

      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white, // 카드 배경을 흰색으로 설정
          borderRadius: BorderRadius.circular(12.0), // 둥근 모서리
          border: Border.all(color: const Color(0xFFECECEC), width: 1.5), // 테두리 설정
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              noticePost.title,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Neo',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),

            // 작성 시간 및 추가 정보
            Text(
              '${noticePost.createdAt} | 관리자',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontFamily: 'Neo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
