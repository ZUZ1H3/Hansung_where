import 'dart:convert';

import 'package:flutter/material.dart';
import '../local_push_notification.dart';
import '../theme/colors.dart';
import 'WriteNoticePage.dart';
import '/NoticePost.dart';
import '/NoticePostCard.dart';
import '../DbConn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoticePage extends StatefulWidget {
  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  SharedPreferences? prefs;
  String currentUserId = ""; // 현재 접속 중인 사용자 ID
  int savedNoticeCount = 0; // 저장된 공지사항 개수

  @override
  void initState() {
    super.initState();
    _initPref();
  }

  // SharedPreferences 초기화
  Future<void> _initPref() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs?.getString('studentId') ?? "";
      savedNoticeCount = prefs?.getInt('notice_count') ?? 0; // 저장된 공지사항 개수 불러오기
    });
    _checkForNewNotices(); // 새 공지사항 확인
  }

  // 새 공지사항 확인
  Future<void> _checkForNewNotices() async {
    try {
      final noticePosts = await DbConn.fetchNoticePosts();

      if (noticePosts.length > savedNoticeCount) {

        final newNotification = {
          'type': 'notice',
          'title': '공지사항',
          'content': '새로운 공지사항이 올라왔어요',
          'date': _getCurrentDateTime(),
        };

        // 저장된 알림 내역 업데이트
        await _saveNotification(newNotification);

        // 새 공지사항 알림 전송
        await LocalPushNotifications.showSimpleNotification(
          title: "새로운 공지사항",
          body: "공지사항이 새로 추가되었습니다.",
          payload: "", // 페이로드
        );

        // 새 공지사항 개수 저장
        await prefs?.setInt('notice_count', noticePosts.length);
        savedNoticeCount = noticePosts.length; // 로컬 변수 업데이트
      }
    } catch (e) {
      print("Error checking new notices: $e");
    }
  }

  Future<void> _saveNotification(Map<String, dynamic> notification) async {
    final prefs = await SharedPreferences.getInstance();
    final savedNotifications = prefs.getString('notifications') ?? '[]';
    final List<Map<String, dynamic>> notifications =
    List<Map<String, dynamic>>.from(json.decode(savedNotifications));

    notifications.insert(0, notification); // 최신 알림을 맨 앞에 추가
    await prefs.setString('notifications', json.encode(notifications));
  }

  String _getCurrentDateTime() {
    final now = DateTime.now();
    return "${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }



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
                currentUserId == "0000"
                ? GestureDetector(
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
                  )
                : SizedBox(width: 30),
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
