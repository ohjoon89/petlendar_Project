import 'package:flutter/material.dart';
import '../home_page.dart';
import '../album_screen.dart';
import '../setting_screen.dart';
import '../calendar_screen.dart';
import 'pet_profile.dart';
import 'profile_View_page.dart';

class MainBottomNav extends StatefulWidget {
  const MainBottomNav({super.key});

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  int _selectedIndex = 0;
  DateTime? _lastTapTime;
  PetProfile? _lastViewedProfile;


  void updateLastViewedProfile(PetProfile profile) {
      _lastViewedProfile = profile;
    }

  final List<Widget> _pages = const [
    HomePage(),
    Center(child: Text("리스트 페이지", style: TextStyle(fontSize: 24))),
    CalendarScreen(),
    AlbumScreen(),
    SettingScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 0) {
      DateTime now = DateTime.now();
      if (_lastTapTime != null &&
          now.difference(_lastTapTime!) < const Duration(milliseconds: 400)) {
        // 더블탭: 마지막 본 프로필이 있으면 상세 페이지 열기
        if (_lastViewedProfile != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ProfileViewPage(index: 0, profile: _lastViewedProfile!),
            ),
          );
        }
      } else {
        setState(() => _selectedIndex = 0);
      }
      _lastTapTime = now;
    } else {
      setState(() => _selectedIndex = index);
    }
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
