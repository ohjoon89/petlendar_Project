// services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// 이메일 로그인
  static Future<bool> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user != null;
    } catch (e) {
      debugPrint("이메일 로그인 에러: $e");
      return false;
    }
  }

  /// 구글 로그인
  static Future<void> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'petlendar://login-callback',
      );
      // LoginScreen에서 currentSession으로 성공 여부 판단
    } catch (e) {
      debugPrint("구글 로그인 에러: $e");
      rethrow;
    }
  }

  /// 카카오 로그인
  static Future<void> signInWithKakao() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.kakao,
        redirectTo: 'petlendar://login-callback',
      );
    } catch (e) {
      debugPrint("카카오 로그인 에러: $e");
      rethrow;
    }
  }

  /// 전체 로그아웃 (Supabase + Google + Kakao)
  static Future<void> signOutAll() async {
    try {
      // Supabase 로그아웃
      await _supabase.auth.signOut();

      // Google 로그아웃
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      // Kakao 로그아웃
      try {
        await UserApi.instance.logout();
      } catch (e) {
        debugPrint("카카오 로그아웃 실패: $e");
      }

      debugPrint("모든 로그아웃 완료");
    } catch (e) {
      debugPrint("로그아웃 전체 에러: $e");
      rethrow;
    }
  }
}
