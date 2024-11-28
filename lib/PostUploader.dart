import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hansung_where/Firebase.dart'; // FirebaseHelper 임포트
import 'DbConn.dart';

class PostUploader {
  final Firebase _firebaseHelper = Firebase(); // FirebaseHelper 인스턴스 생성

  /// 이미지 업로드 및 게시물 저장
  Future<void> uploadImagesAndSavePost({
    required String title,
    required String body,
    required int userId,
    required List<File> imageFiles,
    required String type,
    required String place,
    required String thing,
    required BuildContext context,
  }) async {
    List<Future<String>> uploadTasks = [];

    // FirebaseHelper를 사용하여 이미지 업로드 작업 생성
    for (int i = 0; i < imageFiles.length; i++) {
      uploadTasks.add(_firebaseHelper.uploadImage(imageFiles[i], i + 1));
    }

    try {
      // 모든 이미지 업로드 완료 대기
      List<String> uploadedUrls = await Future.wait(uploadTasks);

      // MySQL에 게시물 저장
      bool isSuccess = await DbConn.savePost(
        title: title,
        body: body,
        userId: userId,
        imageUrl1: uploadedUrls.length > 0 ? uploadedUrls[0] : null,
        imageUrl2: uploadedUrls.length > 1 ? uploadedUrls[1] : null,
        imageUrl3: uploadedUrls.length > 2 ? uploadedUrls[2] : null,
        imageUrl4: uploadedUrls.length > 3 ? uploadedUrls[3] : null,
        type: type,
        place: place,
        thing: thing,
      );

      if (isSuccess) {
        // 성공 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시물이 저장되었습니다.')),
        );
        Navigator.pop(context); // 메인 화면으로 돌아가기
      } else {
        throw Exception("게시물 저장 실패");
      }
    } catch (e) {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    }
  }
}