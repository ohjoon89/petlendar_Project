import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vibration/vibration.dart';

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
    _loadSettings(); // 앱 시작 시 저장된 설정 불러오기
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


    //에뮬레이터 진동 기능 X, 기능은 문제 없음
    if (_vibration && await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 250,); // 0.25초 진동
    }

    Fluttertoast.showToast(
    msg: "진동 ${_vibration ? '켜짐' : '꺼짐'}",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Color.fromARGB(178, 0, 0, 0),
    textColor: Colors.white,
    fontSize: 16.0,
    // 아이콘 제거 → 기본적으로 Fluttertoast는 아이콘이 없으므로 그대로 메시지만 표시
  );
  }

  void _handleNotificationChanged(bool value) {
    setState(() => _notifications = value);
    _saveSettings();

    Fluttertoast.showToast(
    msg: "알림 ${_notifications ? '허용' : '차단'}",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Color.fromARGB(178, 0, 0, 0),
    textColor: Colors.white,
    fontSize: 16.0,
    // 아이콘 제거
  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        centerTitle: true,
      ),
      body: ListView(
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
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('버전'),
            subtitle: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}