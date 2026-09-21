/// ============================================================
/// نموذج الطالب — يمثل بيانات طالب واحد
/// ============================================================
class Student {
  // ===== الحقول =====
  final String? id;              // المعرف (UUID)
  final String name;             // الاسم الكامل
  final String? studentNumber;   // رقم الطالب
  final String? gender;          // الجنس
  final String? grade;           // الصف
  final String? section;         // الفصل
  final String? createdAt;       // تاريخ الإضافة

  // ===== البناء =====
  Student({
    this.id,
    required this.name,
    this.studentNumber,
    this.gender,
    this.grade,
    this.section,
    this.createdAt,
  });

  // ===== من JSON إلى Student =====
  factory Student.fromJson(Map<String, dynamic> json) {
    try {
      return Student(
        id: json['id']?.toString(),
        name: json['name']?.toString() ?? '',
        studentNumber: json['student_number']?.toString(),
        gender: json['gender']?.toString(),
        grade: json['grade']?.toString(),
        section: json['section']?.toString(),
        createdAt: json['created_at']?.toString(),
      );
    } catch (e) {
      print('خطأ في Student.fromJson: $e');
      return Student(name: '');
    }
  }

  // ===== من Student إلى JSON =====
  Map<String, dynamic> toJson() {
    try {
      return {
        if (id != null) 'id': id,
        'name': name,
        'student_number': studentNumber,
        'gender': gender,
        'grade': grade,
        'section': section,
        'created_at': createdAt,
      };
    } catch (e) {
      print('خطأ في Student.toJson: $e');
      return {};
    }
  }

  // ===== نسخ مع تعديل =====
  Student copyWith({
    String? id,
    String? name,
    String? studentNumber,
    String? gender,
    String? grade,
    String? section,
    String? createdAt,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      studentNumber: studentNumber ?? this.studentNumber,
      gender: gender ?? this.gender,
      grade: grade ?? this.grade,
      section: section ?? this.section,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ===== للطباعة =====
  @override
  String toString() {
    return 'Student(id: $id, name: $name, grade: $grade)';
  }
}