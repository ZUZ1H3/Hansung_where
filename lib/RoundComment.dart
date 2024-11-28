import 'package:flutter/material.dart';
import 'theme/colors.dart';

class RoundComment extends StatelessWidget {
  final int id;                // 댓글 ID
  final int postId;            // 게시글 ID
  final int userId;            // 작성자 ID
  final String body;           // 내용
  final String createdAt;      // 작성 시간
  final String type;           // 유형 (댓글 or 답글)
  final int? parentCommentId;  // 상위 댓글 ID, 최상위 댓글일 경우 null
  final bool isReplyMode;      // 외부에서 전달된 댓글 모드 상태
  final Function() onReplyClick; // 댓글 버튼 클릭시 실행될 함수

  const RoundComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
    required this.body,
    required this.type,
    this.parentCommentId,
    required this.isReplyMode,     // 상태값 전달
    required this.onReplyClick,    // 상태 변경 함수 전달
  });

  // 가짜 이름 조회 함수 (DB에서 가져오는 함수로 대체 가능)
  Future<String> getUsernameById(int userId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return "작성자_$userId"; // 예: 작성자_1, 작성자_2
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isReplyMode ? ColorStyles.mainBlue : ColorStyles.borderGrey, // 외부 상태에 따른 border 색상
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: FutureBuilder<String>(
              future: getUsernameById(userId), // 작성자 이름 가져오기
              builder: (context, snapshot) {
                return Padding(
                  padding: const EdgeInsets.only(left: 5), // 오른쪽으로 5만큼 이동
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 3), // 아래로 3만큼 이동
                            child: Text(
                              snapshot.data ?? "",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // 댓글 내용 (스크롤 가능)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 120, // 최대 높이
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text(
                            body,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              height: 20 / 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 작성 시간
                      Text(
                        createdAt,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF858585),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // 오른쪽에 점 버튼과 댓글 버튼을 고정
          Padding(
            padding: const EdgeInsets.only(top: 3), // 아래로 3만큼 이동
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onReplyClick,
                  child: Image.asset(
                    'assets/icons/ic_comment.png',
                    width: 18,
                    height: 18,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 3), // 점 버튼과 댓글 버튼 사이 간격
                GestureDetector(
                  onTap: () {
                    print("댓글 버튼 클릭");
                  },
                  child: Image.asset(
                    'assets/icons/ic_dots.png', // 댓글 버튼 이미지
                    width: 18,
                    height: 18,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
