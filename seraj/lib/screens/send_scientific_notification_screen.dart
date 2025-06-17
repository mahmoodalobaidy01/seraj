import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:seraj/screens/main_screen.dart';
import '../controllers/user_controller.dart';

class Stage {
  final int id;
  final String stageClass;
  final String stageBranch;
  final int teacherId;
  final List<Subject> subjects;

  Stage({
    required this.id,
    required this.stageClass,
    required this.stageBranch,
    required this.teacherId,
    required this.subjects,
  });

  factory Stage.fromJson(Map<String, dynamic> json) {
    var subjectsList = json['subjects'] as List? ?? [];
    List<Subject> subjects =
        subjectsList.map((i) => Subject.fromJson(i)).toList();

    return Stage(
      id: json['id'] ?? 0,
      stageClass: json['stage_class'] ?? '',
      stageBranch: json['stage_branch'] ?? '',
      teacherId: json['teacher_id'] ?? 0,
      subjects: subjects,
    );
  }

  String get displayName => 'الصف $stageClass - شعبة $stageBranch';
}

class Subject {
  final int id;
  final String subjectName;
  final String subjectOrder;
  final int stageId;

  Subject({
    required this.id,
    required this.subjectName,
    required this.subjectOrder,
    required this.stageId,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? 0,
      subjectName: json['subject_name'] ?? '',
      subjectOrder: json['subject_order'] ?? '',
      stageId: json['stage_id'] ?? 0,
    );
  }
}

class SendScientificNotificationScreen extends StatefulWidget {
  final user;
  const SendScientificNotificationScreen({Key? key, required this.user})
      : super(key: key);

  @override
  State<SendScientificNotificationScreen> createState() =>
      _SendScientificNotificationScreenState();
}

