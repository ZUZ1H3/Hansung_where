import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isDrawerOpen = false; // 서랍 상태를 관리하는 변수
  String? selectedChat; // 선택된 채팅
  final List<Map<String, dynamic>> chatList = [ // 화면 미리 보기
    {'name': '분홍샌들의치타', 'message': '제 바람막이 어디있어요?', 'unreadCount': 3},
    {'name': '고구마붕어빵', 'message': '미래관 지하에서 본 것 같아요!', 'unreadCount': 1},
    {'name': '민들레복숭아', 'message': '좋은 하루 보내세요', 'unreadCount': 0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '쪽지함',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // 채팅 목록
          ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            itemCount: chatList.length,
            itemBuilder: (context, index) {
              final chat = chatList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12.0),
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  leading: CircleAvatar(
                    radius: 24.0,
                    backgroundColor: Colors.blue,
                    child: Text(
                      chat['name'][0], // 이름의 첫 글자 표시
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    chat['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(chat['message']),
                  trailing: chat['unreadCount'] > 0
                      ? CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${chat['unreadCount']}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                      : null,
                  onTap: () {
                    setState(() {
                      isDrawerOpen = true;
                      selectedChat = chat['name'];
                    });
                  },
                ),
              );
            },
          ),

          // 하단 드로어 배경
          if (isDrawerOpen)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  isDrawerOpen = false;
                  selectedChat = null;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.5), // 반투명 검정 배경
              ),
            ),

          // 하단 드로어
          if (isDrawerOpen)
            Align(
              alignment: Alignment.bottomCenter,
              child: DraggableScrollableSheet(
                initialChildSize: 0.4,
                minChildSize: 0.2,
                maxChildSize: 0.8,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            '$selectedChat와의 대화',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: 5, // 채팅 메시지 예제
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16.0,
                                      backgroundColor: Colors.grey,
                                      child: Text(
                                        selectedChat != null
                                            ? selectedChat![0]
                                            : '',
                                        style:
                                        const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12.0),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0F0F0),
                                          borderRadius:
                                          BorderRadius.circular(12.0),
                                        ),
                                        child: Text(
                                          '메시지 내용 ${index + 1}',
                                          style: const TextStyle(fontSize: 14.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
