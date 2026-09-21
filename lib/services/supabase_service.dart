import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student.dart';

/// ============================================================
/// خدمة Supabase — CRUD كامل للطلاب
/// ============================================================
class SupabaseService {
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
  // ===== إضافة طالب (Create) =====
  // ============================================================
  static Future<bool> addStudent(Student student) async {
    try {
      // ✅ لا نرسل id (Supabase يولّده تلقائياً)
      final data = student.toJson();
      data.remove('id');
      data.remove('created_at');

      await client.from('students').insert(data);
      print('✅ تم إضافة الطالب');
      return true;
    } catch (e) {
      print('خطأ في إضافة الطالب: $e');
      return false;
    }
  }

  // ============================================================
  // ===== عرض كل الطلاب (Read) =====
  // ============================================================
  static Future<List<Student>> getAllStudents() async {
    try {
      final response = await client
          .from('students')
          .select()
          .order('id', ascending: false);   // ✅ id بدل created_at

      return (response as List)
          .map((json) => Student.fromJson(json))
          .toList();
    } catch (e) {
      print('خطأ في جلب الطلاب: $e');
      return [];
    }
  }

  // ============================================================
  // ===== جلب طالب واحد =====
  // ============================================================
  static Future<Student?> getStudentById(String id) async {
    try {
      final response = await client
          .from('students')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Student.fromJson(response);
    } catch (e) {
      print('خطأ في جلب الطالب: $e');
      return null;
    }
  }

  // ============================================================
  // ===== تحديث طالب (Update) =====
  // ============================================================
  static Future<bool> updateStudent(Student student) async {
    try {
      if (student.id == null) return false;

      // ✅ لا نرسل id و created_at
      final data = student.toJson();
      data.remove('id');
      data.remove('created_at');

      await client
          .from('students')
          .update(data)
          .eq('id', student.id!);

      print('✅ تم تحديث الطالب');
      return true;
    } catch (e) {
      print('خطأ في تحديث الطالب: $e');
      return false;
    }
  }

  // ============================================================
  // ===== حذف طالب (Delete) =====
  // ============================================================
  static Future<bool> deleteStudent(String id) async {
    try {
      await client.from('students').delete().eq('id', id);
      print('✅ تم حذف الطالب');
      return true;
    } catch (e) {
      print('خطأ في حذف الطالب: $e');
      return false;
    }
  }

  // ============================================================
  // ===== البحث (Search) =====
  // ============================================================
  static Future<List<Student>> searchStudents(String query) async {
    try {
      if (query.trim().isEmpty) return getAllStudents();

      final response = await client
          .from('students')
          .select()
          .or('name.ilike.%$query%,student_number.ilike.%$query%')
          .order('id', ascending: false);   // ✅ id بدل created_at

      return (response as List)
          .map((json) => Student.fromJson(json))
          .toList();
    } catch (e) {
      print('خطأ في البحث: $e');
      return [];
    }
  }

  // ============================================================
  // ===== عدد الطلاب =====
  // ============================================================
  static Future<int> getStudentsCount() async {
    try {
      final response = await client
          .from('students')
          .select('id')
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      print('خطأ في عدد الطلاب: $e');
      return 0;
    }
  }
}