import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../DbConn.dart';
import '../screens/ChattingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> chatList = [];
  int currentStudentId = -1; // 현재 접속 중인 user Id
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    initStudentId();
    loadMessages(); // 초기 데이터 로드
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> initStudentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentStudentId = int.tryParse(prefs.getString('studentId') ?? '') ?? 1;
    });
  }

  // DB에서 메시지 가져오기
  Future<void> loadMessages() async {
    final messages = await DbConn.fetchSamePostMessages(currentStudentId: currentStudentId);

    setState(() { // 최신 메시지가 상단에 위치
      chatList = messages
        ..sort((a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''));
    });
  }

  // 30초 간격으로 재실행
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        loadMessages();
      } else {
        timer.cancel();
      }
    });
  }

  // 이미지 경로
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
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            Row(
              children: [
                const SizedBox(width: 137),
                const Text(
                  '쪽지함',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            // 메시지 리스트
            Expanded(
              child: RefreshIndicator(
                onRefresh: loadMessages, // 새로고침 트리거 시 호출할 함수
                child: ListView.builder(
                  itemCount: chatList.length,
                  itemBuilder: (context, index) {
                    final chat = chatList[index]; // 현재 항목 데이터 가져오기
                    return GestureDetector(
                      onTap: () async {
                        // 타입 변환
                        final postId = int.tryParse(chat['post_id'].toString()) ?? 0;
                        final receiverId = int.tryParse(chat['receiver_id'].toString()) ?? -1;

                        // 메시지 읽음 처리
                        await DbConn.markMessagesAsRead(currentStudentId: currentStudentId, postId: postId);

                        // postTitle 가져오기
                        final postTitle = await DbConn.getPostTitleById(postId: postId);

                        // Navigator로 Chatting 페이지로 이동
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Chatting(
                              postTitle: postTitle ?? '제목 없음', // null 처리
                              receiverNickname: chat['nickname'],
                              postId: postId,
                              receiverId: receiverId,
                            ),
                          ),
                        );

                        // Navigator.pop 이후 새로고침
                        if (result == true) {
                          await loadMessages();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: buildMessageBox(
                          avatar: _getProfileImagePath(
                            int.tryParse(chat['profile']?.toString() ?? '') ?? 1,
                          ),
                          nickname: chat['nickname'] ?? '',
                          message: chat['message'] ?? '',
                          badgeCount: int.tryParse(chat['unread_count']?.toString() ?? '0') ?? 0, // unread_count 전달
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMessageBox({
    required String avatar,
    required String nickname,
    required String message,
    int badgeCount = 0,
  }) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ColorStyles.borderGrey,
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 7, left: 4), // 프로필 위치 조정
            child: CircleAvatar(
              backgroundImage: AssetImage(avatar),
              radius: 27.5,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 9), // 제목 위치 조정
                  child: Text(
                    nickname,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: 215, // 메시지 최대 넓이
                  ),
                  child: Text(
                    message,
                    style: TextStyle(fontSize: 12, color: Colors.black),
                    maxLines: 2, // 최대 2줄
                    overflow: TextOverflow.ellipsis, // 줄임표 처리
                  ),
                ),
              ],
            ),
          ),
          if (badgeCount > 0)
            Container(
              width: 20, // 고정된 너비와 높이로 원형 생성
              height: 20,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle, // 원형 모양
              ),
              alignment: Alignment.center, // 텍스트를 중앙 정렬
              child: Text(
                '$badgeCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
