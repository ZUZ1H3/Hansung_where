import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../CustomSearcherBar.dart';
import 'SearchResultPage.dart';
import '../DbConn.dart'; // MySQL 연결을 위한 DbConn import
import '../theme/colors.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  List<String> recentSearches = []; // 최근 검색어
  List<String> trendingKeywords = []; // MySQL에서 가져올 실시간 검색어

  @override
  void initState() {
    super.initState();
    fetchTrendingKeywords(); // MySQL에서 실시간 검색어 가져오기
    loadRecentSearches(); // SharedPreferences에서 최근 검색어 로드
  }

  /// SharedPreferences에서 최근 검색어 로드
  Future<void> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList('recentSearches') ?? [];
    setState(() {
      recentSearches = searches;
    });
  }

  /// SharedPreferences에 최근 검색어 저장
  Future<void> saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('recentSearches', recentSearches);
  }

  /// MySQL에서 실시간 검색어 상위 5개 가져오기
  Future<void> fetchTrendingKeywords() async {
    try {
      final results =
          await DbConn.getTopSearchKeywords(limit: 5); // DbConn에서 쿼리 실행
      setState(() {
        trendingKeywords = results;
      });
      print("실시간 검색어 로드 성공: $trendingKeywords");
    } catch (e) {
      print('실시간 검색어 불러오는 중 오류 발생: $e');
    }
  }

  void navigateToSearchResult(String keyword) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResult(keyword: keyword),
      ),
    );

    // 결과가 true라면 최근 검색어를 다시 로드
    if (result == true) {
      loadRecentSearches();
    }
  }

  /// MySQL에 검색 키워드 저장
  Future<void> saveSearchKeyword(String keyword) async {
    if (keyword.isEmpty) return;

    try {
      await DbConn.saveSearchKeyword(keyword); // DbConn 메서드 호출
    } catch (e) {
      print('검색어 저장 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: CustomSearchBar(
          controller: searchController,
          onSearch: (keyword) {
            if (keyword.isEmpty) return;

            // 최근 검색어에 추가
            setState(() {
              if (!recentSearches.contains(keyword)) {
                recentSearches.insert(0, keyword);
                if (recentSearches.length > 100) {
                  recentSearches = recentSearches.sublist(0, 100);
                }
              }
            });

            saveRecentSearches();
            saveSearchKeyword(keyword);

            navigateToSearchResult(keyword);
          },
          onBackPressed: () {
            Navigator.pop(context); // 뒤로가기 동작
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '실시간 검색어',
              style: TextStyle(
                  fontSize: 14, fontFamily: 'Neo', fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 7),
            Padding(
              padding: const EdgeInsets.only(left: 14), // 왼쪽에서 14만큼 이동
              child: Wrap(
                spacing: 8.0,
                children: trendingKeywords.map((keyword) {
                  return GestureDetector(
                    onTap: () {
                      navigateToSearchResult(keyword);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
                      decoration: BoxDecoration(
                        color: ColorStyles.mainBlue, // 배경색
                        borderRadius: BorderRadius.circular(12), // 둥근 모서리
                      ),
                      child: Text(
                        keyword,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12, // 글자 크기
                          fontFamily: 'Neo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 26),
            Text(
              '최근 검색어',
              style: TextStyle(
                  fontSize: 14, fontFamily: 'Neo', fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 8),
            if (recentSearches.isNotEmpty)
              Column(
                children: recentSearches.map((search) {
                  bool isPlace = places.contains(search);
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            isPlace
                                ? 'assets/icons/ic_placePin.png'
                                : 'assets/icons/ic_search.png',
                            color: Colors.black,
                            width: 15,
                            height: 15,
                          ),
                          SizedBox(width: 10), // 아이콘과 글자 사이 간격
                          GestureDetector(
                            onTap: () {
                              navigateToSearchResult(search);
                            },
                            child: Text(
                              search,
                              style: TextStyle(
                                fontSize: 12, // 글자 크기
                                color: Colors.black, // 글자 색상
                                fontFamily: 'Neo',
                              ),
                            ),
                          ),
                          Spacer(), // 빈 공간 추가하여 오른쪽 정렬
                          IconButton(
                            padding: EdgeInsets.zero, // IconButton 패딩 제거
                            constraints: BoxConstraints(), // 기본 여백 및 크기 제한 제거
                            icon: Image.asset(
                              'assets/icons/ic_x.png',
                              width: 10, // 아이콘 크기 조정
                              height: 10, // 아이콘 크기 조정
                            ),
                            onPressed: () {
                              setState(() {
                                recentSearches.remove(search);
                              });
                              saveRecentSearches();
                            },
                          ),
                        ],
                      ),
                      Divider(
                        color: Color(0xFFE0E0E0), // 구분선 색상을 E0E0E0로 설정
                        thickness: 1, // 구분선 두께
                        indent: 0, // 왼쪽 여백 제거
                        endIndent: 0, // 오른쪽 여백 제거
                        height: 0, // 구분선과 ListTile 사이 간격 제거
                      ),
                    ],
                  );
                }).toList(),
              )
            else
              Text(
                '최근 검색어가 없습니다.',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontFamily: 'Neo',
                    fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  // 장소 리스트
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
}
