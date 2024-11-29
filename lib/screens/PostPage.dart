import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../DbConn.dart';
import 'NotificationPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../RoundPost.dart';
import '../RoundComment.dart';
import '../Post.dart';

class PostPage extends StatefulWidget {
  final int post_id;
  final String type; // type 받을 변수

  const PostPage({required this.post_id, required this.type, Key? key}) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  SharedPreferences? prefs;
  Future<Map<String, dynamic>?> postFuture = Future.value(null);
  String studentId = "";
  String userNickname = "";
  String profilePath = '';

  @override
  void initState() {
    super.initState();
    postFuture = _fetchPostData(); // Future 초기화
    _initPref(); // SharedPreferences 초기화
  }

  Future<Map<String, dynamic>?> _fetchPostData() async {
    try {
      final postData = await DbConn.getPostById(widget.post_id);

      return postData; // null일 수도 있음
    } catch (e) {
      print("Error fetching post data: $e");
      return null;
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

  // SharedPreferences 초기화
  Future<void> _initPref() async {
    prefs = await SharedPreferences.getInstance();
    // studentId 불러오기
    String? savedStudentId = prefs?.getString('studentId');
  }

  @override
  Widget build(BuildContext context) {
    String titleText = widget.type == 'lost' ? '분실물' : '습득물';

    final comments = [
      {
        'id': 1,
        'postId': 101,
        'userId': 1,
        'body': '이건 첫 번째 댓글이에요.',
        'createdAt': '11/29 12:00',
        'type': '댓글',
        'parentCommentId': null,
      },
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
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
                  const SizedBox(width: 110),
                  Text(
                    titleText,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 89),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationPage()),
                      );
                    },
                    child: Transform.translate(
                      offset: const Offset(0, -1), // Y축으로 1만큼 올리기
                      child: Image.asset(
                        'assets/icons/ic_notification.png',
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      _showPopupMenu(context);
                    },
                    child: Image.asset(
                      'assets/icons/ic_dots.png',
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 게시글
              FutureBuilder<Map<String, dynamic>?>(
                future: postFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text('게시글을 찾을 수 없습니다.'));
                  }

                  // Map 데이터를 Post 객체로 변환
                  final postData = snapshot.data!;
                  final String studentId = postData['user_id']?.toString() ?? "";

                  // 비동기 작업 결과를 기다리지 않고 FutureBuilder의 state를 활용
                  return FutureBuilder(
                    future: Future.wait([
                      DbConn.getNickname(studentId),
                      DbConn.getProfileId(studentId),
                    ]),
                    builder: (context, AsyncSnapshot<List<dynamic>> asyncSnapshot) {
                      if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (asyncSnapshot.hasError) {
                        return const Center(child: Text('오류가 발생했습니다.'));
                      }

                      // 닉네임 및 프로필 경로 설정
                      userNickname = asyncSnapshot.data?[0] ?? "";
                      final profileId = asyncSnapshot.data?[1] ?? 0;
                      profilePath = _getProfileImagePath(profileId);

                      // Post 객체 생성
                      final post = Post(
                        postId: widget.post_id,
                        title: postData['title'] as String? ?? '제목 없음',
                        body: postData['body'] as String? ?? '내용 없음',
                        createdAt: postData['created_at'] as String? ?? '',
                        userId: int.tryParse(studentId) ?? 0,
                        imageUrl1: postData['image_url1'] as String?,
                        imageUrl2: postData['image_url2'] as String?,
                        imageUrl3: postData['image_url3'] as String?,
                        imageUrl4: postData['image_url4'] as String?,
                        place: postData['place_keyword'] as String?,
                        thing: postData['thing_keyword'] as String?,
                      );

                      return Column(
                        children: [
                          RoundPost(
                            profile: profilePath,
                            nickname: userNickname,
                            createdAt: post.createdAt,
                            title: post.title,
                            body: post.body,
                            commentCnt: 0, // 댓글 개수는 별도 API 필요
                            keywords: post.keywords,
                            images: post.images,
                          ),
                          // 댓글 목록
                          ListView.builder(
                            shrinkWrap: true, // ListView가 부모 크기를 초과하지 않도록 제한
                            physics: const NeverScrollableScrollPhysics(), // 스크롤 비활성화
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              return RoundComment(
                                id: comment['id'] as int? ?? 0,
                                postId: comment['postId'] as int? ?? 0,
                                userId: comment['userId'] as int? ?? 0,
                                createdAt: comment['createdAt'] as String? ?? "",
                                body: comment['body'] as String? ?? "",
                                type: comment['type'] as String? ?? "",
                                parentCommentId: comment['parentCommentId'] as int? ?? 0,
                                isReplyMode: false,
                                onReplyClick: () {
                                  // 댓글 버튼 클릭 시 동작
                                  print("댓글 버튼 클릭 - 댓글 ID: ${comment['id']}");
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 팝업 메뉴
  void _showPopupMenu(BuildContext context) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        overlay.size.width - 10,
        70, // 상단 여백
        0,
        0, // 아래쪽 여백
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
        // 편집하기 항목
        PopupMenuItem(
          padding: EdgeInsets.zero, // 기본 패딩 제거
          height: 30, // 높이 고정
          child: Container(
            width: 120, // 너비 고정
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 10.5), // 왼쪽 간격 추가
            child: InkWell(
              onTap: () {
                Navigator.pop(context); // 메뉴 닫기
                _showToast("편집하기 클릭");
                // 편집 함수 추가 예정
              },
              child: Text(
                "편집하기",
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
          ),
        ),
        // 구분선
        PopupMenuItem(
          padding: EdgeInsets.zero, // 기본 패딩 제거
          height: 3, // 높이를 살짝 추가하여 여백 확보
          child: Container(
            margin: const EdgeInsets.only(top: 2), // 구분선을 아래로 2px 이동
            child: Divider(
              height: 1, // 구분선 자체 높이
              thickness: 1, // 구분선 두께
              color: Color(0xFFC0C0C0), // 회색 구분선
            ),
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero, // 기본 패딩 제거
          height: 30, // 높이 고정
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 10.5), // 왼쪽 간격 추가
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "삭제하기",
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ),
          ),
        ),
      ],
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

  void _showReportPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("신고하기"),
          content: const Text("신고하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("신고 완료")),
                );
              },
              child: const Text("신고"),
            ),
          ],
        );
      },
    );
  }
}
