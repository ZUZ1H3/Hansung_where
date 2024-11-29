import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/MyPage.dart';
import '../screens/NotificationPage.dart';
import '../screens/WritePage.dart';
import '../LoginPage.dart';
import '../theme/colors.dart';
import '../PostCard.dart';
import '../Post.dart';
import '../DbConn.dart';
import '../screens/ManagerPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> tags = ['전체', '원스톱', '학식당', '학술정보관', '상상빌리지', '상상파크'];
  String selectedTag = '전체';
  bool isPopupVisible = false; // 팝업 표시 여부
  SharedPreferences? prefs; // SharedPreferences를 클래스 변수로 선언

  @override
  void initState() {
    super.initState();
    _initPrefs(); // SharedPreferences 초기화
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


  Widget _buildPostList(String type) {
    return FutureBuilder<List<Post>>(
      future: DbConn.fetchPosts(type: type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('게시물이 없습니다.'));
        } else {
          List<Post> posts = snapshot.data!;

          // 선택된 태그에 따라 게시글 필터링
          if (selectedTag != '전체') {
            posts = posts.where((post) => post.place == selectedTag).toList();
          }

          if (posts.isEmpty) {
            return const Center(child: Text('해당 장소의 게시물이 없습니다.'));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostCard(
                post: posts[index],
                type: type,
              );
            },
          );
        }
      },
    );
  }


  Widget _buildTabBarView(List<String> types) {
    return TabBarView(
      children: types.map((type) => _buildPostList(type)).toList(),
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
        children: tags.map((tag) => _buildTag(tag, selectedTag == tag)).toList(),
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
                    print('검색 아이콘 클릭');
                  },
                ),
                IconButton(
                  icon: Image.asset('assets/icons/ic_notification.png', height: 20),
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
                      _buildPostList('found'), // 습득물
                      _buildPostList('lost'),  // 분실물
                    ],
                  ),                ),
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
                onPressed: () {
                  setState(() {
                    isPopupVisible = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorStyles.mainBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
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
