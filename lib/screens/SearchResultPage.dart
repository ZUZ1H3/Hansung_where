import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Post.dart';
import '../PostCard.dart';
import '../DbConn.dart';
import '../CustomSearcherBar.dart';

class SearchResult extends StatefulWidget {
  final String keyword;

  const SearchResult({Key? key, required this.keyword}) : super(key: key);

  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  late Future<List<Post>> searchResults;
  TextEditingController searchController = TextEditingController();

  final List<String> tags = ['전체', '원스톱', '학식당', '학술정보관', '상상빌리지', '상상파크'];
  String selectedTag = '전체';

  bool isNotificationEnabled = false; // 알림 설정 여부

  @override
  void initState() {
    super.initState();
    searchController.text = widget.keyword;
    searchResults = _fetchSearchResults(widget.keyword);
    _saveSearchKeyword(widget.keyword);
    _loadNotificationState(); // 알림 상태 로드
  }

  /// 알림 설정 여부를 Firebase에서 로드
  Future<void> _loadNotificationState() async {
    final firestore = FirebaseFirestore.instance;
    try {
      final doc =
      await firestore.collection('notifications').doc(widget.keyword).get();

      setState(() {
        isNotificationEnabled = doc.exists ? doc['enabled'] as bool : false;
      });
    } catch (e) {
      print('알림 상태 불러오기 실패: $e');
    }
  }

  /// 알림 설정 상태를 Firebase에 저장
  Future<void> _saveNotificationState(String keyword, bool enabled) async {
    final firestore = FirebaseFirestore.instance;
    try {
      final docRef = firestore.collection('notifications').doc(keyword);

      if (enabled) {
        await docRef.set({
          'keyword': keyword,
          'enabled': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.delete();
      }
    } catch (e) {
      print('알림 상태 저장 실패: $e');
    }
  }

  Future<List<Post>> _fetchSearchResults(String keyword) async {
    try {
      List<Post> posts = await DbConn.fetchPosts(type: 'found');
      return posts.where((post) {
        final matchesKeyword =
            post.title.contains(keyword) || post.body.contains(keyword);
        final matchesTag = selectedTag == '전체' || post.place == selectedTag;
        return matchesKeyword && matchesTag;
      }).toList();
    } catch (e) {
      throw Exception('게시물 찾는 중 오류 발생: $e');
    }
  }

  Future<void> _saveSearchKeyword(String keyword) async {
    if (keyword.isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recentSearches = prefs.getStringList('recentSearches') ?? [];

    if (!recentSearches.contains(keyword)) {
      recentSearches.insert(0, keyword);
      if (recentSearches.length > 100) {
        recentSearches = recentSearches.sublist(0, 100);
      }
      await prefs.setStringList('recentSearches', recentSearches);
    }

    final firestore = FirebaseFirestore.instance;
    try {
      final docRef = firestore.collection('search_keywords').doc(keyword);

      await firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);

        if (docSnapshot.exists) {
          transaction.update(docRef, {
            'count': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(docRef, {
            'keyword': keyword,
            'count': 1,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('키워드 저장 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: CustomSearchBar(
          controller: searchController,
          onSearch: (value) {
            setState(() {
              searchResults = _fetchSearchResults(value);
            });
            _saveSearchKeyword(value);
          },
          onBackPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: tags.map((tag) {
                final isSelected = selectedTag == tag;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTag = tag;
                      searchResults = _fetchSearchResults(searchController.text);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF042D6F)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Post>>(
              future: searchResults,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('해당 장소에 게시물이 없습니다.'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return PostCard(
                        post: snapshot.data![index],
                        type: 'search',
                      );
                    },
                  );
                }
              },
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.transparent,
            child: ElevatedButton.icon(
              onPressed: () async {
                setState(() {
                  isNotificationEnabled = !isNotificationEnabled;
                });
                await _saveNotificationState(searchController.text, isNotificationEnabled);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isNotificationEnabled
                          ? "'${searchController.text}' 키워드 알림 설정 완료"
                          : "'${searchController.text}' 키워드 알림 해제",
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isNotificationEnabled
                    ? Colors.grey
                    : const Color(0xFF042D6F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                minimumSize: const Size(200, 30),
              ),
              icon: Icon(
                isNotificationEnabled
                    ? Icons.notifications_active
                    : Icons.notifications_none,
                color: Colors.white,
              ),
              label: Text(
                isNotificationEnabled
                    ? "${searchController.text} 알림 해제"
                    : "${searchController.text} 알림 받기",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}