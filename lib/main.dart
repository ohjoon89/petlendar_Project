import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


// 캘린더 import
import 'package:intl/date_symbol_data_local.dart';


import 'login_screen.dart';
import 'models/pet_profile.dart';
import 'models/main_bottom_nav.dart'; // ✅ 분리된 네비바 임포트

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mljwvknbhwgtcbwbmimh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1sand2a25iaHdndGNid2JtaW1oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUzNTc2MTksImV4cCI6MjA3MDkzMzYxOX0.IfnELTNHeJZXkmn5BWA_aY_lxK2m7J87Ew-mSjC1wE8',
  );

  // 캘린더
  await initializeDateFormatting('ko_KR', null);

  runApp(
    ChangeNotifierProvider(
      create: (_) => PetProfileProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool _checkingLogin = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final session = Supabase.instance.client.auth.currentSession;
    setState(() {
      _isLoggedIn = session != null;
      _checkingLogin = false;
    });
  }

  void _onLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingLogin) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: true,
      home: _isLoggedIn
          ? const MainBottomNav() // ✅ 분리된 네비바 시작 화면
          : LoginScreen(onLoginSuccess: _onLoginSuccess),
    );
  }
}

class PetProfileProvider extends ChangeNotifier {
  final List<PetProfile> _profiles = [];

  List<PetProfile> get profiles => _profiles;

  void addProfile(PetProfile profile) {
    _profiles.add(profile);
    notifyListeners();
  }

  void updateProfile(int index, PetProfile profile) {
    _profiles[index] = profile;
    notifyListeners();
  }

  void deleteProfile(int index) {
    if (index >= 0 && index < _profiles.length) {
      _profiles.removeAt(index);
      notifyListeners();
    }
  }
}