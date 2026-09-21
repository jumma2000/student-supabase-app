import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

/// ============================================================
/// نقطة البداية للتطبيق
/// ============================================================
Future<void> main() async {
  try {
    // ✅ تهيئة Flutter
    WidgetsFlutterBinding.ensureInitialized();

    // ✅ تحميل ملف .env
    await dotenv.load(fileName: "assets/.env");
    print('✅ تم تحميل ملف .env');

    // ✅ قراءة المفاتيح
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    // ✅ التحقق من المفاتيح
    if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
      print('❌ المفاتيح مفقودة في .env');
      runApp(const ErrorApp());
      return;
    }

    print('🔗 Supabase URL: $supabaseUrl');

    // ✅ تهيئة Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );

    print('✅ تم تهيئة Supabase');
    runApp(const StudentSupabaseApp());
  } catch (e, stackTrace) {
    print('❌ خطأ في تهيئة التطبيق: $e');
    print('📍 StackTrace: $stackTrace');
    runApp(const ErrorApp());
  }
}

/// ============================================================
/// التطبيق الرئيسي
/// ============================================================
class StudentSupabaseApp extends StatelessWidget {
  const StudentSupabaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      return MaterialApp(
        title: 'تطبيق الطلبة',
        debugShowCheckedModeBanner: false,

        // ===== الثيم =====
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E88E5),
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
          ),
        ),

        // ===== دعم العربية =====
        locale: const Locale('ar', 'LY'),
        supportedLocales: const [
          Locale('ar', 'LY'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // ===== الشاشة الأولى =====
        // ✅ إذا مسجل دخول → Home
        // ✅ إذا ما مسجلش → Login
        home: AuthService.isLoggedIn
            ? const HomeScreen()
            : const LoginScreen(),

        // ===== Routes =====
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
        },
      );
    } catch (e) {
      print('❌ خطأ في StudentSupabaseApp: $e');
      return const ErrorApp();
    }
  }
}

/// ============================================================
/// تطبيق الخطأ (إذا فشلت التهيئة)
/// ============================================================
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('خطأ'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 80, color: Colors.red),
                SizedBox(height: 20),
                Text(
                  'حدث خطأ في تهيئة التطبيق',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'يرجى التحقق من:\n'
                  '1. ملف .env موجود\n'
                  '2. الرابط صحيح\n'
                  '3. المفاتيح صحيحة\n'
                  '4. الاتصال بالإنترنت',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}