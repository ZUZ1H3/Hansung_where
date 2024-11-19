import 'package:flutter/material.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('지도 페이지', style: TextStyle(fontSize: 16)),
    );
  }
}

