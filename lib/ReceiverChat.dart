import 'package:flutter/material.dart';
import 'theme/colors.dart';

class ReceiverChat extends StatelessWidget {
  final String message;      // 메시지 내용
  final String createdAt;    // 메시지 시간
  final bool showProfile;    // 프로필 이미지 표시 여부
  final String profileImage; // 프로필 이미지 경로

  ReceiverChat({
    required this.message,
    required this.createdAt,
    required this.showProfile,
    required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 프로필 이미지
        if (showProfile)
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(profileImage),
          )
        else
          const SizedBox(width: 22), // 프로필 이미지를 생략할 때 여백 유지

        const SizedBox(width: 8), // 프로필과 메시지 사이 간격 추가
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
                  message, // 메시지 표시
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
        ),

        // 시간 표시
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 2), // 메시지와 시간 간격
          child: Text(
            createdAt, // 메시지 시간
            style: const TextStyle(
              color: Color(0xFF858585),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
