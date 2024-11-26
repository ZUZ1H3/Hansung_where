import 'package:flutter/material.dart';
import 'package:hansung_where/theme/colors.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class WritePage extends StatefulWidget {
  final String type;

  WritePage({required this.type});

  @override
  _WritePageState createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  final List<File?> selectedImages = [null, null, null, null]; // 최대 4개 이미지

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
              onPressed: () {
                // 저장 버튼
                print('제목: ${titleController.text}');
                print('내용: ${contentController.text}');
                print(
                    '이미지 개수: ${selectedImages.where((img) => img != null).length}');
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
