import 'package:flutter/material.dart';
import 'theme/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RoundReply extends StatelessWidget {
  final String nickname; // 닉네임
  final String body; // 내용
  final String createdAt; // 작성 시간
  final String userId;         // 사용자 학번
  final String commenterId;    // 작성자 학번
  final int commentId;         // 댓글 ID
  final Function(int commentId) onDeleteClick; // 삭제 버튼 클릭 시 실행될 함수

  // GlobalKey를 사용하여 점 버튼의 위치를 추적
  final GlobalKey _dotsKey = GlobalKey();

  RoundReply({
    required this.nickname,
    required this.body,
    required this.createdAt,
    required this.userId,
    required this.commenterId,
    required this.commentId,
    required this.onDeleteClick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 답글 아이콘
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 5),
          child: Image.asset(
            'assets/icons/ic_reply.png',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
        // 댓글 내용 컨테이너 (점 버튼 포함)
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(
                top: 15, left: 10, right: 10, bottom: 10), // 여백 조정
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: ColorStyles.borderGrey,
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // 댓글 내용 및 작성 시간
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 닉네임 출력
                    Text(
                      nickname,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 댓글 내용 (스크롤 가능)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 100),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Text(
                          body,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            height: 1.6,
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
                // 점 버튼 (컨테이너 오른쪽 상단에 고정)
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    key: _dotsKey,  // GlobalKey를 설정하여 점 위치를 추적
                    onTap: () {
                      _showCommentPopupMenu(context); // 점 버튼 클릭 시 팝업 메뉴 띄우기
                    },
                    child: Image.asset(
                      'assets/icons/ic_dots.png', // 점 버튼 이미지
                      width: 18,
                      height: 18,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  // 점 버튼 위치를 계산하고 팝업 메뉴를 띄우는 함수
  void _showCommentPopupMenu(BuildContext context) async {
    final RenderBox renderBox = _dotsKey.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero); // 점 버튼의 위치

    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    // 사용자 학번과 작성자 학번을 비교
    bool isUserOwner = userId == commenterId;

    // showMenu 호출 후 팝업 메뉴를 닫고 다른 작업을 진행하도록 수정
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx, // 점 버튼의 x 위치
        position.dy + renderBox.size.height + 10, // 점 버튼 아래 10px 만큼
        overlay.size.width - 10,
        0,
      ),
      color: Colors.white, // 팝업 배경 흰색
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // 둥근 모서리
        side: BorderSide( // 테두리 추가
          color: Color(0xFFC0C0C0),
          width: 1, // 테두리 두께
        ),
      ),
      items: [
        // 사용자 학번과 작성자 학번이 같을 경우
        if (isUserOwner) ...[
          _buildPopupMenuItem(
            text: "삭제하기",
            onTap: () {
              Navigator.pop(context); // 메뉴 닫기
              onDeleteClick(commentId);
            },
          ),
        ] else ...[
          // 사용자 학번과 작성자 학번이 다를 경우
          _buildPopupMenuItem(
            text: "쪽지 보내기",
            onTap: () {
              Navigator.pop(context); // 메뉴 닫기
              _showToast("추가 예정");
            },
          ),
          _buildDivider(marginTop: 2),
          _buildPopupMenuItem(
            text: "> 신고하기",
            onTap: () {
              Navigator.pop(context); // 메뉴 닫기
              // 메뉴를 닫은 후에 신고 팝업을 열도록 수정
              _showReportPopupMenu(context);
            }, paddingTop: 8,
          ),
        ],
      ],
    );
  }

  // 신고하기 팝업창
  void _showReportPopupMenu(BuildContext context) async {
    if (!_dotsKey.currentContext!.mounted) return; // 위젯이 활성화되어 있는지 확인

    final RenderBox renderBox = _dotsKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero); // 점 버튼의 위치

    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx, // 점 버튼의 x 위치
        position.dy + renderBox.size.height + 10, // 점 버튼 아래 10px 만큼
        overlay.size.width - 10,
        0,
      ),
      color: Colors.white, // 팝업 배경 흰색
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // 둥근 모서리
        side: BorderSide( // 테두리 추가
          color: Color(0xFFC0C0C0),
          width: 1, // 테두리 두께
        ),
      ),
      items: [
        // "불쾌한 콘텐츠 신고" 항목
        _buildPopupMenuItem(
          text: "불쾌한 콘텐츠 신고",
          onTap: () {
            if (context.mounted) {
              Navigator.pop(context); // 메뉴 닫기
              _showReportDialog(context, nickname, "불쾌한 콘텐츠 신고");
            }
          },
        ),
        _buildDivider(marginTop: 4),
        _buildPopupMenuItem(
          text: "게시판 성격에 부적절",
          onTap: () {
            if (context.mounted) {
              Navigator.pop(context);
              _showReportDialog(context, nickname, "게시판 성격에 부적절");
            }
          },
          paddingTop: 8,
        ),
        _buildDivider(marginTop: 6),
        _buildPopupMenuItem(
          text: "욕설/비하",
          onTap: () {
            if (context.mounted) {
              Navigator.pop(context);
              _showReportDialog(context, nickname, "욕설/비하");
            }
          },
          paddingTop: 8,
        ),
      ],
    );
  }

  // 다이얼로그 생성 함수
  void _showReportDialog(BuildContext context, String nickname, String reason) {
    if (!context.mounted) return; // 다이얼로그를 띄울 수 없는 상태인지 확인

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          actionsPadding: EdgeInsets.only(bottom: 10, right: 5), // 버튼 여백 조정
          title: const Text(
            '신고하기',
            style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          content: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "$nickname", // nickname은 bold로 표시
                  style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ' 이용자를 ', // " 이용자를
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
                TextSpan(
                  text: "$reason",
                  style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '로 신고하시겠습니까?',
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (context.mounted) Navigator.pop(context); // 다이얼로그 닫기
              },
              child: Text("취소", style: TextStyle(fontSize: 15, color: ColorStyles.darkGrey)),
            ),
            TextButton(
              onPressed: () {
                if (context.mounted) {
                  Navigator.pop(context); // 다이얼로그 닫기
                  _showToast("신고가 접수되었습니다."); // 신고 처리
                }
              },
              child: Text("확인", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ColorStyles.mainBlue)),
            ),
          ],
        );
      },
    );
  }

  // PopupMenu 아이템을 생성
  PopupMenuItem _buildPopupMenuItem({
    required String text,
    required VoidCallback onTap,
    double paddingTop = 0,
  }) {
    return PopupMenuItem(
      padding: EdgeInsets.zero, // 기본 패딩 제거
      height: 30, // 높이 고정
      child: Container(
        width: 150, // 너비 고정
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 10.5, top: paddingTop),
        child: InkWell(
          onTap: onTap,
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ),
      ),
    );
  }

  // 구분선 아이템을 생성하는 함수
  PopupMenuItem _buildDivider ({ double marginTop = 2 }) {
    return PopupMenuItem(
      padding: EdgeInsets.zero, // 기본 패딩 제거
      height: 1 + marginTop,
      child: Container(
        margin: EdgeInsets.only(top: marginTop),
        child: Divider(
          height: 1, // 구분선 자체 높이
          thickness: 1, // 구분선 두께
          color: Color(0xFFC0C0C0), // 회색 구분선
        ),
      ),
    );
  }

  // Toast 메시지 표시 함수
  void _showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: ColorStyles.mainBlue,
        textColor: Colors.white,
        fontSize: 16
    );
  }
}