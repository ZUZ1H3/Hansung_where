import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> chatList = [
    {'name': '분홍샌들의치타', 'message': '제 바람막이 어디있어요?', 'unreadCount': 3},
    {'name': '고구마붕어빵', 'message': '미래관 지하에서 본 것 같아요!', 'unreadCount': 1},
    {'name': '민들레복숭아', 'message': '좋은 하루 보내세요!', 'unreadCount': 0},
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
          icon: const Text(
            '<',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
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
                // 채팅 선택 시 ChattingPage로 이동
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ChattingPage(),
                //   ),
                // );
              },
            ),
          );
        },
      ),
    );
  }
}
