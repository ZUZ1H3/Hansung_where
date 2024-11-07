import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Neo-regular',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List<BottomNavigationBarItem> bottomItems=[
    BottomNavigationBarItem(
        label: '지도',
        icon: Icon(Icons.pin_drop, size: 30),
  ),
    BottomNavigationBarItem(
      label: '홈',
      icon: Icon(Icons.home, size: 30),
    ),
    BottomNavigationBarItem(
      label: '채팅',
      icon: Icon(Icons.send, size: 30),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("메인페이지"),),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.mainBlue, // 하단 바 배경 색상
          selectedItemColor: Colors.white,  // 선택된 아이템 색상
          unselectedItemColor: Colors.navgrey,
          currentIndex: _selectedIndex,

          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: bottomItems),
      body: Container(),
    );
  }
}
