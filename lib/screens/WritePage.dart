import 'package:flutter/material.dart';
import 'package:hansung_where/theme/colors.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:hansung_where/PostUploader.dart';
import 'package:hansung_where/DbConn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WritePage extends StatefulWidget {
  final String type;

  WritePage({required this.type});

  @override
  _WritePageState createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final PostUploader _postUploader = PostUploader();

  final List<File?> selectedImages = [null, null, null, null]; // 최대 4개 이미지

  Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString('studentId');
    return int.tryParse(studentId ?? '') ?? 2211062; // 문자열을 정수로 변환, 실패 시 0 반환
  }

  Future<void> _pickImage() async {
    if (selectedImages.where((img) => img != null).length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("최대 4개까지 추가할 수 있습니다."),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        for (int i = 0; i < selectedImages.length; i++) {
          if (selectedImages[i] == null) {
            selectedImages[i] = File(image.path);
            break;
          }
        }
      });
    }
  }

  Future<void> uploadImagesToFirebase() async {
    if (selectedImages.every((image) => image == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업로드할 이미지를 선택해주세요.')),
      );
      return;
    }

    try {
      List<String> uploadedUrls = [];

      for (int i = 0; i < selectedImages.length; i++) {
        if (selectedImages[i] != null) {
          String downloadUrl = await _postUploader.uploadImage(selectedImages[i]!, i + 1);
          uploadedUrls.add(downloadUrl);
          print("Uploaded image URL: $downloadUrl"); // 업로드된 URL 출력
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 업로드 완료: ${uploadedUrls.length}개')),
      );
    } catch (e) {
      print("Error uploading images: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 업로드 중 오류가 발생했습니다: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorStyles.seedColor,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/icons/ic_back.png', height: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          widget.type == 'found' ? '습득물' : '분실물',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Neo',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty || contentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('제목과 내용을 입력해주세요.')),
                  );
                  return;
                }

                // 선택된 이미지 파일만 필터링
                List<File> imageFiles = selectedImages.whereType<File>().toList();

                try {
                  int userId = await getUserId();
                  // Firebase Storage 업로드
                  List<String> uploadedUrls = [];
                  for (int i = 0; i < imageFiles.length; i++) {
                    String downloadUrl = await _postUploader.uploadImage(imageFiles[i], i + 1);
                    uploadedUrls.add(downloadUrl);
                  }

                  // MySQL에 게시글 저장
                  bool isSuccess = await DbConn.savePost(
                    title: titleController.text,
                    body: contentController.text,
                    userId: userId, // 사용자 ID
                    imageUrl1: uploadedUrls.isNotEmpty ? uploadedUrls[0] : null,
                    imageUrl2: uploadedUrls.length > 1 ? uploadedUrls[1] : null,
                    imageUrl3: uploadedUrls.length > 2 ? uploadedUrls[2] : null,
                    imageUrl4: uploadedUrls.length > 3 ? uploadedUrls[3] : null,
                    type: widget.type, // WritePage에서 전달받은 type 값
                    place: '서울', // 장소 키워드
                    thing: '지갑', // 물건 키워드
                  );

                  if (isSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('게시물이 저장되었습니다.')),
                    );
                    Navigator.pop(context); // 메인 화면으로 돌아가기
                  } else {
                    throw Exception("게시물 저장 실패");
                  }
                } catch (e) {
                  print("Error: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('오류 발생: $e')),
                  );
                }
              },


              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF042D6F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
              ),
              child: Text(
                '등록',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Neo',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목과 내용 입력 필드
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: '제목',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Neo',
                        fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    color: Colors.grey.shade300,
                    thickness: 1,
                  ),
                  TextField(
                    controller: contentController,
                    maxLines: 16,
                    decoration: InputDecoration(
                      hintText: '내용을 최소 10글자 이상 작성하세요. \n\n찾아부기는 누구나 기분 좋게 참여할 수 있는 커뮤니티를 만들기 위해 이용 규칙을 제정하여 운영하고 있습니다. 위반 시 게시물이 삭제되며 서비스 이용이 일정 기간 제한될 수 있습니다.\n\n'
                          '  • 타인의 권리를 침해하거나 불쾌감을 주는 행위\n'
                          '  • 범죄, 불법 행위 등 법령 위반하는 행위\n'
                          '  • 욕설, 비하, 차별, 혐오, 폭력 관련 내용을 포함한 게시글을 작성하는 행위\n'
                          '  •  음란물, 성적 수치심을 유발하는 행위\n'
                          '  • 스포일러, 공포, 속임, 놀라게 하는 행위',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontSize: 14, fontFamily: 'Neo'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            // 이미지 추가 버튼과 슬롯
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end, // 오른쪽 정렬
                  children: [

                    Text(
                      "( ${selectedImages.where((img) => img != null).length} / 4 )",
                      style: TextStyle(fontSize: 11, fontFamily: 'Neo')
                    ),
                    SizedBox(width: 2), // 텍스트와 카메라 버튼 사이 간격
                    IconButton(
                      icon: Image.asset('assets/icons/ic_camera.png', height: 24),
                      onPressed: _pickImage,
                    ),
                  ],
                ),


                SizedBox(height: 2),
                // 이미지 슬롯들
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    4,
                        (index) => Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: Colors.white, // 슬롯 배경을 흰색으로 설정
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        image: selectedImages[index] != null
                            ? DecorationImage(
                            image: FileImage(selectedImages[index]!),
                            fit: BoxFit.cover,
                        )
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
