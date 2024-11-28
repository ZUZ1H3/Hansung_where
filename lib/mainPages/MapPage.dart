import 'package:flutter/material.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
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

  @override
  void initState() {
    super.initState();
    // 초기 확대 비율 설정 (1.5배 확대)
    _transformationController.value = Matrix4.identity()..scale(1.5);
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
                  return Positioned(
                    left: pin.dx, // X 좌표
                    top: pin.dy, // Y 좌표
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
                      child: Image.asset(
                        'assets/icons/ic_pin.png',
                        width: 32, // 핀 이미지의 너비
                        height: 45, // 핀 이미지의 높이
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

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }
}
