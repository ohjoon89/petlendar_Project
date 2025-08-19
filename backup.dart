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

  // 각 탭별 페이지 위젯
  static final List<Widget> _pages = [
    // [홈 화면] 담당 개발자: 여기에 홈 화면 소스코드 작성
    const Center(child: Text("홈 화면", style: TextStyle(fontSize: 24))),

    // [리스트 페이지] 담당 개발자: 여기에 리스트 페이지 소스코드 작성
    const Center(child: Text("리스트 페이지", style: TextStyle(fontSize: 24))),

    // [캘린더 페이지] 담당 개발자: 여기에 캘린더 페이지 소스코드 작성
    const Center(child: Text("캘린더 페이지", style: TextStyle(fontSize: 24))),

    // [사진첩 페이지] 담당 개발자: 여기에 사진첩 페이지 소스코드 작성
    const Center(child: Text("사진첩 페이지", style: TextStyle(fontSize: 24))),

    // [설정 페이지] 담당 개발자: 여기에 설정 페이지 소스코드 작성
    const Center(child: Text("설정 페이지", style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: Scaffold(
        body: _pages[_selectedIndex], // 페이지 전환
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: '리스트',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: '캘린더',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: '사진첩'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
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

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.profileName,
    required this.profileImageUrl,
    required this.onAddProfile,
    required this.onAddProfileLongPressDemo,
    required this.onClearProfile,
  });

  final String? profileName;
  final String? profileImageUrl;
  final VoidCallback onAddProfile;
  final VoidCallback onAddProfileLongPressDemo;
  final VoidCallback onClearProfile;

  @override
  Widget build(BuildContext context) {
    final hasProfile = (profileName != null && profileName!.trim().isNotEmpty);

    if (!hasProfile) {
      // 등록 전 화면
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 48,
              child: Icon(Icons.person, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onLongPress: onAddProfileLongPressDemo,
              child: ElevatedButton(
                onPressed: onAddProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('프로필 추가'),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '(* 길게 누르면 임시 데이터 등록 — UI 테스트용)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // 등록 후 화면
    return SafeArea(
      child: Column(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            color: const Color(0xFFE6FAF8),
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: 48,
              backgroundImage:
                  (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                  ? NetworkImage(profileImageUrl!)
                  : null,
              child: (profileImageUrl == null || profileImageUrl!.isEmpty)
                  ? const Icon(Icons.person, size: 48)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profileName!,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onClearProfile,
            icon: const Icon(Icons.delete_outline),
            label: const Text('프로필 초기화'),
          ),
        ],
      ),
    );
  }
}
