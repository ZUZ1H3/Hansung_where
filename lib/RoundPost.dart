import 'package:flutter/material.dart';
import 'theme/colors.dart';

class RoundPost extends StatelessWidget {
  final String profile; // 프로필 이미지 경로
  final String nickname; // 닉네임
  final String createdAt; // 작성 시간
  final String title; // 제목
  final String body; // 내용
  final int commentCnt; // 댓글 개수
  final List <String> keywords; // 키워드
  final List <String> images; // 이미지

  final bool isNotice; // 공지사항 여부

  const RoundPost({
    required this.profile,
    required this.nickname,
    required this.createdAt,
    required this.title,
    required this.body,
    this.commentCnt = 0, // 기본값 0
    this.keywords = const [], // 기본값 빈 리스트
    this.images = const [], // 기본값 빈 리스트
    this.isNotice = false, // 기본값: 일반 게시물
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15), // 내부 간격
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ColorStyles.borderGrey,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 프로필 이미지
              CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage(profile),
              ),
              SizedBox(width: 8),
              // 닉네임과 시간
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nickname,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    createdAt,
                    style: TextStyle(fontSize: 12, color: Color(0xFF858585)),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          // 제목
          Padding(
            padding: const EdgeInsets.only(left: 5), // 5칸 오른쪽 이동
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300), // 최대 너비
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 2, // 줄 수 제한
              ),
            ),
          ),
          SizedBox(height: 12),
          // 본문
          Padding(
            padding: const EdgeInsets.only(left: 5), // 5칸 오른쪽 이동
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300, maxHeight: 100), // 최대 너비, 높이
              child: SingleChildScrollView(
                child: Text(
                  body,
                  style: TextStyle(fontSize: 12, color: Colors.black, height: 20 / 12),
                ),
              ),
            ),
          ),
          // 이미지
          if (images.isNotEmpty)
            SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.only(right: 5), // 오른쪽으로 5만큼 Padding 추가
            child: Wrap(
              spacing: 10, // 이미지 간 간격
              children: images.map(
                    (url) => Image.network(
                  url,
                  width: 65,
                  height: 65,
                  fit: BoxFit.cover,
                ),
              ).toList(),
            ),
          ),
          SizedBox(height: 12),
          // 댓글 개수 (공지사항이 아닌 경우에만 표시)
          if (!isNotice)
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/ic_comment.png',
                    fit: BoxFit.contain,
                    width: 18,
                    height: 18,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    commentCnt.toString(),
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          SizedBox(height: 12),
          // 키워드
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: keywords
                .map((keyword) => Container(
              padding: EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: Color(0xFFECECEC), // 키워드 배경색
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "#$keyword",
                style: TextStyle(fontSize: 12, color: Color(0xFF858585)),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}