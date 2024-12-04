import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isDrawerOpen = false; // 채팅창 활성 상태
  String? selectedChat; // 현재 선택된 채팅
  final List<Map<String, dynamic>> chatList = [
    {'name': '분홍샌들의치타', 'message': '제 바람막이 어디있어요?', 'unreadCount': 3},
    {'name': '고구마붕어빵', 'message': '미래관 지하에서 본 것 같아요!', 'unreadCount': 1},
    {'name': '민들레복숭아', 'message': '좋은 하루 보내세요', 'unreadCount': 0},
  ];

  final List<Map<String, dynamic>> messages = []; // 메시지 데이터
  final TextEditingController _messageController = TextEditingController(); // 입력 컨트롤러

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        messages.add({'text': text, 'isSentByMe': true}); // 내 메시지 추가
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isDrawerOpen
            ? Text(
          '$selectedChat와의 대화',
          style: const TextStyle(color: Colors.black),
        )
            : const Text(
          '쪽지함',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (isDrawerOpen) {
              setState(() {
                isDrawerOpen = false;
                selectedChat = null; // 선택 해제
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: isDrawerOpen
          ? Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                return Align(
                  alignment: message['isSentByMe']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 10.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: message['isSentByMe']
                          ? Colors.blue[100]
                          : const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(message['text']),
                  ),
                );
              },
            ),
          ),
          // 입력창
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: '메시지를 입력하세요...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      )
          : ListView.builder(
        padding:
        const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12),
                ),
              )
                  : null,
              onTap: () {
                setState(() {
                  isDrawerOpen = true;
                  selectedChat = chat['name'];
                  messages.clear();
                  messages.addAll([
                    {'text': '안녕하세요!', 'isSentByMe': false},
                  ]);
                });
              },
            ),
          );
        },
      ),
    );
  }
}
