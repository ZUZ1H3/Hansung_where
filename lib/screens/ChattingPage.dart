import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../DbConn.dart';

class Chatting extends StatefulWidget {
  final String receiverNickname; // 메시지를 전달받는 사용자 이름
  final String postTitle; // 시작된 게시물

  // 생성자를 통해 속성 초기화
  const Chatting(
      {required this.receiverNickname, required this.postTitle, Key? key})
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

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged); // 포커스 변화
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isVisble = false;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged); // 리스너 제거
    _focusNode.dispose(); // FocusNode 정리
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      hasFocus = _focusNode.hasFocus; // 포커스 상태 업데이트
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
                  padding: const EdgeInsets.symmetric(horizontal: 20), // 좌우 패딩 추가
                  width: 340,
                  height: 75, // 박스 높이
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
                const SizedBox(height: 15),
                AnimatedSwitcher(
                  duration: const Duration(seconds: 1), // 애니메이션 지속 시간
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _isVisble
                      ? Center(
                    child: IntrinsicWidth(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10), // 좌우 10의 패딩 추가
                        height: 30, // 고정된 높이
                        decoration: BoxDecoration(
                          color: ColorStyles.mainBlue,
                          borderRadius: BorderRadius.circular(20), // 둥근 모서리
                        ),
                        child: const Center(
                          child: Text(
                            "2024.10.12",
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  )
                      : const SizedBox(), // _isVisible이 false면 빈 공간으로 대체
                ),
              ],
            ),
          ),
          // 채팅 영역
          Expanded(
            child: ListView.builder(
              itemCount: 20, // 예제 데이터 개수
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),

                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: '댓글을 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: ColorStyles.borderGrey, // 테두리 색상 설정
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: ColorStyles.mainBlue, // 클릭(포커스) 시 테두리 색상 변경
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    String newMessage = _messageController.text.trim();
                    if (newMessage.isNotEmpty) {
                      // 메시지 처리 로직
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
}
