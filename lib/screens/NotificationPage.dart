import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../DbConn.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications(); // 저장된 알림 내역 불러오기
  }

  // 저장된 알림 내역 불러오기
  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNotifications = prefs.getString('notifications') ?? '[]';
    setState(() {
      notifications = List<Map<String, dynamic>>.from(json.decode(savedNotifications));
    });
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
        padding: const EdgeInsets.all(10.0),
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
                const SizedBox(width: 117),
                const Text(
                  '알림',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: notifications.isEmpty
                  ? const Center(child: Text('알림 내역이 없습니다.'))
                  : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final isComment = notification['type'] == 'comment';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: ColorStyles.borderGrey,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Image.asset(
                          isComment
                              ? 'assets/icons/ic_comment.png'
                              : 'assets/icons/ic_notice.png',
                          width: 24,
                          height: 24,
                        ),
                        title: Text(
                          notification['title'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          notification['content'],
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Text(
                          notification['date'],
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
    ),
    ),
    );
  }
}