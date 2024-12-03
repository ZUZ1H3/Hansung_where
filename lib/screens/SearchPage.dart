import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../CustomSearcherBar.dart';
import 'SearchResultPage.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  List<String> recentSearches = []; // 최근 검색어
  List<String> trendingKeywords = []; // Firestore에서 가져올 실시간 검색어

  @override
  void initState() {
    super.initState();
    fetchTrendingKeywords(); // Firestore에서 실시간 검색어 가져오기
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

  /// Firestore에서 실시간 검색어 상위 5개 가져오기
  Future<void> fetchTrendingKeywords() async {
    final firestore = FirebaseFirestore.instance;

    try {
      final querySnapshot = await firestore
          .collection('search_keywords') // Firestore 컬렉션 이름
          .orderBy('count', descending: true) // 검색 횟수 기준 내림차순 정렬
          .limit(5) // 상위 5개만 가져오기
          .get();

      // Firestore에서 데이터를 성공적으로 가져왔는지 확인
      if (querySnapshot.docs.isNotEmpty) {
        final keywords =
        querySnapshot.docs.map((doc) => doc['keyword'] as String).toList();

        // 상태 업데이트
        setState(() {
          trendingKeywords = keywords;
        });

        print("실시간 검색어 로드 성공: $trendingKeywords");
      } else {
        print("실시간 검색어가 없습니다.");
      }

      // 1시간 후 다시 호출하여 업데이트
      Future.delayed(Duration(hours: 1), fetchTrendingKeywords);
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

  /// Firestore에 검색 키워드 저장
  Future<void> saveSearchKeyword(String keyword) async {
    if (keyword.isEmpty) return;

    final firestore = FirebaseFirestore.instance;

    try {
      final docRef = firestore.collection('search_keywords').doc(keyword);

      await firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);

        if (docSnapshot.exists) {
          // 키워드가 이미 존재하면 count 증가
          transaction.update(docRef, {
            'count': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // 키워드가 없으면 새로 생성
          transaction.set(docRef, {
            'keyword': keyword,
            'count': 1,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('검색어 저장 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '실시간 검색어',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: trendingKeywords.map((keyword) {
                return ElevatedButton(
                  onPressed: () {
                    navigateToSearchResult(keyword);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF042D6F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    keyword,
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 24),
            Text(
              '최근 검색어',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            if (recentSearches.isNotEmpty)
              Column(
                children: recentSearches.map((search) {
                  return ListTile(
                    leading: Icon(Icons.history, color: Colors.grey),
                    title: Text(search),
                    trailing: IconButton(
                      icon: Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          recentSearches.remove(search);
                        });
                        saveRecentSearches();
                      },
                    ),
                    onTap: () {
                      navigateToSearchResult(search);
                    },
                  );
                }).toList(),
              )
            else
              Text(
                '최근 검색어가 없습니다.',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}