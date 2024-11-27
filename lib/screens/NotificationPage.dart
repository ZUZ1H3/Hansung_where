import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../DbConn.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
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
        ],
    ),
    ),
    );
  }
}