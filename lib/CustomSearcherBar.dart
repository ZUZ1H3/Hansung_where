import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final VoidCallback onBackPressed;

  const CustomSearchBar({
    Key? key,
    required this.controller,
    required this.onSearch,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F9FB),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBackPressed, // 뒤로가기 동작
                child: Image.asset(
                  'assets/icons/ic_back.png',
                  width: 14, // 아이콘의 크기 설정
                  height: 26,
                ),
              ),
              const SizedBox(width: 16), // 텍스트와 검색창 사이 간격
              Expanded(
                child: Container(
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: controller,
                    textAlignVertical: TextAlignVertical.center,
                    // 수직 가운데 정렬
                    style: TextStyle(
                      fontFamily: 'Neo', // Neo 폰트 적용
                      fontSize: 14, // 적절한 폰트 크기 설정
                      color: Colors.black,
                    ),

                    decoration: InputDecoration(
                      hintText: '검색어를 입력하세요',
                      hintStyle: TextStyle(
                        fontFamily: 'Neo', // Neo 폰트 적용
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                      isCollapsed: true, // 내부 패딩이 없을 때 텍스트 중앙 정렬
                      contentPadding: EdgeInsets.symmetric( horizontal: 6), // 패딩 설정
                      suffixIcon: IconButton(
                        icon: Image.asset(
                          'assets/icons/ic_search.png', // 커스텀 이미지 경로
                          width: 20, // 아이콘 크기 설정
                          height: 20,
                        ),
                        onPressed: () {
                          onSearch(controller.text);
                        },
                      ),
                    ),
                    onSubmitted: onSearch,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
