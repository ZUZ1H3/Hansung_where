import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'DbConn.dart';

class PostUploader {
  final FirebaseStorage _storage = FirebaseStorage.instance;


  /// 이미지 업로드
  Future<String> uploadImage(File imageFile, int index) async {
    try {
      final String timestamp = DateTime.now().toIso8601String();
      final String fileName = "images/${timestamp}_$index.jpg";
      print("Uploading to path: $fileName"); // 경로 출력

      // Firebase Storage 참조 생성 및 업로드
      final Reference storageRef = _storage.ref().child(fileName);
      final UploadTask uploadTask = storageRef.putFile(imageFile);

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print("Image uploaded: $downloadUrl"); // 업로드된 URL 확인

      return downloadUrl; // 업로드 성공 시 다운로드 URL 반환
    } catch (e) {
      print("Image upload error: $e");
      throw Exception("Image upload failed: $e");
    }
  }

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

    // Firebase Storage에 이미지 업로드 작업 생성
    for (int i = 0; i < imageFiles.length; i++) {
      uploadTasks.add(uploadImage(imageFiles[i], i + 1));
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
