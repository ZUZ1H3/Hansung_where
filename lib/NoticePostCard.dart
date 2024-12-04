import 'package:flutter/material.dart';
import 'theme/colors.dart';
import 'NoticePost.dart';
import 'DbConn.dart';
import 'package:hansung_where/screens/NoticePostPage.dart';

class NoticePostCard extends StatelessWidget {
  final NoticePost noticePost;
  final bool showTitle; // 카드 내부에 "공지사항" 타이틀을 표시할지 여부
  final bool isForHomePage; // HomePage 여부에 따른 스타일 구분

  const NoticePostCard({
    Key? key,
    required this.noticePost,
    this.showTitle = false,
    this.isForHomePage = false, // 기본값: NoticePage 스타일
  }) : super(key: key);

  Future<String?> _fetchManagerNickname(int? managerId) async {
    if (managerId == null) return '관리자'; // managerId가 없을 경우 기본값 반환
    return await DbConn.getNickname(managerId.toString());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoticePostPage(noticeId: noticePost.noticeId), // noticePost.noticeId 전달
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isForHomePage ? Color(0xFFFFFEE7) : Colors.white, // 노란 배경 (HomePage) 또는 흰 배경 (NoticePage)
          borderRadius: BorderRadius.circular(12.0), // 둥근 모서리
          border: Border.all(color: const Color(0xFFECECEC), width: 1.5), // NoticePage일 경우 회색 테두리
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTitle) // showTitle이 true일 때만 타이틀 표시
              Text(
                '🚨 공지사항',
                style: const TextStyle(
                  fontFamily: 'Neo',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            if (showTitle) const SizedBox(height: 6.0), // 타이틀 아래 간격 추가

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
            FutureBuilder<String?>(
              future: _fetchManagerNickname(noticePost.managerId),
              builder: (context, snapshot) {
                String managerName = snapshot.data ?? '관리자'; // 기본값: 관리자
                if (snapshot.connectionState == ConnectionState.waiting) {
                  managerName = '';
                }
                return RichText(
                  text: TextSpan(
                    text: '${noticePost.createdAt} | ',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontFamily: 'Neo',
                    ),
                    children: [
                      TextSpan(
                        text: managerName,
                        style: const TextStyle(
                          color: Color(0xFF042D6F), // 관리자 텍스트를 파란색으로 설정
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
