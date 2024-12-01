import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../DbConn.dart';
import 'NotificationPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../RoundPost.dart';
import '../RoundComment.dart';
import '../RoundReply.dart';
import '../Post.dart';
import '../Comment.dart';
import 'WritePage.dart';

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
  String studentId = ""; // 현재 접속중인 학번
  String postUserId = ""; // 게시글 작성자 학번
  String userNickname = "";
  String profilePath = "";
  Color borderColor = ColorStyles.borderGrey;
  List<Comment> comments = [];
  String commentType = 'comment'; // 댓글 Type
  final TextEditingController _commentController = TextEditingController(); // 댓글 입력 필드 컨트롤러
  final FocusNode _focusNode = FocusNode();
  bool hasFocus = false;
  bool replyClicked = false;
  int? commentId;
  int? selectedCommentId; // 현재 선택된 댓글 ID
  String postType = "";

  @override
  void initState() {
    super.initState();
    postFuture = _fetchPostData(); // Future 초기화
    _initPref(); // SharedPreferences 초기화
    _fetchComments(); // 댓글 불러오기
    _focusNode.addListener(_onFocusChanged); // 포커스 변화
    _fetchPostType();
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

  // 답글 클릭 시 외곽선 색상 변경
  void _onReplyClick(int commentId) {
    setState(() {
      replyClicked = !replyClicked;
      selectedCommentId = selectedCommentId == commentId ? null : commentId;

      if (replyClicked) {
        commentType = 'reply';
        this.commentId = commentId;
      } else {
        commentType = 'comment';
        this.commentId = null;
      }
    });
  }

  // 게시물 가져오기
  Future<Map<String, dynamic>?> _fetchPostData() async {
    try {
      final postData = await DbConn.getPostById(widget.post_id);
      if (postData != null && postData['user_id'] != null) {
        postUserId = postData['user_id'].toString(); // String 형식으로 처리
      } else {
        postUserId = ""; // 기본값으로 빈 문자열 설정
      }

      return postData; // null일 수도 있음
    } catch (e) {
      print("Error fetching post data: \$e");
      return null;
    }
  }

  // 댓글 가져오기
  Future<void> _fetchComments() async {
    try {
      // 댓글 불러오기
      final fetchedComments = await DbConn.fetchComments(postId: widget.post_id);

      // 각 댓글에 대해 닉네임을 추가
      for (var comment in fetchedComments) {
        final nickname = await DbConn.getNickname(comment.userId.toString());
        comment.nickname = nickname;
      }
      setState(() {
        comments = fetchedComments;
      });
    } catch (e) {
      print("Error fetching comments: \$e");
    }
  }

  // 게시물 삭제하기
  void _deletePost(int postId) async {
    try {
      await DbConn.deletePostById(postId: widget.post_id);
      _showToast("게시물이 삭제되었습니다.");
      Navigator.pop(context);
    } catch(e) {
      print("댓글 삭제 오류: $e");
    }
  }

  // 댓글 삭제하기
  void _deleteComment(int commentId) async {
    try {
      await DbConn.deleteCommentById(commentId: commentId);
    } catch(e) {
      print("댓글 삭제 오류: $e");
    }
  }

  // 현재 Post의 타입 불러오기
  Future<void> _fetchPostType() async {
    try {
      postType = (await DbConn.fetchTypeById(postId: widget.post_id)).toString();
    } catch(e) {
      print("타입 불러오기 오류: $e");
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
    studentId = prefs?.getString('studentId') ?? "";
  }

  @override
  Widget build(BuildContext context) {
    String titleText = widget.type == 'lost' ? '분실물' : '습득물';

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                              context, MaterialPageRoute(
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
                            _showPopupMenu(context, postUserId, studentId);
                            selectedCommentId = null;
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
                    FutureBuilder<Map<String, dynamic>?> (
                      future: postFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data == null) {
                          return const Center(child: Text('게시글을 찾을 수 없습니다.'));
                        }

                        // Map 데이터를 Post 객체로 변환
                        final postData = snapshot.data!;

                        return FutureBuilder(
                          future: Future.wait([
                            DbConn.getNickname(postUserId),
                            DbConn.getProfileId(postUserId),
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
                              userId: (postData['user_id'] != null)
                                  ? int.tryParse(postData['user_id'].toString()) ?? 0
                                  : 0,
                              imageUrl1: postData['image_url1'] as String?,
                              imageUrl2: postData['image_url2'] as String?,
                              imageUrl3: postData['image_url3'] as String?,
                              imageUrl4: postData['image_url4'] as String?,
                              place: postData['place_keyword'] as String?,
                              thing: postData['thing_keyword'] as String?,
                            );

                            // 게시물
                            return SingleChildScrollView(
                              child: Column(
                              children: [
                                RoundPost(
                                  profile: profilePath,
                                  nickname: userNickname,
                                  createdAt: post.createdAt,
                                  title: post.title,
                                  body: post.body,
                                  commentCnt: comments.length,
                                  keywords: post.keywords,
                                  images: post.images,
                                ),
                                // 댓글 목록
                                comments.isEmpty
                                    ? Container() // 댓글이 없을 때 빈 공간 표시
                                    : ListView.builder(
                                  shrinkWrap: true, // ListView가 부모 크기를 초과하지 않도록 제한
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: comments.length,
                                  itemBuilder: (context, index) {
                                    final comment = comments[index];
                                    final isSelected = comment.commentId == selectedCommentId;

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 10), // 댓글들 사이 간격 10
                                      child: comment.parentCommentId == null
                                          ? RoundComment(
                                        nickname: comment.nickname ?? '',
                                        body: comment.body,
                                        createdAt: comment.createdAt,
                                        borderColor: isSelected
                                        ? ColorStyles.mainBlue
                                        : ColorStyles.borderGrey,
                                        onReplyClick: () {
                                          _onReplyClick(comment.commentId);
                                        },
                                        userId: studentId,
                                        commenterId: comment.userId.toString(),
                                        commentId: comment.commentId,
                                        onDeleteClick: (commentId) {
                                          _deleteComment(commentId);
                                          _fetchComments(); // 댓글 동기화
                                        },
                                      )
                                          : RoundReply(
                                        nickname: comment.nickname ?? '',
                                        body: comment.body,
                                        createdAt: comment.createdAt,
                                        userId: studentId,
                                        commenterId: comment.userId.toString(),
                                        commentId: comment.commentId,
                                        onDeleteClick: (commentId) {
                                          _deleteComment(commentId);
                                          _fetchComments(); // 댓글 동기화
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 댓글 입력 필드
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 100,
                    ),
                    child: SingleChildScrollView(
                      child: TextField(
                        controller: _commentController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: '댓글을 입력하세요',
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
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    String newComment = _commentController.text.trim();
                    if (newComment.isNotEmpty) {
                      _addComment(newComment);
                      replyClicked = false;
                      selectedCommentId = null;
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

  // 댓글 추가 로직
  void _addComment(String body) async {
    try {

      bool success = await DbConn.saveComment(
        postId: widget.post_id,
        userId: int.parse(studentId),
        body: body,
        type: commentType,
        parentCommentId: commentId,
      );

      if (success) {
        _commentController.clear();
        _fetchComments(); // 댓글 목록 업데이트
      } else {
        print("Failed to add comment");
      }
    } catch (e) {
      print("Error adding comment: \$e");
    }
  }

  // 팝업 메뉴 표시 로직
  void _showPopupMenu(BuildContext context, String postUserId, String currentUserId) {
    if (postUserId == currentUserId) { // 작성자라면
      _showAuthorPopupMenu(context);
    } else { // 일반 사용자
      _showUserPopupMenu(context);
    }
  }

  // 작성자 팝업 메뉴
  void _showAuthorPopupMenu(BuildContext context) async {
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
        // "편집하기"
        _buildPopupMenuItem(
          text: "편집하기",
          onTap: () {
            Navigator.pop(context); // 메뉴 닫기
            _pushPostIdForEdit();
            _showToast("함수 추가 예정");
          },
        ),
        // 구분선
        _buildDivider(),
        // "삭제하기"
        _buildPopupMenuItem(
          text: "삭제하기",
          onTap: () {
            Navigator.pop(context);
            _deletePost(widget.post_id);
          }, paddingTop: 8,
        ),
      ],
    );
  }
  // 사용자 팝업 메뉴
  void _showUserPopupMenu(BuildContext context) async {
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
        // "쪽지 보내기"
        _buildPopupMenuItem(
          text: "쪽지 보내기",
          onTap: () {
            Navigator.pop(context); // 메뉴 닫기
            _showToast("함수 추가 예정");
          },
        ),
        // 구분선
        _buildDivider(),
        // "신고하기"
        _buildPopupMenuItem(
          text: "> 신고하기",
          onTap: () {
            Navigator.pop(context);
            _showReportPopupMenu(context); // 신고하기 메뉴 띄우기
          }, paddingTop: 8,
        ),
      ],
    );
  }

  // 신고하기 팝업 메뉴
  void _showReportPopupMenu(BuildContext context) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        overlay.size.width - 150,
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
        // "불쾌한 콘텐츠 신고" 항목
        _buildPopupMenuItem(
          text: "불쾌한 콘텐츠 신고",
          onTap: () {
            Navigator.pop(context); // 메뉴 닫기
            _showReportDialog(context, userNickname, "불쾌한 콘텐츠 신고");
          },
        ), _buildDivider(marginTop: 4),
        _buildPopupMenuItem(
          text: "게시판 성격에 부적절",
          onTap: () {
            Navigator.pop(context);
            _showReportDialog(context, userNickname, "게시판 성격에 부적절");
          }, paddingTop: 8,
        ), _buildDivider(marginTop: 6),
      _buildPopupMenuItem(
        text: "욕설/비하",
        onTap: () {
          Navigator.pop(context);
          _showReportDialog(context, userNickname, "욕설/비하");
          }, paddingTop: 8,
        ),
      ],
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

  // 다이얼로그 생성
  void _showReportDialog(BuildContext context, String nickname, String reason) {
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
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: Text("취소", style: TextStyle(fontSize: 15, color: ColorStyles.darkGrey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                _showToast("신고가 접수되었습니다."); // 신고 처리
              },
              child: Text("확인", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ColorStyles.mainBlue)),
            ),
          ],
        );
      },
    );
  }

  // 편집하기 함수
  void _pushPostIdForEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WritePage(type: postType),
        settings: RouteSettings(
          arguments: widget.post_id,  // 전달할 데이터
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
