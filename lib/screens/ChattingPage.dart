import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import '../DbConn.dart';
import '../SenderChat.dart';
import '../ReceiverChat.dart';
import '../Message.dart';

class Chatting extends StatefulWidget {
  final String postTitle;
  final String receiverNickname;
  final int postId;
  final int receiverId;

  // 생성자를 통해 속성 초기화
  const Chatting(
      {required this.postTitle, required this.receiverNickname, required this.postId, required this.receiverId, Key? key})
      : super(key: key);

  @override
  _ChattingState createState() => _ChattingState();
}

class _ChattingState extends State<Chatting> {
  final TextEditingController _messageController = TextEditingController(); // 입력 필드 컨트롤러
  final FocusNode _focusNode = FocusNode();
  bool hasFocus = false;
  bool _isVisble = true;
  final String createdAt = "";
  late List<Message> _chatMessages = []; // 채팅 메시지 저장
  SharedPreferences? prefs;
  late String currentUserId; // 현재 접속 중인 사용자 ID
  String _latestDate = "";   // 최신 채팅 날짜
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    _initPref();
    _loadInitialData();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isVisble = false;
      });
    });
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _fetchMessages(),
      _fetchLatestDate(),
    ]);
  }

  // SharedPreferences 초기화
  Future<void> _initPref() async {
    prefs = await SharedPreferences.getInstance();
    currentUserId = prefs?.getString('studentId') ?? "";
  }

  @override
  void dispose() {
    _isDisposed = true; // State가 폐기되었음을 표시
    _focusNode.removeListener(_onFocusChanged); // 리스너 제거
    _focusNode.dispose(); // FocusNode 정리
    _messageController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      hasFocus = _focusNode.hasFocus; // 포커스 상태 업데이트
    });
  }

  // 최신 날짜 불러오기
  Future<void> _fetchLatestDate() async {
    final latestDate = await DbConn.fetchCreatedAtMessages(postId: widget.postId);

    // 현재 날짜 가져오기
    final currentDate = DateTime.now();
    final formattedCurrentDate =
        "${currentDate.year}.${currentDate.month.toString().padLeft(2, '0')}.${currentDate.day.toString().padLeft(2, '0')}";

    setState(() {
      _latestDate = latestDate ?? formattedCurrentDate; // 최신 날짜가 없으면 현재 날짜 사용
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),
                Row(
                  children: [
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // 뒤로 가기
                      },
                      child: const ImageIcon(
                        AssetImage('assets/icons/ic_back.png'),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.receiverNickname,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 30), // 오른쪽 공간 유지
                  ],
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  // 좌우 패딩 추가
                  width: 340,
                  height: 75,
                  // 박스 높이
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ColorStyles.borderGrey, // 테두리 색상
                      width: 1, // 테두리 두께
                    ),
                  ),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${widget.postTitle} ", // 제목
                            style: const TextStyle(
                              fontSize: 14,
                              color: ColorStyles.mainBlue, // postTitle의 색상
                              fontWeight: FontWeight.bold, // bold로 설정
                            ),
                          ),
                          TextSpan(
                            text: "게시물에서 시작된 채팅입니다.", // 나머지 텍스트
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black, // 기본 텍스트 색상
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(seconds: 1), // 애니메이션 지속 시간
                  transitionBuilder: (Widget child,
                      Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _isVisble
                      ? Center(
                    child: IntrinsicWidth(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10), // 좌우 10의 패딩 추가
                        height: 30,  // 고정된 높이
                        decoration: BoxDecoration(
                          color: ColorStyles.mainBlue,
                          borderRadius: BorderRadius.circular(12), // 둥근 모서리
                        ),
                        child: Center(
                          child: Text(
                            _latestDate,
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  )
                      : const SizedBox.shrink(), // 공간을 완전히 없애기
                ),
              ],
            ),
          ),
          // 채팅 영역
          Expanded(
            child: ListView.builder(
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final chat = _chatMessages[index];
                final isSender = chat.senderId.toString() == currentUserId;

                // profileId를 결정
                final profileId = (isSender)
                    ? int.tryParse(chat.receiverProfileId ?? '1') ?? 1
                    : int.tryParse(chat.senderProfileId ?? '1') ?? 1;

                return isSender
                    ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                  child: SenderChat(
                    message: chat.message,
                    createdAt: chat.createdAt,
                  ),
                )
                    : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                  child: ReceiverChat(
                    message: chat.message,
                    createdAt: chat.createdAt,
                    showProfile: true,
                    profileImage: _getProfileImagePath(profileId),
                  ),
                );
              },
            ),
          ),
          // 댓글 입력 필드
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 100, // 최대 높이 설정
                    ),
                    child: Scrollbar( // 스크롤바 추가
                      child: SingleChildScrollView(
                        child: TextField(
                          controller: _messageController,
                          focusNode: _focusNode,
                          maxLines: null, // null로 설정하면 줄바꿈에 따라 자동으로 늘어남
                          minLines: 1, // 최소 줄 수
                          keyboardType: TextInputType.multiline, // 여러 줄 입력 가능
                          decoration: InputDecoration(
                            hintText: '댓글을 입력하세요',
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ), // 텍스트 필드 내부 패딩
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: ColorStyles.borderGrey, // 테두리 색상 설정
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: ColorStyles.mainBlue, // 클릭(포커스) 시 테두리 색상 변경
                                width: 1.5,
                              ),
                            ),
                          ),
                          style: const TextStyle(fontSize: 14), // 텍스트 스타일 설정
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    String newMessage = _messageController.text.trim();
                    if (newMessage.isNotEmpty) {
                      _addComment(newMessage);
                      _messageController.clear();
                    }
                  },
                  child: Image.asset(
                    'assets/icons/ic_send.png',
                    width: 24,
                    height: 24,
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

  // 메시지 추가하기
  void _addComment(String body) async {
    try {
      bool success = await DbConn.saveMessage(
        senderId: int.parse(currentUserId),
        receiverId: widget.receiverId,
        postId: widget.postId,
        message: body,
      );

      if (success) {
        _messageController.clear();
        _fetchMessages();
        print("댓글 저장 성공");
      } else {
        print("댓글 저장 실패");
      }
    } catch (e) {
      print("댓글 저장 오류: \$e");
    }
  }

  // 메시지 가져오기
  Future<void> _fetchMessages() async {
    try {
      final fetchedMessages = await DbConn.fetchMessages(postId: widget.postId);

      if (!_isDisposed) {
        setState(() {
          _chatMessages = fetchedMessages;
        });
      }
    } catch (e) {
      print('채팅 메시지 가져오기 오류: $e');
    }
  }

  // 프로필 ID에 따른 이미지 경로 반환
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
}
