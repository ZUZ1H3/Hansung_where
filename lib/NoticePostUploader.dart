import 'package:flutter/material.dart';
import '/DbConn.dart';

class NoticePostUploader {
  /// 공지사항 업로드 및 저장
  Future<void> uploadAndSaveNoticePost({
    required String title,
    required String body,
    required int managerId,
    required BuildContext context,
  }) async {
    try {
      // MySQL에 공지사항 저장
      bool isSuccess = await DbConn.saveNoticePost(
        title: title,
        body: body,
        managerId: managerId,
      );

      if (isSuccess) {
        // 성공 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('공지사항이 저장되었습니다.')),
        );
        Navigator.pop(context); // 메인 화면으로 돌아가기
      } else {
        throw Exception("공지사항 저장 실패");
      }
    } catch (e) {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    }
  }
}
