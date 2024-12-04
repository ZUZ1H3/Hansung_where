import 'package:flutter/material.dart';

// InquiryHistoryPage 기본 구조
class InquiryHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('문의 내역'),
      ),
      body: Center(
        child: Text('문의 내역 페이지 내용이 여기에 표시됩니다.'),
      ),
    );
  }
}
