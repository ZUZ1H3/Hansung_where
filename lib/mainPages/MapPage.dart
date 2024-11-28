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

  @override
  void initState() {
    super.initState();
    // 초기 확대 비율 설정 (2배 확대)
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
            child: Center(
              child: Image.asset(
                'assets/map.png',
                height: screenHeight,
                fit: BoxFit.fitHeight,
              ),
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
