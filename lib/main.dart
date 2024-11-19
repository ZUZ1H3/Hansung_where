import 'package:flutter/material.dart';
import 'package:hansung_where/theme/colors.dart';

import 'mainPages/ChatPage.dart';
import 'mainPages/HomePage.dart';
import 'mainPages/MapPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // DEBUG 제거
      theme: ThemeData(
        fontFamily: 'Neo-regular',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        scaffoldBackgroundColor: ColorStyles.seedColor,
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
  int _selectedIndex = 1;
  final List<Widget> _pages = [
    MapPage(),
    HomePage(),
    ChatPage()
  ];

  List<BottomNavigationBarItem> bottomItems = [
    const BottomNavigationBarItem(
      label: '지도',
      icon: ImageIcon(AssetImage('assets/pin.png'), size: 32),
    ),
    const BottomNavigationBarItem(
      label: '홈',
      icon: ImageIcon(AssetImage('assets/home.png'), size: 32),
    ),
    const BottomNavigationBarItem(
      label: '채팅',
      icon: ImageIcon(AssetImage('assets/chat.png'), size: 32),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: ColorStyles.mainBlue,
          // 하단 바 배경 색상
          selectedItemColor: Colors.white,
          // 선택된 아이템 색상
          unselectedItemColor: ColorStyles.navGrey,
          currentIndex: _selectedIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: bottomItems),
    );
  }
}
