import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import '../DbConn.dart';

class NotiSetting extends StatefulWidget {
  @override
  _NotiSettingState createState() => _NotiSettingState();
}

class _NotiSettingState extends State<NotiSetting> {
  final List<String> keywords = []; // 키워드를 저장하는 리스트
  final TextEditingController keywordController = TextEditingController();
  bool commentToggle = false;
  bool replyToggle = true;
  bool messageToggle = true;
  bool noticeToggle = true;
  bool keywordToggle = true;

  @override
  void initState() {
    super.initState();
    _loadKeywords(); // 앱 시작 시 저장된 키워드를 불러옴
  }

  // 키워드를 로컬에 저장
  Future<void> _saveKeywords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('keywords', keywords);
  }

  // 저장된 키워드를 불러오기
  Future<void> _loadKeywords() async {
    final prefs = await SharedPreferences.getInstance();
    final savedKeywords = prefs.getStringList('keywords') ?? [];
    setState(() {
      keywords.addAll(savedKeywords);
    });
  }

  void addKeyword(String keyword) {
    if (keyword.isNotEmpty) {
      setState(() {
        keywords.add(keyword);
        keywordController.clear();
      });
      _saveKeywords(); // 키워드 저장
    }
  }

  void removeKeyword(String keyword) {
    setState(() {
      keywords.remove(keyword);
    });
    _saveKeywords(); // 키워드 저장
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey[100], // 전체 배경색
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
                  const SizedBox(width: 100),
                  const Text(
                    '알림 설정',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              //
              const SizedBox(height: 40),
              // 알림받을 키워드 입력
              TextField(
                controller: keywordController,
                decoration: InputDecoration(
                  hintText: '알림받을 키워드를 입력해주세요.',
                  hintStyle: TextStyle(color: Color(0xFF9F9F9F)),
                  fillColor: Colors.white, // 배경색
                  filled: true, // 배경 활성화
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(0xFFEDEDED),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(0xFFEDEDED),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(0xFFEDEDED), // 포커스 상태 테두리 색상
                    ),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 18),
                    child: IconButton(
                      icon: const Text(
                        '등록',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () => addKeyword(keywordController.text),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 알림받는 키워드 섹션
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '알림받는 키워드',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10), // 오른쪽 간격 추가
                    child: Switch(
                      value: keywordToggle,
                      onChanged: (value) {
                        setState(() {
                          keywordToggle = value;
                        });
                      },
                      activeColor: Colors.white,
                      activeTrackColor: Color(0xFF042D6F),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey[300],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // 키워드 리스트
              Wrap(
                spacing: 0.0,
                runSpacing: 8.0,
                children: keywords
                    .map(
                      (keyword) => Container(
                    width: double.infinity, // 부모 크기만큼 너비 확장
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color(0xFFEDEDED),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '# $keyword',
                          style: const TextStyle(color: Colors.black),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () => removeKeyword(keyword),
                        ),
                      ],
                    ),
                  ),
                )
                    .toList(),
              ),
              const SizedBox(height: 20),
              //const Divider(), //댓글 위 회색 선
              // 댓글, 답글, 쪽지, 공지사항 섹션
              Column(
                children: [
                  buildNotificationItem('댓글', commentToggle, (value) {
                    setState(() {
                      commentToggle = value;
                    });
                  }),
                  buildNotificationItem('답글', replyToggle, (value) {
                    setState(() {
                      replyToggle = value;
                    });
                  }),
                  buildNotificationItem('쪽지', messageToggle, (value) {
                    setState(() {
                      messageToggle = value;
                    });
                  }),
                  buildNotificationItem('공지사항', noticeToggle, (value) {
                    setState(() {
                      noticeToggle = value;
                    });
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 네모 박스 형태의 알림 항목 생성
  Widget buildNotificationItem(String title, bool toggleValue, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xFFEDEDED)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Switch(
            value: toggleValue,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Color(0xFF042D6F),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}
