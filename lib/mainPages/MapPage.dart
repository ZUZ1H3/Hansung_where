import 'package:flutter/material.dart';
import '/DbConn.dart'; // DbConn 임포트

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  double _scaleFactor = 1.0; // 현재 확대/축소 비율
  double minScale = 1.0;
  double maxScale = 4.0;
  final TransformationController _transformationController =
      TransformationController();

  // 핀의 위치 목록 (Offset으로 좌표 지정)
  final List<Offset> pins = [
    Offset(290, 250), // 원스톱
    Offset(350, 380), // 학식당
    Offset(340, 280), // 학술정보관
    Offset(200, 350), // 상상파크
    Offset(240, 500), // 상상빌리지
  ];

  // 장소 이름 목록
  final List<String> places = [
    '원스톱',
    '학식당',
    '학술정보관',
    '상상파크',
    '상상빌리지',
  ];

  // 각 장소에 대한 게시물 수를 저장할 맵
  Map<String, int> placePostCounts = {};

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged); // 리스너 추가
    // 초기 확대 비율 설정 (1.5배 확대)
    _transformationController.value = Matrix4.identity()..scale(1.5);
    _loadPostCounts(); // 페이지 로드 시 게시물 수 미리 로드
  }

  void _onTransformationChanged() {
    setState(() {
      _scaleFactor =
          _transformationController.value.getMaxScaleOnAxis(); // 확대/축소 비율 계산
    });
  }

  void dispose() {
    _transformationController
        .removeListener(_onTransformationChanged); // 리스너 제거
    _transformationController.dispose();
    super.dispose();
  }

  // 게시물 수를 처음 로드하는 함수
  Future<void> _loadPostCounts() async {
    for (String place in places) {
      // 이미 캐시에 데이터가 없다면 MySQL에서 게시물 수를 가져옴
      if (!placePostCounts.containsKey(place)) {
        final count = await DbConn.getFoundPostCount(place);
        setState(() {
          placePostCounts[place] = count; // 데이터를 캐시에 저장
        });
      }
    }
  }

  // MySQL에서 장소별 게시물 수를 가져오는 함수
  Future<int> _getFoundPostCount(String place) async {
    return placePostCounts[place] ?? 0; // 캐시된 데이터를 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;
          final double screenHeight = constraints.maxHeight;

          return InteractiveViewer(
            minScale: minScale,
            maxScale: maxScale,
            constrained: false,
            transformationController: _transformationController,
            child: Stack(
              children: [
                // 지도 이미지
                Center(
                  child: Image.asset(
                    'assets/map.png',
                    height: screenHeight,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                // 핀들 추가
                ...pins.map((pin) {
                  final place = places[pins.indexOf(pin)]; // 핀에 해당하는 장소 이름을 가져옴
                  return Positioned(
                    left: pin.dx, // X 좌표
                    top: pin.dy, // Y 좌표
                    child: Transform.scale(
                      scale: 1 / _scaleFactor, // 확대/축소 비율의 역수로 핀 크기 고정
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('핀 정보'),
                              content: Text('핀 위치: (${pin.dx}, ${pin.dy})'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('닫기'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Stack(
                          clipBehavior: Clip.none, // 스택의 자식이 잘리지 않도록 설정
                          children: [
                            Image.asset(
                              'assets/icons/ic_pin.png', // 핀 아이콘
                              width: 32, // 핀의 기본 너비
                              height: 45, // 핀의 기본 높이
                            ),
                            // 핀 위에 "5건" 같은 텍스트 표시
                            Positioned(
                              top: -30, // 위치 조정
                              left: -4, // 위치 조정
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  // 배경색을 화이트로 설정
                                  borderRadius: BorderRadius.circular(12),
                                  // 테두리 둥글게
                                  border: Border.all(
                                    color: Color(0xFF042D6F), // 테두리 색상: #042D6F
                                    width: 1, // 테두리 두께
                                  ),
                                ),
                                child: Text(
                                  '${placePostCounts[place] ?? 0}건', // 게시물 수 표시
                                  style: TextStyle(
                                    color: Colors.black, // 텍스트 색상: 검정색
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
          );
        },
      ),
    );
  }
}
