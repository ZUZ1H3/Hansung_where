import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class FirebaseHelper {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 이미지 업로드 메서드
  Future<String> uploadImage(File imageFile, int imageIndex) async {
    try {
      // 현재 시간 기반으로 고유 파일 이름 생성
      final String timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final String fileName = "images/${timestamp}_$imageIndex.jpg";

      // Firebase Storage에 파일 참조 생성
      final Reference storageRef = _storage.ref().child(fileName);

      // 이미지 업로드
      final UploadTask uploadTask = storageRef.putFile(imageFile);

      // 업로드 완료 후 다운로드 URL 가져오기
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl; // 성공적으로 업로드된 파일의 URL 반환
    } catch (e) {
      throw Exception("Image upload failed: $e");
    }
  }
}
