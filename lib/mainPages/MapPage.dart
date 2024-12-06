import 'package:flutter/material.dart';
import '/DbConn.dart'; // DbConn 임포트
import '/PostCard.dart'; // PostCard 위젯
import '/Post.dart'; // Post 모델

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  double _scaleFactor = 1.0;
  double minScale = 1.0;
  double maxScale = 4.0;
  final TransformationController _transformationController =
  TransformationController();

  final List<Offset> pins = [
    Offset(290, 250),
    Offset(350, 380),
    Offset(340, 280),
    Offset(200, 350),
    Offset(240, 500),
  ];

  final List<String> places = [
    '원스톱',
    '학식당',
    '학술정보관',
    '상상파크',
    '상상빌리지',
  ];

  Map<String, int> placePostCounts = {};

  bool isDrawerOpen = false; // 서랍 상태를 관리하는 변수
  String? selectedPlace; // 선택된 장소

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged);
    _transformationController.value = Matrix4.identity()..scale(1.5);
    _loadPostCounts();
  }

  void _onTransformationChanged() {
    setState(() {
      _scaleFactor = _transformationController.value.getMaxScaleOnAxis();
    });
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadPostCounts() async {
    for (String place in places) {
      if (!placePostCounts.containsKey(place)) {
        final count = await DbConn.getFoundPostCount(place);
        setState(() {
          placePostCounts[place] = count;
        });
      }
    }
  }

  Future<List<Post>> _getPostsByPlace(String place) async {
    return await DbConn.fetchPosts(type: 'found', placeKeyword: place);
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenHeight = constraints.maxHeight;

          return Stack(
            children: [
              // 지도 및 핀
              InteractiveViewer(
                minScale: minScale,
                maxScale: maxScale,
                constrained: false,
                transformationController: _transformationController,
                child: Stack(
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/map.png',
                        height: screenHeight,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    ...pins.map((pin) {
                      final place = places[pins.indexOf(pin)];
                      return Positioned(
                        left: pin.dx,
                        top: pin.dy,
                        child: Transform.scale(
                          scale: 1 / _scaleFactor,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isDrawerOpen = true;
                                selectedPlace = place;
                              });
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Image.asset(
                                  'assets/icons/ic_pin.png',
                                  width: 32,
                                  height: 45,
                                ),
                                Positioned(
                                  top: -30,
                                  left: -4,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Color(0xFF042D6F),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      '${placePostCounts[place] ?? 0}건',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

              // 서랍이 열렸을 때 배경 어둡게 처리
              if (isDrawerOpen) ...[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      isDrawerOpen = false;
                    });
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.5), // 반투명 검정 배경
                  ),
                ),

                // 서랍
                Align(
                  alignment: Alignment.bottomCenter,
                  child: DraggableScrollableSheet(
                    initialChildSize: 0.2,
                    minChildSize: 0.2,
                    maxChildSize: 0.8,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 24, 0, 0),
                              child: Text(
                                '$selectedPlace - ${placePostCounts[selectedPlace] ?? 0} 건',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Neo',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: FutureBuilder<List<Post>>(
                                future: _getPostsByPlace(selectedPlace ?? ''),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(
                                      child: Text('게시물을 가져오는 중 오류가 발생했습니다.'),
                                    );
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return Center(
                                      child: Text('게시물이 없습니다.'),
                                    );
                                  } else {
                                    final posts = snapshot.data!;
                                    return ListView.builder(
                                      controller: scrollController,
                                      itemCount: posts.length,
                                      itemBuilder: (context, index) {
                                        return PostCard(
                                          post: posts[index],
                                          type: 'found',
                                          isForMapPage: true,
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
