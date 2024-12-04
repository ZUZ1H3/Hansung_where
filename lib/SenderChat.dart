import 'package:flutter/material.dart';
import 'theme/colors.dart';

class SenderChat extends StatelessWidget {
  final String message; // 메시지 내용
  final String createdAt; // 메시지 시간

  const SenderChat({
    required this.message,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end, // 전체를 오른쪽 정렬
      children: [
        // 시간 표시
        Padding(
          padding: const EdgeInsets.only(top: 20, right: 2), // 시간과 메시지 간격
          child: Text(
            createdAt, // 메시지 시간
            style: const TextStyle(
              color: Color(0xFF858585),
              fontSize: 12,
            ),
          ),
        ),
        // 메시지 박스
        Flexible(
          child: IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), // 상하좌우 10의 패딩 추가
              constraints: BoxConstraints(
                maxWidth: 200,
                minHeight: 30, // 최소 높이 설정
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10), // 둥근 모서리
                border: Border.all(
                  color: ColorStyles.borderGrey, // 테두리 색상
                  width: 1, // 테두리 두께
                ),
              ),
              child: Center(
                child: Text(
                  message, // 메시지 내용 표시
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
