import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/auth_service.dart';        // ✅ جديد
import '../services/supabase_service.dart';
import 'add_student_screen.dart';

/// ============================================================
/// الشاشة الرئيسية — عرض الطلاب + بحث + إضافة
/// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ===== المتغيرات =====
  List<Student> _students = [];
  List<Student> _filteredStudents = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  // ============================================================
  // ===== البداية =====
  // ============================================================
  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // ===== تحميل الطلاب =====
  // ============================================================
  Future<void> _loadStudents() async {
    try {
      setState(() => _isLoading = true);
      final students = await SupabaseService.getAllStudents();
      setState(() {
        _students = students;
        _filteredStudents = students;
        _isLoading = false;
      });
    } catch (e) {
      print('خطأ في تحميل الطلاب: $e');
      setState(() => _isLoading = false);
      _showSnackBar('خطأ في التحميل', Colors.red);
    }
  }

  // ============================================================
  // ===== البحث =====
  // ============================================================
  Future<void> _search(String query) async {
    try {
      if (query.trim().isEmpty) {
        setState(() => _filteredStudents = _students);
        return;
      }
      final results = await SupabaseService.searchStudents(query);
      setState(() => _filteredStudents = results);
    } catch (e) {
      print('خطأ في البحث: $e');
    }
  }

  // ============================================================
  // ===== حذف طالب =====
  // ============================================================
  Future<void> _deleteStudent(Student student) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Text('تأكيد الحذف'),
            ],
          ),
          content: Text(
            'هل أنت متأكد من حذف "${student.name}"؟',
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('حذف'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      final success = await SupabaseService.deleteStudent(student.id!);
      if (success) {
        _showSnackBar('✅ تم حذف الطالب', Colors.green);
        _loadStudents();
      } else {
        _showSnackBar('❌ فشل في الحذف', Colors.red);
      }
    } catch (e) {
      print('خطأ في الحذف: $e');
    }
  }

  // ============================================================
  // ===== تسجيل الخروج (جديد) =====
  // ============================================================
  Future<void> _logout(BuildContext context) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.orange),
              SizedBox(width: 10),
              Text('تسجيل الخروج'),
            ],
          ),
          content: const Text(
            'هل أنت متأكد من تسجيل الخروج؟',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('خروج'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      await AuthService.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('خطأ في تسجيل الخروج: $e');
    }
  }

  // ============================================================
  // ===== SnackBar =====
  // ============================================================
  void _showSnackBar(String message, Color color) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print('خطأ في SnackBar: $e');
    }
  }

  // ============================================================
  // ===== بناء الواجهة =====
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تطبيق الطلبة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudents,
            tooltip: 'تحديث',
          ),
          IconButton(
            icon: const Icon(Icons.logout),       // ✅ جديد
            onPressed: () => _logout(context),
            tooltip: 'تسجيل خروج',
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              _buildStatsCard(context),
              _buildSearchBar(),
              Expanded(child: _buildStudentsList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddStudentScreen(),
            ),
          );
          if (result == true) _loadStudents();
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('إضافة طالب'),
      ),
    );
  }

  // ============================================================
  // ===== بطاقة الإحصائيات =====
  // ============================================================
  Widget _buildStatsCard(BuildContext context) {
    try {
      final theme = Theme.of(context);

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.people, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'إجمالي الطلاب',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              '${_students.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  // ============================================================
  // ===== شريط البحث =====
  // ============================================================
  Widget _buildSearchBar() {
    try {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: _searchController,
          onChanged: _search,
          decoration: InputDecoration(
            hintText: 'ابحث بالاسم أو رقم الطالب...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _search('');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  // ============================================================
  // ===== قائمة الطلاب =====
  // ============================================================
  Widget _buildStudentsList() {
    try {
      if (_isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_filteredStudents.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredStudents.length,
        itemBuilder: (context, index) {
          return _buildStudentCard(_filteredStudents[index]);
        },
      );
    } catch (e) {
      return const Center(child: Text('خطأ في العرض'));
    }
  }

  // ============================================================
  // ===== بطاقة الطالب =====
  // ============================================================
  Widget _buildStudentCard(Student student) {
    try {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              student.name.isNotEmpty ? student.name[0] : '؟',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            student.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            [
              if (student.studentNumber != null)
                'رقم: ${student.studentNumber}',
              if (student.grade != null)
                '${student.grade} ${student.section ?? ""}',
            ].join(' | '),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddStudentScreen(student: student),
                    ),
                  );
                  if (result == true) _loadStudents();
                },
                tooltip: 'تعديل',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteStudent(student),
                tooltip: 'حذف',
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  // ============================================================
  // ===== حالة عدم وجود طلاب =====
  // ============================================================
  Widget _buildEmptyState() {
    try {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'لا يوجد طلاب',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'اضغط "إضافة طالب" للبدء',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    } catch (e) {
      return const Center(child: Text('خطأ'));
    }
  }
}