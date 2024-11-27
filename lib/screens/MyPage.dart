import 'package:flutter/material.dart';
import '../mainPages/HomePage.dart';
import '../theme/colors.dart';
import '../DbConn.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'NotificationPage.dart';
import 'MyPostPage.dart';
import 'MyCommentPage.dart';
import 'NotiSettingPage.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool isProfileBoxVisible = false; // 프로필 변경 변수
  bool isEdit = false; // 닉네임 편집 변수
  String? profileImage;
  String? nickname;
  SharedPreferences? prefs;
  String? studentId;
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initPref();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  // SharedPreferences 초기화 및 프로필 데이터 불러오기
  Future<void> _initPref() async {
    prefs = await SharedPreferences.getInstance();
    // studentId 불러오기
    String? savedStudentId = prefs?.getString('studentId');

    if (savedStudentId != null) {
      setState(() {
        studentId = savedStudentId;
      });

      // 프로필 값으로 이미지 설정
      await _loadProfile(savedStudentId);
      await _loadNickname(savedStudentId);
    } else {
      _showToast("로그인된 사용자 정보가 없습니다.");
    }
  }

  // 프로필값 불러오기
  Future<void> _loadProfile(String studentId) async {
    try {
      // DB에서 프로필 ID 가져오기
      int profileId = await DbConn.getProfileId(studentId);

      // 상태 업데이트
      setState(() {
        profileImage = _getProfileImagePath(profileId); // 프로필 이미지 경로 설정
      });
    } catch (e) {
      print("프로필 데이터를 불러오는 중 오류 발생: $e");
    }
  }

  // 닉네임 불러오기
  Future<void> _loadNickname(String studentId) async {
    try {
      // DB에서 닉네임 가져오기
      String? userName = await DbConn.getNickname(studentId);

      // 상태 업데이트
      setState(() {
        nickname = userName ?? "";
      });
    } catch (e) {
      print("프로필 데이터를 불러오는 중 오류 발생: $e");
    }
  }

  // 닉네임 변경
  Future<void> _updateNickname() async {
    if (studentId != null && _nicknameController.text.isNotEmpty) {
      final newNickname = _nicknameController.text.trim();

      // 닉네임 길이 체크
      if(newNickname.length > 10) {
        _showToast("닉네임은 최대 10자까지 작성 가능합니다.");
        return;
      }
      // 중복 확인
      bool isUnique = await DbConn.checkNickname(newNickname);
      if (!isUnique) {
        _showToast("이미 사용 중인 닉네임입니다.");
        return;
      }

      // 중복되지 않으면 업데이트
      bool success = await DbConn.updateNickname(studentId!, newNickname);
      if (success) {
        setState(() {
          nickname = newNickname;
          isEdit = false; // 편집 상태 해제
        });
        _showToast("닉네임이 변경되었습니다.");
      } else {
        _showToast("닉네임 변경에 실패했습니다.");
      }
    } else {
      _showToast("닉네임을 입력해주세요.");
    }
  }

  // 로그아웃
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()), // 로그인 화면으로 이동
    );
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
                      child: profileImage != null ? Image.asset(
                        profileImage!,
                        width: 76,
                        height: 76,
                        fit: BoxFit.contain,
                      ) : const SizedBox(
                        width: 76,
                        height: 76,
                      ), // 빈 공간 유지
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            nickname ?? '',
                            style: TextStyle(fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 2),
                          GestureDetector(
                            onTap: () {
                              _showEditNicknameDialog(); // 다이얼로그 표시
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
                              buildIconItem('assets/icons/ic_boogi.png', 1),
                              buildIconItem('assets/icons/ic_kkukku.png', 2),
                              buildIconItem('assets/icons/ic_kkokko.png', 3),
                              buildIconItem('assets/icons/ic_sangzzi.png', 4),
                              buildIconItem('assets/icons/ic_nyang.png', 5),
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
              onTap1: () async {
                await logout(); // 로그아웃 수행
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

  // 프로필 업데이트
  Widget buildIconItem(String assetPath, int profileId) {
    return Padding(
      padding: const EdgeInsets.only(top: 26.0),
      child: GestureDetector(
        onTap: () async {
          if (studentId != null) {
            // 프로필 이미지를 변경하고 서버에 업데이트
            setState(() {
              profileImage = assetPath;
            });

            bool success = await DbConn.updateProfile(studentId!, profileId);
            if (success) {
              _showToast("프로필 이미지가 변경되었습니다.");
            } else {
              _showToast("프로필 변경 실패. 다시 시도해 주세요.");
            }
          } else {
            _showToast("로그인 정보가 없습니다.");
          }
        },
        child: CircleAvatar(
          radius: 27.5,
          backgroundImage: AssetImage(assetPath),
        ),
      ),
    );
  }

  // 닉네임 수정 다이얼로그
  Future<void> _showEditNicknameDialog() async {
    _nicknameController.text = nickname ?? ''; // 기존 닉네임을 텍스트 필드에 채우기

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          // 배경색 흰색으로 설정
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // 덜 둥근 형태로 설정
          ),
          title: const Text(
            '닉네임 수정',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            height: 50,
            child: Center(
              child: TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 다이얼로그 닫기
                Navigator.of(context).pop();
              },
              child: const Text('취소',
                  style: TextStyle(fontSize: 16, color: ColorStyles.darkGrey)),
            ),
            TextButton(
              onPressed: () async {
                // 닉네임 업데이트 로직 실행
                await _updateNickname();
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('저장',
                  style: TextStyle(fontSize: 16, color: ColorStyles.mainBlue)),
            ),
          ],
        );
      },
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
