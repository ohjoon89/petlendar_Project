import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  static const List<String> _titles = [
    "홈 화면",
    "리스트",
    "캘린더",
    "사진첩",
    "설정",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white), //배경 색상
        splashColor: Colors.transparent, // 잉크 번짐 제거
        highlightColor: Colors.transparent, // 하이라이트 제거

      ),
      home: Scaffold(
        body: Center(
          child: Text(
            _titles[_selectedIndex],
            style: const TextStyle(fontSize: 24),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // 5개 이상일 때 필요
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: '리스트',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: '캘린더',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt),
              label: '사진첩',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '설정',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color.fromARGB(255, 44, 44, 44),
          unselectedItemColor: const Color.fromARGB(255, 129, 129, 129),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
