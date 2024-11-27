import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../DbConn.dart';

class MyPost extends StatefulWidget {
  @override
  _MyPostState createState() => _MyPostState();
}

class _MyPostState extends State<MyPost> {
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
                const SizedBox(width: 100),
                const Text(
                  '내 게시글',
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
