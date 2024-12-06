import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/MyPage.dart';
import '../screens/NotificationPage.dart';
import '../screens/WritePage.dart';
import '../LoginPage.dart';
import '../theme/colors.dart';
import '../PostCard.dart';
import '../Post.dart';
import '../NoticePostCard.dart';
import '../NoticePost.dart';
import '../DbConn.dart';
import '../screens/ManagerPage.dart';
import '../screens/SearchPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  final List<String> tags = ['전체', '원스톱', '학식당', '학술정보관', '상상빌리지', '상상파크'];
  String selectedTag = '전체';
  bool isPopupVisible = false; // 팝업 표시 여부
  SharedPreferences? prefs; // SharedPreferences를 클래스 변수로 선언

  @override
  void initState() {
    super.initState();
    _initPrefs(); // SharedPreferences 초기화
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // RouteAware 등록
    RouteObserver<ModalRoute>().subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    super.didPopNext();
    // 화면이 돌아올 때 새로고침
    _refreshPosts();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {}); // 초기화 후 상태 갱신
  }

  //userId를 가져옴
  Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString('studentId');
    return int.tryParse(studentId ?? '') ?? 0; // 기본값 설정
  }

  Future<void> _movePage(String pageType) async {
    if (prefs == null) return; // prefs 초기화 확인
    final isLogIn = prefs!.getBool('isLogIn') ?? false;
    Widget targetPage;

    if (isLogIn) {
      if (pageType == 'notification') {
        targetPage = NotificationPage();
      } else if (pageType == 'manager') {
        targetPage = ManagerPage();
      } else {
        targetPage = MyPage();
      }
    } else {
      targetPage = LoginPage();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
    );
  }

  // 새로고침
  Future<void> _refreshPosts() async {
    setState(() {
      DbConn.fetchPosts(type: selectedTag); // 데이터 갱신
    });
  }

  Widget _buildPostList(String type) {
    return FutureBuilder(
      future: Future.wait([
        selectedTag == '전체'
            ? DbConn.fetchLatestNoticePosts()
            : Future.value(null), // 태그가 전체일 때만 공지사항 가져오기
        DbConn.fetchPosts(type: type), // 게시물 가져오기
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final noticePost = snapshot.data?[0] as NoticePost?;
        List<Post> posts = snapshot.data?[1] as List<Post>? ?? [];

        // 선택된 태그에 따라 게시글 필터링
        if (selectedTag != '전체') {
          posts = posts.where((post) => post.place == selectedTag).toList();
        }

        if (noticePost == null && posts.isEmpty) {
          return const Center(child: Text('게시물이 없습니다.'));
        }

        return ListView.builder(
          itemCount: (noticePost != null ? 1 : 0) + posts.length,
          itemBuilder: (context, index) {
            if (index == 0 && noticePost != null) {
              return NoticePostCard(
                noticePost: noticePost,
                showTitle: true,
                isForHomePage: true,
              );
            }

            // 이후 게시글 표시
            return PostCard(
              post: posts[index - (noticePost != null ? 1 : 0)],
              type: type,
            );
          },
        );
      },
    );
  }

  Widget _buildTag(String tag, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTag = tag;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? ColorStyles.mainBlue : ColorStyles.seedColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          tag,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTagSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            tags.map((tag) => _buildTag(tag, selectedTag == tag)).toList(),
      ),
    );
  }

  Widget _buildPopupButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorStyles.mainBlue,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Neo',
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildPopupButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPopupButton('습득물', () async {
          final isLogIn = prefs?.getBool('isLogIn') ?? false; // 로그인 상태 확인

          if (isLogIn) {
            // 로그인 상태
            setState(() {
              isPopupVisible = false;
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WritePage(type: 'found')),
            );
          } else {
            // 비로그인 상태
            setState(() {
              isPopupVisible = false;
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          }
        }),
        _buildPopupButton('분실물', () async {
          final isLogIn = prefs?.getBool('isLogIn') ?? false; // 로그인 상태 확인

          if (isLogIn) {
            // 로그인 상태
            setState(() {
              isPopupVisible = false;
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WritePage(type: 'lost')),
            );
          } else {
            // 비로그인 상태
            setState(() {
              isPopupVisible = false;
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          }
        }),
      ],
    );
  }

  void _showSuspendedDialog(BuildContext context, String suspendedUntil) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // 모서리를 둥글게 설정
            side: const BorderSide(
              color: Colors.grey, // 회색 테두리
              width: 1.5,
            ),
          ),
          backgroundColor: Colors.white,
          // 흰색 배경
          title: const Text(
            '정지 상태',
            style: TextStyle(
              fontFamily: 'Neo', // Neo 폰트 적용
              fontWeight: FontWeight.bold, // 굵은 텍스트
              fontSize: 18,
            ),
          ),
          content: Text(
            '현재 정지 상태입니다.\n정지 해제 시간: $suspendedUntil',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF042D6F), // 배경색 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // 둥근 버튼
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // 버튼 패딩
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                '확인',
                style: TextStyle(
                  fontFamily: 'Neo', // Neo 폰트 적용
                  fontSize: 14,
                  color: Colors.white, // 흰색 텍스트
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _checkUserSuspension(int userId) async {
    try {
      final suspendedUntilStr =
          await DbConn.getUserSuspensionStatus(userId); // 정지 상태 조회

      if (suspendedUntilStr != null) {
        final DateTime suspendedUntil =
            DateTime.parse(suspendedUntilStr); // 문자열을 DateTime으로 변환
        final DateTime now = DateTime.now(); // 현재 시간
        print("현재: $now, 정지: $suspendedUntil");
        if (suspendedUntil.isAfter(now)) {
          return true; // 현재 시간보다 미래라면 정지 상태
        } else {
          final success = await DbConn.updateSuspendStatus(userId); // 정지 상태 해제
          if (success) {
            print("정지가 해제되었습니다."); // Toast 메시지 표시
          }
        }
      }
      return false;
    } catch (e) {
      print('정지 상태 확인 중 오류 발생: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 35,
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Image.asset('assets/icons/ic_search.png', height: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    );
                  },
                ),
                IconButton(
                  icon: Image.asset('assets/icons/ic_notification.png',
                      height: 20),
                  onPressed: () {
                    _movePage('notification');
                  },
                ),
                IconButton(
                  icon: Image.asset('assets/icons/ic_user.png', height: 20),
                  onPressed: () async {
                    final userId = await getUserId(); // 비동기로 userId 가져오기
                    if (userId != 0) {
                      _movePage('user'); // userId가 0이 아니면 MyPage로 이동
                    } else {
                      _movePage('manager'); // userId가 0이면 ManagerPage로 이동
                    }
                  },
                ),
              ],
              bottom: const TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF042D6F),
                labelStyle: TextStyle(
                  fontFamily: 'Neo',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                unselectedLabelStyle: TextStyle(
                  fontFamily: 'Neo',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                tabs: [
                  Tab(text: '습득물'),
                  Tab(text: '분실물'),
                ],
              ),
            ),
            body: Column(
              children: [
                const SizedBox(height: 10),
                _buildTagSelector(),
                Expanded(
                  child: TabBarView(
                    children: [
                      // 당길 때 새로고침 기능 추가
                      RefreshIndicator(
                        onRefresh: _refreshPosts,
                        child: _buildPostList('found'), // 습득물
                      ),
                      RefreshIndicator(
                        onRefresh: _refreshPosts,
                        child: _buildPostList('lost'), // 분실물
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isPopupVisible)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isPopupVisible = false; // 배경 클릭 시 팝업 닫기
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.5), // 화면 전체 반투명 어두운 배경
                ),
              ),
            ),
          Positioned(
            bottom: 26,
            left: 0,
            right: 0,
            child: Center(
              child: isPopupVisible
                  ? _buildPopupButtons()
                  : ElevatedButton(
                      onPressed: () async {
                        final userId = await getUserId();

                        final bool isSuspended =
                            await _checkUserSuspension(userId); // 정지 여부 확인

                        if (isSuspended) {
                          final suspendedUntil =
                              await DbConn.getUserSuspensionStatus(
                                  userId); // 정지 해제 시간 가져오기
                          _showSuspendedDialog(
                              context, suspendedUntil!); // 정지 다이얼로그 표시
                        } else {
                          setState(() {
                            isPopupVisible = true; // 팝업 버튼 보이기
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorStyles.mainBlue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '글쓰기',
                        style: TextStyle(
                          fontFamily: 'Neo',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
