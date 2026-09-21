import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/supabase_service.dart';

/// ============================================================
/// شاشة إضافة طالب جديد
/// ============================================================
class AddStudentScreen extends StatefulWidget {
  final Student? student; // للتعديل (null = إضافة)

  const AddStudentScreen({super.key, this.student});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  // ===== المتغيرات =====
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _gradeController = TextEditingController();
  final _sectionController = TextEditingController();

  String? _selectedGender;
  bool _isSaving = false;

  // ===== التهيئة =====
  @override
  void initState() {
    super.initState();
    // ✅ إذا كان تعديل، املأ الحقول
    if (widget.student != null) {
      _nameController.text = widget.student!.name;
      _numberController.text = widget.student!.studentNumber ?? '';
      _gradeController.text = widget.student!.grade ?? '';
      _sectionController.text = widget.student!.section ?? '';
      _selectedGender = widget.student!.gender;
    }
  }

  // ===== التخلص من الموارد =====
  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _gradeController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  // ===== حفظ الطالب =====
  Future<void> _saveStudent() async {
    try {
      if (!_formKey.currentState!.validate()) return;

      setState(() => _isSaving = true);

      final student = Student(
        id: widget.student?.id,
        name: _nameController.text.trim(),
        studentNumber: _numberController.text.trim().isEmpty
            ? null
            : _numberController.text.trim(),
        gender: _selectedGender,
        grade: _gradeController.text.trim().isEmpty
            ? null
            : _gradeController.text.trim(),
        section: _sectionController.text.trim().isEmpty
            ? null
            : _sectionController.text.trim(),
      );

      bool success;
      if (widget.student == null) {
        // ✅ إضافة
        success = await SupabaseService.addStudent(student);
      } else {
        // ✅ تعديل
        success = await SupabaseService.updateStudent(student);
      }

      if (success) {
        _showSnackBar(
          widget.student == null
              ? '✅ تم إضافة الطالب'
              : '✅ تم تحديث الطالب',
          Colors.green,
        );
        Navigator.pop(context, true);
      } else {
        _showSnackBar('❌ فشل في الحفظ', Colors.red);
      }
    } catch (e) {
      print('خطأ في الحفظ: $e');
      _showSnackBar('خطأ: $e', Colors.red);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // ===== SnackBar =====
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

  // ===== بناء الواجهة =====
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.student != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'تعديل طالب' : 'إضافة طالب جديد'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('البيانات الأساسية'),
                  const SizedBox(height: 10),

                  _buildTextField(
                    controller: _nameController,
                    label: 'الاسم الكامل',
                    icon: Icons.person,
                    required: true,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _numberController,
                    label: 'رقم الطالب',
                    icon: Icons.numbers,
                  ),
                  const SizedBox(height: 12),

                  _buildGenderDropdown(),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _gradeController,
                    label: 'الصف',
                    icon: Icons.school,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _sectionController,
                    label: 'الفصل',
                    icon: Icons.class_,
                  ),
                  const SizedBox(height: 30),

                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===== عنوان قسم =====
  Widget _buildSectionTitle(String title) {
    try {
      final colorScheme = Theme.of(context).colorScheme;
      return Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  // ===== حقل نصي =====
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    try {
      return TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال $label';
                }
                return null;
              }
            : null,
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  // ===== قائمة الجنس =====
  Widget _buildGenderDropdown() {
    try {
      return DropdownButtonFormField<String>(
        initialValue: _selectedGender,
        decoration: InputDecoration(
          labelText: 'الجنس',
          prefixIcon: const Icon(Icons.wc),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        items: const [
          DropdownMenuItem(value: 'ذكر', child: Text('ذكر')),
          DropdownMenuItem(value: 'أنثى', child: Text('أنثى')),
        ],
        onChanged: (value) {
          setState(() => _selectedGender = value);
        },
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  // ===== زر الحفظ =====
  Widget _buildSaveButton() {
    try {
      final colorScheme = Theme.of(context).colorScheme;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isSaving ? null : _saveStudent,
          icon: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.save),
          label: Text(
            _isSaving ? 'جاري الحفظ...' : 'حفظ',
            style: const TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }
}