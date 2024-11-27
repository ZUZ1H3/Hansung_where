import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/MyPage.dart';
import '../screens/NotificationPage.dart';
import '../screens/WritePage.dart';
import '../LoginPage.dart';
import '../theme/colors.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> tags = ['전체', '원스톱', '학식당', '학술정보관', '상상빌리지', '상상관'];
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

  // 알림 페이지로 이동
  Future<void> _moveNotificationPage() async {
    final prefs = await SharedPreferences.getInstance();
    final isLogIn = prefs.getBool('isLogIn') ?? false; // 로그인 여부

    if(isLogIn) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  // 마이페이지로 이동
  Future<void> _moveUserPage() async {
    final prefs = await SharedPreferences.getInstance();
    final isLogIn = prefs.getBool('isLogIn') ?? false; // 로그인 여부

    if(isLogIn) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
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
                    print('검색 아이콘 클릭');
                  },
                ),
                IconButton(
                  icon: Image.asset('assets/icons/ic_notification.png', height: 20),
                  onPressed: () {
                    _moveNotificationPage();
                  },
                ),
                IconButton(
                  icon: Image.asset('assets/icons/ic_user.png', height: 20),
                  onPressed: () {
                    _moveUserPage();
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
                const Expanded(
                  child: TabBarView(
                    children: [
                      Center(child: Text('습득물 페이지')),
                      Center(child: Text('분실물 페이지')),
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
                  ? _buildPopupButtons() // 팝업 버튼 표시
                  : ElevatedButton(
                onPressed: () {
                  setState(() {
                    isPopupVisible = true; // 팝업 활성화
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

  Widget _buildPopupButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              isPopupVisible = false; // 팝업 닫기
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WritePage(type: 'found'), // 'found' 전달
              ),            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorStyles.mainBlue,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            '습득물',
            style: TextStyle(
              fontFamily: 'Neo',
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              isPopupVisible = false; // 팝업 닫기
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WritePage(type: 'lost'), // 'lost' 전달
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorStyles.mainBlue,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            '분실물',
            style: TextStyle(
              fontFamily: 'Neo',
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tags.map((tag) {
          final bool isSelected = selectedTag == tag;
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
        }).toList(),
      ),
    );
  }
}
