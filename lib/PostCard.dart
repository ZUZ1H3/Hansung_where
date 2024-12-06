import 'package:flutter/material.dart';
import 'package:hansung_where/screens/PostPage.dart';
import 'Post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final String type;
  final bool isForMapPage; // HomePage 여부에 따른 스타일 구분

  const PostCard({
    Key? key,
    required this.post,
    required this.type,
    this.isForMapPage = false, // 기본값: NoticePage 스타일
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostPage(
              post_id: post.postId, // postId 전달
              type: type,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white, // 카드 배경을 흰색으로 설정
          borderRadius: BorderRadius.circular(12.0), // 둥근 모서리
          border:
              Border.all(color: const Color(0xFFECECEC), width: 1.5), // 테두리 설정
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 텍스트와 태그를 포함한 왼쪽 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Row(
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Neo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isForMapPage && _isNew(post.createdAt))
                        Container(
                          margin: const EdgeInsets.only(left: 8.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 2.0),

                          child: const Text(
                            'new',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFE46060),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Neo',
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8.0),

                  // 태그 (장소 및 사물)
                  Wrap(
                    spacing: 8.0,
                    children: [
                      if (post.place != null)
                        _buildTag('#${post.place}'), // 장소 태그
                      if (post.thing != null)
                        _buildTag('#${post.thing}'), // 사물 태그
                    ],
                  ),
                  const SizedBox(height: 8.0),

                  // 작성 시간 및 추가 정보
                  Text(
                    '${post.displayTime} | 학생',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontFamily: 'Neo',
                    ),
                  ),
                ],
              ),
            ),

            // 오른쪽 이미지 (이미지가 있을 때만 표시)
            if (post.imageUrl1 != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  post.imageUrl1!,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink(); // 이미지 로딩 실패 시 숨기기
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
  bool _isNew(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt).inDays;
    return difference <= 7; // 7일 이내일 때 true 반환
  }

  /// 태그 스타일
  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC), // 태그 배경색
        borderRadius: BorderRadius.circular(50), // 완전한 원형 모양
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF7F7F7F),
          fontFamily: 'Neo', // 네오 폰트
        ),
      ),
    );
  }
}