class _SendScientificNotificationScreenState
    extends State<SendScientificNotificationScreen> {
  // late final widget.user widget.user;

  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  // Dropdown values
  Stage? _selectedStage;
  Subject? _selectedSubject;

  // Data lists
  List<Stage> _stages = [];

  // File selection
  File? _selectedFile;
  String? _selectedFileName;

  // Loading states
  bool _isLoadingStages = false;
  bool _isSubmitting = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    // Get user controller - try to find existing one first, then create if needed
    // try {
    //   widget.user = Get.find<widget.user>();
    //   widget.user.refreshProfile();
    // } catch (e) {
    //   print('widget.user not found, creating new one: $e');
    //   widget.user = Get.put(widget.user());
    // }

    // Check if user is authenticated before proceeding
    if (!widget.user.isAuthenticated) {
      print(
          'User not authenticated, going back ${widget.user.isAuthenticated}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
      });
      return;
    }

    // Fetch stages after a brief delay to ensure the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_disposed) {
        _fetchStages();
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (mounted && !_disposed) {
      setState(fn);
    }
  }

  Future<void> _fetchStages() async {
    if (_disposed || !mounted) return;

    _safeSetState(() {
      _isLoadingStages = true;
    });

    try {
      // Use the existing widget.user instance
      final user = widget.user.user.value;

      print('User object: $user');
      print('Access token: ${user?.accessToken}');
      print('Token type: ${user?.tokenType}');
      print('Variable ID: ${user?.variableId}');

      if (user == null) {
        print('User is null');
        if (mounted) {
          Get.snackbar(
            'خطأ',
            'يرجى تسجيل الدخول مرة أخرى',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        return;
      }

      if (user.accessToken == null || user.accessToken!.isEmpty) {
        print('Access token is null or empty: ${user.accessToken}');
        if (mounted) {
          Get.snackbar(
            'خطأ',
            'يرجى تسجيل الدخول مرة أخرى',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        return;
      }

      int? teacherId = user.variableId;
      print('Teacher ID: $teacherId');

      if (teacherId == null) {
        print('Teacher ID is null');
        if (mounted) {
          Get.snackbar(
            'خطأ',
            'معرف المعلم غير صحيح',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://khayalstudio.com/siraj/api/stagefromteacher?id=$teacherId'),
        headers: {
          'Authorization': '${user.tokenType ?? 'Bearer'} ${user.accessToken}',
          'Accept': 'application/json',
        },
      );

      print('Stages response status: ${response.statusCode}');
      print('Stages response body: ${response.body}');

      if (!mounted || _disposed) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['stages'] != null && data['stages'] is List) {
          _safeSetState(() {
            _stages = (data['stages'] as List)
                .map((stage) => Stage.fromJson(stage))
                .toList();
          });
          print('Loaded ${_stages.length} stages');
        } else {
          print('No stages found in response');
          if (mounted) {
            Get.snackbar(
              'تنبيه',
              'لا توجد مراحل دراسية متاحة',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          }
        }
      } else if (response.statusCode == 401) {
        print('Unauthorized - logging out user');
        if (mounted) {
          widget.user.logout();
        }
      } else {
        print('Failed to load stages: ${response.statusCode}');
        if (mounted) {
          Get.snackbar(
            'خطأ',
            'فشل في تحميل المراحل الدراسية (${response.statusCode})',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('Error fetching stages: $e');
      if (mounted) {
        Get.snackbar(
          'خطأ',
          'خطأ في الاتصال بالشبكة',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted && !_disposed) {
        _safeSetState(() {
          _isLoadingStages = false;
        });
      }
    }
  }

  Future<void> _pickFile() async {
    if (_disposed || !mounted) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && mounted && !_disposed) {
        _safeSetState(() {
          _selectedFile = File(result.files.single.path!);
          _selectedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      print('Error picking file: $e');
      if (mounted) {
        Get.snackbar(
          'خطأ',
          'فشل في اختيار الملف',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _submitNotification() async {
    if (_disposed || !mounted) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSubject == null) {
      if (mounted) {
        Get.snackbar(
          'خطأ',
          'يرجى اختيار المادة الدراسية',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      return;
    }

    _safeSetState(() {
      _isSubmitting = true;
    });

    try {
      final user = widget.user.user.value;

      if (user?.accessToken == null || user?.accessToken?.isEmpty == true) {
        print('Access token is null or empty during submission');
        if (mounted) {
          Get.snackbar(
            'خطأ',
            'يرجى تسجيل الدخول مرة أخرى',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://khayalstudio.com/siraj/api/announcement/create'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': '${user!.tokenType ?? 'Bearer'} ${user.accessToken}',
        'Accept': 'application/json',
      });

      // Add form fields
      request.fields['subject_id'] = _selectedSubject!.id.toString();
      request.fields['announcement_title'] = _titleController.text.trim();
      request.fields['announcement_description'] =
          _descriptionController.text.trim();
      request.fields['announcement_type'] = 'scientific';
      request.fields['created_by'] =
          user.variableId?.toString() ?? '${user.variableId}';

      print('Submitting with fields: ${request.fields}');

      // Add file if selected
      if (_selectedFile != null && _selectedFile!.existsSync()) {
        request.files.add(await http.MultipartFile.fromPath(
          'announcement_document',
          _selectedFile!.path,
        ));
        print('Added file: ${_selectedFile!.path}');
      }

      final response =
          await request.send().timeout(const Duration(seconds: 60));

      if (_disposed || !mounted) return;

      final responseBody = await response.stream.bytesToString();

      print('Submit response status: ${response.statusCode}');
      print('Submit response body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(responseBody);
        if (mounted) {
          Get.snackbar(
            'نجح',
            data['message'] ?? 'تم إرسال التبليغ العلمي بنجاح',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }

        // Clear form
        if (mounted && !_disposed) {
          _titleController.clear();
          _descriptionController.clear();
          _safeSetState(() {
            _selectedStage = null;
            _selectedSubject = null;
            _selectedFile = null;
            _selectedFileName = null;
          });
        }

        // Go back to previous screen
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else if (response.statusCode == 401) {
        print('Unauthorized during submission - logging out user');
        if (mounted) {
          widget.user.logout();
        }
      } else {
        try {
          final data = json.decode(responseBody);
          if (mounted) {
            Get.snackbar(
              'خطأ',
              data['message'] ?? 'فشل في إرسال التبليغ العلمي',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        } catch (e) {
          if (mounted) {
            Get.snackbar(
              'خطأ',
              'فشل في إرسال التبليغ العلمي (${response.statusCode})',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        }
      }
    } catch (e) {
      print('Error submitting notification: $e');
      if (mounted) {
        Get.snackbar(
          'خطأ',
          'خطأ في الاتصال بالشبكة',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      _safeSetState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      appBar: AppBar(
        title: const Text(
          'إرسال تبليغ علمي',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF87CEEB),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Debug info (remove this in production)
              // Container(
              //   padding: const EdgeInsets.all(16),
              //   margin: const EdgeInsets.only(bottom: 20),
              //   decoration: BoxDecoration(
              //     color: Colors.yellow.shade100,
              //     borderRadius: BorderRadius.circular(8),
              //     border: Border.all(color: Colors.orange),
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text('Debug Info:', style: TextStyle(fontWeight: FontWeight.bold)),
              //       Text('User ID: ${widget.user.user.value?.variableId ?? "null"}'),
              //       Text('Access Token: ${widget.user.user.value?.accessToken?.isNotEmpty == true ? "Present" : "null/empty"}'),
              //       Text('Token Type: ${widget.user.user.value?.tokenType ?? "null"}'),
              //       Text('Is Authenticated: ${widget.user.isAuthenticated}'),
              //       Text('Stages Count: ${_stages.length}'),
              //       Text('Loading Stages: $_isLoadingStages'),
              //     ],
              //   ),
              // ),

              // Stage Selection
              Container(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: _isLoadingStages
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : DropdownButtonFormField<Stage>(
                        decoration: const InputDecoration(
                          labelText: 'اختر المرحلة الدراسية',
                          border: InputBorder.none,
                          prefixIcon:
                              Icon(Icons.class_, color: Color(0xFF2E7D7A)),
                        ),
                        value: _selectedStage,
                        items: _stages.map((Stage stage) {
                          return DropdownMenuItem<Stage>(
                            value: stage,
                            child: Text(stage.displayName),
                          );
                        }).toList(),
                        onChanged: (Stage? newValue) {
                          if (!_disposed) {
                            _safeSetState(() {
                              _selectedStage = newValue;
                              _selectedSubject =
                                  null; // Reset subject when stage changes
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'يرجى اختيار المرحلة الدراسية';
                          }
                          return null;
                        },
                      ),
              ),
              const SizedBox(height: 20),

              // Subject Selection
              Container(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButtonFormField<Subject>(
                  decoration: const InputDecoration(
                    labelText: 'اختر المادة الدراسية',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.book, color: Color(0xFF2E7D7A)),
                  ),
                  value: _selectedSubject,
                  items: _selectedStage?.subjects.map((Subject subject) {
                        return DropdownMenuItem<Subject>(
                          value: subject,
                          child: Text(subject.subjectName),
                        );
                      }).toList() ??
                      [],
                  onChanged: _selectedStage == null
                      ? null
                      : (Subject? newValue) {
                          if (!_disposed) {
                            _safeSetState(() {
                              _selectedSubject = newValue;
                            });
                          }
                        },
                  validator: (value) {
                    if (value == null) {
                      return 'يرجى اختيار المادة الدراسية';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Title Field
              Container(
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
                child: TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان التبليغ',
                    hintText: 'أدخل عنوان التبليغ العلمي',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    prefixIcon: Icon(Icons.title, color: Color(0xFF2E7D7A)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال عنوان التبليغ';
                    }
                    if (value.trim().length < 3) {
                      return 'يجب أن يكون العنوان 3 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Description Field
              Container(
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
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'محتوى التبليغ',
                    hintText: 'أدخل محتوى التبليغ العلمي',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    prefixIcon:
                        Icon(Icons.description, color: Color(0xFF2E7D7A)),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال محتوى التبليغ';
                    }
                    if (value.trim().length < 10) {
                      return 'يجب أن يكون المحتوى 10 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // File Selection
              Container(
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
                child: ListTile(
                  leading:
                      const Icon(Icons.attach_file, color: Color(0xFF2E7D7A)),
                  title: Text(
                    _selectedFileName ?? 'اختر ملف مرفق (اختياري)',
                    style: TextStyle(
                      color: _selectedFileName != null
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                  subtitle: _selectedFileName != null
                      ? const Text('اضغط لتغيير الملف')
                      : const Text('PDF, DOC, صورة'),
                  trailing: _selectedFile != null
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          onPressed: () {
                            if (!_disposed) {
                              _safeSetState(() {
                                _selectedFile = null;
                                _selectedFileName = null;
                              });
                            }
                          },
                        )
                      : const Icon(Icons.upload_file),
                  onTap: _pickFile,
                ),
              ),
              const SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitNotification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('جاري الإرسال...',
                              style: TextStyle(fontSize: 16)),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send),
                          SizedBox(width: 8),
                          Text('إرسال التبليغ العلمي',
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
