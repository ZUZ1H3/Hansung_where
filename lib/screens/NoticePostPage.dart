import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../DbConn.dart';
import '../RoundPost.dart';

class NoticePostPage extends StatefulWidget {
  final int noticeId;

  const NoticePostPage({required this.noticeId, Key? key}) : super(key: key);

  @override
  _NoticePostPageState createState() => _NoticePostPageState();
}

class _NoticePostPageState extends State<NoticePostPage> {
  Future<Map<String, dynamic>?> noticeFuture = Future.value(null);
  String managerNickname = ""; // 관리자 닉네임
  String profilePath = ""; // 프로필 이미지 경로

  @override
  void initState() {
    super.initState();
    noticeFuture = _fetchNoticeData();
  }

  Future<Map<String, dynamic>?> _fetchNoticeData() async {
    try {
      // 공지사항 데이터 가져오기
      final noticeData = await DbConn.getNoticePostById(widget.noticeId);

      // 관리자 ID로 닉네임 및 프로필 이미지 경로 가져오기
      if (noticeData != null) {
        final managerId = noticeData['manager_id']?.toString() ?? "";

        if (managerId.isNotEmpty) {
          final nickname = await DbConn.getNickname(managerId);
          final profileId = await DbConn.getProfileId(managerId);
          final profileImage = _getProfileImagePath(profileId);

          setState(() {
            managerNickname = nickname ?? "관리자";
            profilePath = profileImage;
          });
        }
      }

      return noticeData;
    } catch (e) {
      print("Error fetching notice data: $e");
      return null;
    }
  }

  String _getProfileImagePath(int profileId) {
    switch (profileId) {
      case 1:
        return 'assets/icons/ic_boogi.png';
      case 2:
        return 'assets/icons/ic_kkukku.png';
      case 3:
        return 'assets/icons/ic_kkokko.png';
      case 4:
        return 'assets/icons/ic_sangzzi.png';
      case 5:
        return 'assets/icons/ic_nyang.png';
      default:
        return 'assets/icons/ic_boogi.png'; // 기본 이미지
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              // 상단 바
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양 끝 정렬
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      'assets/icons/ic_back.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const Text(
                    '🚨 공지사항 🚨',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 24),
                ],
              ),

              const SizedBox(height: 20),

              // 공지사항 본문
              FutureBuilder<Map<String, dynamic>?>(
                future: noticeFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text('공지사항을 찾을 수 없습니다.'));
                  }

                  final noticeData = snapshot.data!;
                  final title = noticeData['title'] ?? '제목 없음';
                  final body = noticeData['body'] ?? '내용 없음';
                  final createdAt = noticeData['created_at'] ?? '날짜 없음';

                  return Column(
                    children: [
                      RoundPost(
                        profile: profilePath,
                        nickname: managerNickname,
                        displayTime: createdAt,
                        title: title,
                        body: body,
                        isNotice: true, // 공지사항 플래그
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
