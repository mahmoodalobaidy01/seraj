import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:seraj/controllers/auth_controller.dart';

class TeacherSubject {
  final int teacherId;
  final String teacherName;
  final String teacherPosition;
  final int stageId;
  final String stageClass;
  final String stageBranch;
  final int subjectId;
  final String subjectName;
  final String subjectOrder;

  TeacherSubject({
    required this.teacherId,
    required this.teacherName,
    required this.teacherPosition,
    required this.stageId,
    required this.stageClass,
    required this.stageBranch,
    required this.subjectId,
    required this.subjectName,
    required this.subjectOrder,
  });

  factory TeacherSubject.fromJson(Map<String, dynamic> json) {
    return TeacherSubject(
      teacherId: json['teacher_id'] ?? 0,
      teacherName: json['teacher_name'] ?? '',
      teacherPosition: json['teacher_position'] ?? '',
      stageId: json['stage_id'] ?? 0,
      stageClass: json['stage_class'] ?? '',
      stageBranch: json['stage_branch'] ?? '',
      subjectId: json['subject_id'] ?? 0,
      subjectName: json['subject_name'] ?? '',
      subjectOrder: json['subject_order'] ?? '',
    );
  }

  String get stageDisplayName => 'الصف $stageClass الابتدائي';
  String get fullStageDisplayName => 'الصف $stageClass الابتدائي - شعبة $stageBranch';
}

class HomeworkScreen extends StatefulWidget {
  final int teacherId;

  const HomeworkScreen({Key? key, required this.teacherId}) : super(key: key);

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  List<TeacherSubject> _teacherSubjects = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, List<TeacherSubject>> _groupedSubjects = {};

  @override
  void initState() {
    super.initState();
    _fetchTeacherSubjects();
  }

  Future<void> _fetchTeacherSubjects() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get auth controller to access token
      final authController = Get.find<AuthController>();
      
      final response = await http.get(
        Uri.parse('https://khayalstudio.com/siraj/api/examfromteacher?id=${widget.teacherId}'),
        headers: authController.authHeaders,
      );

      print('Homework response status: ${response.statusCode}');
      print('Homework response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data'] is List) {
          _teacherSubjects = (data['data'] as List)
              .map((item) => TeacherSubject.fromJson(item))
              .toList();
          
          _groupSubjectsByStage();
        } else {
          setState(() {
            _errorMessage = 'لا توجد مواد دراسية متاحة';
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى';
        });
        authController.logout();
      } else {
        setState(() {
          _errorMessage = 'فشل في تحميل البيانات (${response.statusCode})';
        });
      }
    } catch (e) {
      print('Error fetching teacher subjects: $e');
      setState(() {
        _errorMessage = 'خطأ في الاتصال بالشبكة';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _groupSubjectsByStage() {
    _groupedSubjects.clear();
    for (var subject in _teacherSubjects) {
      String stageKey = subject.fullStageDisplayName;
      if (!_groupedSubjects.containsKey(stageKey)) {
        _groupedSubjects[stageKey] = [];
      }
      _groupedSubjects[stageKey]!.add(subject);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      appBar: AppBar(
        title: const Text(
          'الواجبات البيتية',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF87CEEB),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchTeacherSubjects,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF87CEEB),
                        ),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFF87CEEB),
                  onRefresh: _fetchTeacherSubjects,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: _groupedSubjects.entries.map((entry) {
                      return _buildStageSection(entry.key, entry.value);
                    }).toList(),
                  ),
                ),
    );
  }

  Widget _buildStageSection(String stageTitle, List<TeacherSubject> subjects) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          title: Text(
            stageTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D7A),
            ),
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF87CEEB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.expand_more,
              color: Colors.white,
            ),
          ),
          children: subjects.map((subject) => _buildSubjectTile(subject)).toList(),
        ),
      ),
    );
  }

  Widget _buildSubjectTile(TeacherSubject subject) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        title: Text(
          subject.subjectName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          'ترتيب المادة: ${subject.subjectOrder}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(
            Icons.book,
            color: Colors.white,
            size: 20,
          ),
        ),
        onTap: () {
          // Navigate to homework details for this subject
          _showHomeworkDetails(subject);
        },
      ),
    );
  }

  void _showHomeworkDetails(TeacherSubject subject) {
    Get.snackbar(
      'الواجبات البيتية',
      'عرض واجبات ${subject.subjectName} - ${subject.fullStageDisplayName}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
    
    // TODO: Navigate to homework details screen
    // Get.to(() => HomeworkDetailsScreen(subject: subject));
  }
}