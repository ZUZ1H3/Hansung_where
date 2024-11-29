import 'package:flutter/material.dart';

// NoticePage 기본 구조
class NoticePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('공지사항'),
      ),
      body: Center(
        child: Text('공지사항 페이지 내용이 여기에 표시됩니다.'),
      ),
    );
  }
}