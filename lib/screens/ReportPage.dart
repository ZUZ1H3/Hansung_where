import 'package:flutter/material.dart';
// ReportPage 기본 구조
class ReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('신고 내역'),
      ),
      body: Center(
        child: Text('신고 내역 페이지 내용이 여기에 표시됩니다.'),
      ),
    );
  }
}