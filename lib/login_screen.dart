import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback? onLoginSuccess; // 로그인 성공 시 호출될 콜백

  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 140),

            // 로고
            Image.asset(
              'assets/src/petlendar.png',
              width: 200,
            ),

            // 아이디 입력
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
              child: SizedBox(
                width: 300,
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '아이디',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
            ),

            // 비밀번호 입력
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
              child: SizedBox(
                width: 300,
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '비밀번호',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
            ),

            // 회원가입 / 아이디 찾기 / 비밀번호 찾기
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: const Text("회원가입 | "),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text("아이디 찾기 | "),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text("비밀번호 찾기"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 로그인 버튼
            SizedBox(
              width: 300,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(0, 230, 230, 230),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text(
                  "로그인",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 구글 로그인 버튼 (Ink.image 적용)
            Material(
              color: Colors.transparent,
              child: Ink.image(
                image: const AssetImage('assets/src/googleLoginBtn.png'),
                width: 300,
                height: 44,
                fit: BoxFit.cover,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {

                  },
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 카카오 로그인 버튼 (Ink.image 적용)
            Material(
              color: Colors.transparent,
              child: Ink.image(
                image: const AssetImage('assets/src/kakaoLoginBtn.png'),
                width: 300,
                height: 44,
                fit: BoxFit.cover,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {

                  },
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 개발자 로그인 버튼
            ElevatedButton(
              onPressed: () {
                if (onLoginSuccess != null) onLoginSuccess!();
              },
              child: const Text("개발자 로그인"),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
