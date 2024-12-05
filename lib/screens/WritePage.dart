import 'package:flutter/material.dart';
import 'package:hansung_where/theme/colors.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:hansung_where/PostUploader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DbConn.dart';

class WritePage extends StatefulWidget {
  final String type;

  WritePage({required this.type});

  @override
  _WritePageState createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final PostUploader _postUploader = PostUploader(); // PostUploader 인스턴스 생성

  final List<File?> selectedImages = [null, null, null, null]; // 최대 4개 이미지
  String selectedPlace = "#장소"; // 초기 장소 값
  String selectedKeyword = "#물건"; // 초기 키워드 값

  late int postId; // 편집하기 버튼 클릭시에만 전달 받는 post_id
  List<String> imageUrls = []; // 불러온 이미지 경로를 저장할 리스트
  bool isDataLoaded = false; // 데이터 로드 완료 여부 플래그

  Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString('studentId');
    return int.tryParse(studentId ?? '') ?? -1; // 기본값 설정
  }

  /// 이미지 선택
  Future<void> _pickImage() async {
    if (selectedImages.where((img) => img != null).length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("최대 4개까지 추가할 수 있습니다.")),
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

  /// 이미지 제거
  void _removeImage(int index) {
    setState(() {
      if (index < selectedImages.length && selectedImages[index] != null) {
        // 로컬 이미지 삭제
        selectedImages[index] = null;
      } else if (index < imageUrls.length) {
        // 네트워크 이미지 삭제
        imageUrls.removeAt(index);
      }
    });
  }

  /// 게시물 업로드
  Future<void> _uploadPost() async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목과 내용을 입력해주세요.')),
      );
      return;
    } else if (contentController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('내용을 최소 10자 이상 작성해주세요.')),
      );
      return;
    } else if (selectedPlace == "#장소" || selectedKeyword == "#물건") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('장소와 물건 태그를 모두 선택해주세요.')),
      );
      return;
    }

    try {
      int userId = await getUserId();

      // 선택된 이미지에서 null 제거
      List<File> imageFiles = selectedImages.whereType<File>().toList();

      if (postId != 0) {
        // postId가 존재하면 게시물 업데이트
        final success = await DbConn.updatePost(
          postId: postId,
          title: titleController.text,
          body: contentController.text,
          placeKeyword: selectedPlace,
          thingKeyword: selectedKeyword,
          images: imageUrls,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('게시물이 성공적으로 업데이트되었습니다.')),
          );
          Navigator.pop(context); // 페이지 닫기
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('게시물 업데이트 중 오류가 발생했습니다.')),
          );
        }
      } else { // postId가 없으면 새 게시물 등록
        await _postUploader.uploadImagesAndSavePost(
          title: titleController.text,
          body: contentController.text,
          userId: userId,
          imageFiles: imageFiles,
          type: widget.type,
          place: selectedPlace,
          thing: selectedKeyword,
          context: context,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시물이 성공적으로 등록되었습니다.')),
        );
      }
    } catch (e) {
      print("Error uploading post: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시물 처리 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    // 전달받은 데이터를 null 안전하게 처리
    postId = args?['post_id'] as int? ?? 0;

    // postId가 유효할 때만 데이터를 불러옴
    if (postId != 0) {
      _loadPostData();
    }
  }

  // 게시물 불러오기
  Future<void> _loadPostData() async {
    final post = await DbConn.loadPostData(postId);

    if (post != null) {
      setState(() {
        titleController.text = post['title'];
        contentController.text = post['body'];
        if (!isDataLoaded) {
          selectedPlace = post['place_keyword']; // 초기 장소 값 설정
          selectedKeyword = post['thing_keyword']; // 초기 키워드 값 설정
        }
        imageUrls = post['image_urls'] as List<String>; // 이미지 URL 저장
        isDataLoaded = true; // 데이터 로드 완료
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시물을 불러오지 못했습니다.')),
      );
    }
  }

  /// 장소 선택 다이얼로그
  void _showPlaceDialog() async {
    List<String> places = [
      "원스톱",
      "학식당",
      "학술정보관",
      "상상빌리지",
      "상상파크",
      "상파플",
      "상상관",
      "미래관",
      "공학관",
      "우촌관",
      "탐구관",
      "인성관",
      "창의관",
      "낙산관",
      "진리관",
      "ROTC",
      "학송관",
      "연구관",
      "지선관",
      "체육관",
      "기타"
    ];

    String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String? tempSelectedPlace = selectedPlace;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "장소 키워드",
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Neo',
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.3,
                      ),
                      itemCount: places.length,
                      itemBuilder: (context, index) {
                        String place = places[index];
                        return ElevatedButton(
                          onPressed: () {
                            setState(() {
                              tempSelectedPlace = place;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tempSelectedPlace == place
                                ? Color(0xFF042D6F)
                                : Colors.white,
                            foregroundColor: tempSelectedPlace == place
                                ? Colors.white
                                : Colors.black,
                            side: BorderSide(
                              color: Color(0xFFC1C1C1),
                              width: 1.0,
                            ),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            place,
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Color(0xFF042D6F),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "취소",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, tempSelectedPlace);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF042D6F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "확인",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        selectedPlace = result;
      });
    }
  }

  void _showKeywordDialog() async {
    // 키워드 리스트
    List<Map<String, dynamic>> keywords = [
      {"assetName": "ic_bag", "label": "가방"},
      {"assetName": "ic_diamond", "label": "귀금속"},
      {"assetName": "ic_book", "label": "도서용품"},
      {"assetName": "ic_document", "label": "서류"},
      {"assetName": "ic_clothes", "label": "의류"},
      {"assetName": "ic_wallet", "label": "지갑"},
      {"assetName": "ic_sports", "label": "스포츠"},
      {"assetName": "ic_device", "label": "전자기기"},
      {"assetName": "ic_card", "label": "카드"},
      {"assetName": "ic_other", "label": "기타물품"},
    ];

    String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "분실물/습득물 키워드",
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Neo',
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // 키워드 버튼 그리드
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 3.0,
                      ),
                      itemCount: keywords.length,
                      itemBuilder: (context, index) {
                        bool isSelected =
                            selectedKeyword == keywords[index]['label'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedKeyword =
                                  keywords[index]['label']; // 선택 상태 업데이트
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  isSelected
                                      ? 'assets/icons/${keywords[index]['assetName']}_selected.png' // 선택된 상태
                                      : 'assets/icons/${keywords[index]['assetName']}.png',
                                  // 기본 상태
                                  width: 40, // 이미지 크기
                                  height: 40,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  keywords[index]['label'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Color(0xFF042D6F)
                                        : Colors.black,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontFamily: 'Neo',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Color(0xFF042D6F),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "취소",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, selectedKeyword); // 선택된 값 반환
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF042D6F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "확인",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // 다이얼로그 닫힌 후 선택된 값 반영
    if (result != null && result.isNotEmpty) {
      setState(() {
        selectedKeyword = result; // 상태에 반영
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
              onPressed: _uploadPost,
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
            // 제목 및 내용 입력 필드
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(
                    color: Colors.grey.shade300,
                    thickness: 1,
                  ),
                  TextField(
                    controller: contentController,
                    maxLines: 16,
                    decoration: InputDecoration(
                      hintText: '내용을 최소 10글자 이상 작성하세요.',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontSize: 14, fontFamily: 'Neo'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 키워드, 이미지 개수, 카메라 버튼을 나란히 배치
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우 간격 조정
                  children: [
                    // 키워드와 태그
                    Row(
                      children: [
                        Text(
                          "키워드",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Neo'),
                        ),
                        SizedBox(width: 10), // 키워드와 태그 간격

                        GestureDetector(
                          onTap: _showPlaceDialog,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Text(
                              selectedPlace,
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ),
                        SizedBox(width: 8), // 태그 간격
                        GestureDetector(
                          onTap: _showKeywordDialog, // 물건 태그 클릭 시 실행
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Text(
                              selectedKeyword,
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 이미지 개수와 카메라 버튼
                    Row(
                      children: [
                        Text(
                          "( ${selectedImages.where((img) => img != null).length} / 4 )",
                          style: TextStyle(fontSize: 11, fontFamily: 'Neo'),
                        ),
                        SizedBox(width: 2), // 텍스트와 카메라 버튼 간격
                        IconButton(
                          icon: Image.asset('assets/icons/ic_camera.png',
                              height: 24),
                          onPressed: _pickImage,
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 10), // 상단 Row와 이미지 슬롯 사이 간격

                // 이미지 슬롯들
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    4,
                        (index) => GestureDetector(
                      onTap: () => _removeImage(index), // 네모 박스 클릭 시 _removeImage 호출
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          image: (index < selectedImages.length && selectedImages[index] != null)
                              ? DecorationImage(
                            image: FileImage(selectedImages[index]!),
                            fit: BoxFit.cover,
                          )
                              : (index < imageUrls.length && imageUrls[index].isNotEmpty)
                              ? DecorationImage(
                            image: NetworkImage(imageUrls[index]),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
