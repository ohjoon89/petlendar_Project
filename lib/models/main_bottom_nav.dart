import 'package:flutter/material.dart';
import '../home_page.dart';
import '../album_screen.dart';
import '../setting_screen.dart';
import '../calendar_screen.dart';

class MainBottomNav extends StatefulWidget {
  const MainBottomNav({super.key});

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    Center(child: Text("리스트 페이지", style: TextStyle(fontSize: 24))),
    CalendarScreen(),
    AlbumScreen(),
    SettingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: '리스트'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '캘린더'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: '사진첩'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 44, 44, 44),
        unselectedItemColor: Color.fromARGB(255, 129, 129, 129),
        onTap: _onItemTapped,
      ),
    );
  }
}
