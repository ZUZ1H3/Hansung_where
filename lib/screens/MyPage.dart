import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../DbConn.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'NotificationPage.dart';
import 'MyPostPage.dart';
import 'MyCommentPage.dart';
import 'NotiSettingPage.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool isProfileBoxVisible = false; // 프로필 박스 가시성 제어 변수
  @override
  void initState() {
    super.initState();
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
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // 뒤로 가기
                  },
                  child: const ImageIcon(
                    AssetImage('assets/icons/ic_back.png'),
                  ),
                ),
                const SizedBox(width: 95),
                const Text(
                  '마이페이지',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 92),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotificationPage()),
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
              ],
            ),
            const SizedBox(height: 36),

            // 프로필 섹션과 박스를 겹치게 배치
            Stack(
              clipBehavior: Clip.none,
              children: [
                // 나의 뱃지
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 145),
                    Padding(
                      padding: EdgeInsets.only(left: 13), // 텍스트를 오른쪽으로 이동
                      child: Text(
                        '나의 뱃지',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        RoundBadges(
                          label1: '첫 댓글',
                          icon1: 'assets/icons/ic_blank.png',
                          label2: '첫 게시글',
                          icon2: 'assets/icons/ic_blank.png',
                          label3: '친절함 최고',
                          icon3: 'assets/icons/ic_blank.png',
                          label4: '분실물의 영웅',
                          icon4: 'assets/icons/ic_blank.png',
                        ),
                      ],
                    ),
                  ],
                ),
                // 프로필 섹션
                Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isProfileBoxVisible = !isProfileBoxVisible;
                          });
                        },
                        child: Image.asset(
                          'assets/icons/ic_boogi.png',
                          width: 76,
                          height: 76,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '부기',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 2),
                            GestureDetector(
                              onTap: () {
                                // 이름 수정 예정
                              },
                              child: Image.asset(
                                'assets/icons/ic_pen.png',
                                width: 18,
                                height: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 프로필 박스
                      if (isProfileBoxVisible)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/icons/ic_profilebox.png', // 배경 이미지
                              fit: BoxFit.contain,
                              width: 340,
                              height: 139,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                buildIconItem('assets/icons/ic_boogi.png'),
                                buildIconItem('assets/icons/ic_kkokko.png'),
                                buildIconItem('assets/icons/ic_kkukku.png'),
                                buildIconItem('assets/icons/ic_sangzzi.png'),
                                buildIconItem('assets/icons/ic_nyang.png'),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),

              ],
            ),

            const SizedBox(height: 30),

            // 나의 활동
            const Padding(
              padding: EdgeInsets.only(left: 13), // 텍스트를 오른쪽으로 이동
              child: Text(
                '나의 활동',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            RoundTwoItems(
              icon1: 'assets/icons/ic_mypost.png',
              icon2: 'assets/icons/ic_mycomment.png',
              onTap1: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyPost()),
                );
              },
              onTap2: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyComment()),
                );
              },
            ),
            const SizedBox(height: 30),

            // 설정
            const Padding(
              padding: EdgeInsets.only(left: 13), // 텍스트를 오른쪽으로 이동
              child: Text(
                '설정',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            RoundTwoItems(
              icon1: 'assets/icons/ic_logout.png',
              icon2: 'assets/icons/ic_annosetting.png',
              onTap1: () {
                // 추가 예정
              },
              onTap2: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotiSetting()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIconItem(String assetPath) {
    return CircleAvatar(
      radius: 27.5,
      backgroundImage: AssetImage(assetPath),
    );
  }
}

// 뱃지
class RoundBadges extends StatelessWidget {
  final String label1;
  final String label2;
  final String label3;
  final String label4;
  final String icon1;
  final String icon2;
  final String icon3;
  final String icon4;

  const RoundBadges({
    required this.label1,
    required this.label2,
    required this.label3,
    required this.label4,
    required this.icon1,
    required this.icon2,
    required this.icon3,
    required this.icon4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color(0xFFEDEDED),
          width: 1.0,
        ),
      ),
      child: Stack(
        children: [
          _buildIcon(label1, icon1, 20, 11),
          _buildIcon(label2, icon2, 100, 11),
          _buildIcon(label3, icon3, 180, 11),
          _buildIcon(label4, icon4, 260, 11),
        ],
      ),
    );
  }

  // 아이콘과 라벨 생성
  Widget _buildIcon(String label, String icon, double left, double top) {
    return Positioned(
      left: left,
      top: top,
      child: Column(
        children: [
          Image.asset(
            icon,
            width: 60,
            height: 60,
          ),
          const SizedBox(height: 7), // 아이콘과 텍스트 간격
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// 둥근 사각형
class RoundTwoItems extends StatelessWidget {
  final String icon1;
  final String icon2;
  final VoidCallback onTap1;
  final VoidCallback onTap2;

  const RoundTwoItems({
    required this.icon1,
    required this.icon2,
    required this.onTap1,
    required this.onTap2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color(0xFFEDEDED),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          _buildIcon(icon1, 20, 11, onTap1),
          _buildIcon(icon2, 20, 59, onTap2),
          Positioned(
            left: 18,
            top: 48,
            child: Image.asset(
              'assets/icons/ic_line.png',
              width: 300,
              height: 1,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  // 아이콘 생성
  Widget _buildIcon(String icon, double left, double top, VoidCallback onTap) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: onTap,
        child: Image.asset(
          icon,
          width: 300,
          height: 26,
        ),
      ),
    );
  }
}
