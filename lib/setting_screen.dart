import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vibration/vibration.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _vibration = true;
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _vibration = prefs.getBool('vibration') ?? true;
      _notifications = prefs.getBool('notifications') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibration', _vibration);
    await prefs.setBool('notifications', _notifications);
  }

  void _handleVibrationChanged(bool value) async {
    setState(() => _vibration = value);
    _saveSettings();

    if (_vibration && await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 250);
    }

    Fluttertoast.showToast(
      msg: "진동 ${_vibration ? '켜짐' : '꺼짐'}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color.fromARGB(178, 0, 0, 0),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _handleNotificationChanged(bool value) {
    setState(() => _notifications = value);
    _saveSettings();

    Fluttertoast.showToast(
      msg: "알림 ${_notifications ? '허용' : '차단'}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color.fromARGB(178, 0, 0, 0),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _handleLogout() async {
    try {
      await AuthService.signOutAll();

      Fluttertoast.showToast(
        msg: "로그아웃 완료",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color.fromARGB(178, 0, 0, 0),
        textColor: Colors.white,
        fontSize: 16.0,
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('로그아웃 처리 중 오류: $e');
      Fluttertoast.showToast(
        msg: "로그아웃 중 오류 발생",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color.fromARGB(178, 255, 0, 0),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정'), centerTitle: true),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                '시스템 설정',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 20, thickness: 1),
              SwitchListTile(
                title: const Text('진동'),
                value: _vibration,
                onChanged: _handleVibrationChanged,
              ),
              SwitchListTile(
                title: const Text('알림'),
                value: _notifications,
                onChanged: _handleNotificationChanged,
              ),
              const SizedBox(height: 30),
              const Text(
                '앱 정보',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 20, thickness: 1),
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('버전'),
                subtitle: Text('1.0.0'),
              ),
              const SizedBox(height: 60),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: GestureDetector(
              onTap: _handleLogout,
              child: const Text(
                '로그아웃',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
