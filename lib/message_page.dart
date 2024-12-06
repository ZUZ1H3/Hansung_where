import 'package:flutter/material.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 알림의 payload 가져오기
    final String? payload = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      body: Center(
        child: Text(
          "알림 내용: $payload",
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}