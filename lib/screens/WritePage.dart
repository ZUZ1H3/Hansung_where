import 'package:flutter/material.dart';
import 'package:hansung_where/theme/colors.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class WritePage extends StatefulWidget {
  @override
  _WritePageState createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  List<String> keywords = [];
  int maxKeywords = 4;

  final List<File?> selectedImages = [null, null, null, null]; // 최대 4개 이미지

  Future<void> _pickImage(int slotIndex) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImages[slotIndex] = File(image.path);
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
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          '글쓰기',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                // 저장 버튼 (나중에 MySQL 추가)
                print('제목: ${titleController.text}');
                print('내용: ${contentController.text}');
                print('키워드: $keywords');
                print('이미지 개수: ${selectedImages.where((img) => img != null).length}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF042D6F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: Text(
                '등록',
                style: TextStyle(color: Colors.white, fontSize: 14),
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
            // 제목 입력
            Container(
              color: Colors.white,
              child: TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: '제목',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                ),
                style: TextStyle(fontSize: 16),
              ),
            ),
            Divider(color: Colors.grey.shade300, thickness: 1),
            SizedBox(height: 16),

            // 내용 입력
            Container(
              color: Colors.white,
              child: TextField(
                controller: contentController,
                maxLines: 16,
                decoration: InputDecoration(
                  hintText:
                  '내용을 최소 10글자 이상 작성하세요. \n\n찾아부기는 누구나 기분 좋게 참여할 수 있는 커뮤니티를 만들기 위해 이용 규칙을 제정하여 운영하고 있습니다. 위반 시 게시물이 삭제되며 서비스 이용이 일정 기간 제한될 수 있습니다.\n\n'
                      '  • 타인의 권리를 침해하거나 불쾌감을 주는 행위\n'
                      '  • 범죄, 불법 행위 등 법령 위반하는 행위\n'
                      '  • 욕설, 비하, 차별, 혐오, 폭력 관련 내용을 포함한 게시글을 작성하는 행위\n'
                      '  •  음란물, 성적 수치심을 유발하는 행위\n'
                      '  • 스포일러, 공포, 속임, 놀라게 하는 행위',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                  border: InputBorder.none,
                ),
                style: TextStyle(fontSize: 14),
              ),
            ),
            Divider(color: Colors.grey.shade300, thickness: 1),
            SizedBox(height: 16),

            // 키워드 추가
            Row(
              children: [
                Text(
                  '키워드',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(width: 8),
                Wrap(
                  spacing: 8.0,
                  children: [
                    for (String keyword in keywords)
                      Chip(
                        label: Text(keyword),
                        deleteIcon: Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            keywords.remove(keyword);
                          });
                        },
                      ),
                  ],
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.camera_alt, color: Colors.black),
                  onPressed: () {
                    print('이미지 추가 버튼 클릭');
                  },
                ),
              ],
            ),
            SizedBox(height: 16),

            // 이미지 추가
            Row(
              children: List.generate(
                4,
                    (index) => GestureDetector(
                  onTap: () => _pickImage(index),
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      image: selectedImages[index] != null
                          ? DecorationImage(
                        image: FileImage(selectedImages[index]!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: selectedImages[index] == null
                        ? Center(
                      child: Icon(Icons.image, color: Colors.grey),
                    )
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
