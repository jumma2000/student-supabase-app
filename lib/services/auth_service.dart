import 'package:supabase_flutter/supabase_flutter.dart';

/// ============================================================
/// خدمة المصادقة — إدارة تسجيل الدخول
/// ============================================================
class AuthService {
  // ===== الحصول على العميل =====
  static SupabaseClient get client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      print('خطأ في الحصول على Supabase Client: $e');
      rethrow;
    }
  }

  // ============================================================
  // ===== تسجيل الدخول =====
  // ============================================================
  static Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await client.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      print('✅ تم تسجيل الدخول');
      return true;
    } on AuthException catch (e) {
      print('خطأ في تسجيل الدخول: ${e.message}');
      return false;
    } catch (e) {
      print('خطأ غير متوقع: $e');
      return false;
    }
  }

  // ============================================================
  // ===== إنشاء حساب جديد =====
  // ============================================================
  static Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await client.auth.signUp(
        email: email.trim(),
        password: password.trim(),
      );
      print('✅ تم إنشاء الحساب');
      return true;
    } on AuthException catch (e) {
      print('خطأ في إنشاء الحساب: ${e.message}');
      return false;
    } catch (e) {
      print('خطأ غير متوقع: $e');
      return false;
    }
  }

  // ============================================================
  // ===== تسجيل الخروج =====
  // ============================================================
  static Future<bool> signOut() async {
    try {
      await client.auth.signOut();
      print('✅ تم تسجيل الخروج');
      return true;
    } catch (e) {
      print('خطأ في تسجيل الخروج: $e');
      return false;
    }
  }

  // ============================================================
  // ===== استعادة كلمة المرور =====
  // ============================================================
  static Future<bool> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email.trim());
      print('✅ تم إرسال رابط الاستعادة');
      return true;
    } catch (e) {
      print('خطأ في الاستعادة: $e');
      return false;
    }
  }

  // ============================================================
  // ===== هل المستخدم مسجل دخول؟ =====
  // ============================================================
  static bool get isLoggedIn {
    try {
      return client.auth.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // ===== الحصول على المستخدم الحالي =====
  // ============================================================
  static User? get currentUser {
    try {
      return client.auth.currentUser;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // ===== البريد الإلكتروني للمستخدم =====
  // ============================================================
  static String? get currentUserEmail {
    try {
      return currentUser?.email;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // ===== الاستماع لتغييرات الحالة =====
  // ============================================================
  static Stream<AuthState> get authStateChanges {
    try {
      return client.auth.onAuthStateChange;
    } catch (e) {
      print('خطأ في stream: $e');
      return const Stream.empty();
    }
  }
}