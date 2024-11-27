import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../DbConn.dart';

class NotiSetting extends StatefulWidget {
  @override
  _NotiSettingState createState() => _NotiSettingState();
}

class _NotiSettingState extends State<NotiSetting> {
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
                const SizedBox(width: 102),
                const Text(
                  '알림 설정',
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
