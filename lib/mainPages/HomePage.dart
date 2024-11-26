import 'package:flutter/material.dart';
import '../screens/WritePage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> tags = ['전체', '원스톱', '학식당', '학술정보관', '상상빌리지', '상상관'];

  String selectedTag = '전체';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 탭의 개수: 습득물, 분실물
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white, // AppBar의 배경색을 흰색으로 설정
          title: Row(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 40,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                print('검색 아이콘 클릭');
              },
            ),
            IconButton(
              icon: Icon(Icons.notifications), // 알림 버튼
              onPressed: () {
                print('알림 아이콘 클릭');
              },
            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                print('유저 아이콘 클릭');
              },
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.black, // 탭 활성 상태 텍스트 색상
            unselectedLabelColor: Colors.grey, // 비활성 탭 텍스트 색상
            indicatorColor:Color(0xFF042D6F), // 탭 아래 선택된 표시줄 색상
            tabs: [
              Tab(text: '습득물'), // 첫 번째 탭
              Tab(text: '분실물'), // 두 번째 탭
            ],
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                _buildTagSelector(),
                Divider(), // 구분선
                Expanded(
                  child: TabBarView(
                    children: [
                      Center(child: Text('습득물 페이지')),
                      Center(child: Text('분실물 페이지')),
                    ],
                  ),
                ),
              ],
            ),
            // 글쓰기 버튼 고정
            Positioned(
              bottom: 20, // 화면 아래에서 20px 위치
              right: 20, // 화면 오른쪽에서 20px 위치
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WritePage()),
                  );
                },
                backgroundColor: Color(0xFF042D6F), // 버튼 배경색
                child: Icon(Icons.edit, color: Colors.white), // 버튼 아이콘
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 장소 태그 선택 UI
  Widget _buildTagSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // 태그를 가로 스크롤 가능하게 설정
      child: Row(
        children: tags.map((tag) {
          final bool isSelected = selectedTag == tag;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedTag = tag; // 선택된 태그 업데이트
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 6), // 태그 간 간격
              padding: EdgeInsets.symmetric(horizontal: 9, vertical: 6), // 태그 내부 간격
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF042D6F) : Colors.white, // 선택 상태에 따른 배경색
                borderRadius: BorderRadius.circular(14), // 둥근 모서리

              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black, // 선택 상태에 따른 텍스트 색상
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
