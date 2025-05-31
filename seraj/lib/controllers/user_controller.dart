// user_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:seraj/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? accessToken;
  final String? tokenType;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.accessToken,
    this.tokenType,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromQRResponse(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: '', // Will be updated from profile data
      email: '', // Will be updated from profile data
      role: json['role'] ?? '',
      accessToken: json['access_token'],
      tokenType: json['token_type'] ?? 'Bearer',
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  factory User.fromProfileResponse(Map<String, dynamic> json, String? accessToken, String? tokenType) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      accessToken: accessToken,
      tokenType: tokenType,
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'access_token': accessToken,
      'token_type': tokenType,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? accessToken,
    String? tokenType,
    String? emailVerifiedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      accessToken: accessToken ?? this.accessToken,
      tokenType: tokenType ?? this.tokenType,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Teacher {
  final int id;
  final int userId;
  final String teacherName;
  final String teacherBirth;
  final int teacherGender;
  final String teacherPosition;
  final String? teacherImage;
  final String teacherAddress;
  final String teacherPhone;
  final int teacherStatus;
  final int teacherLeader;
  final String teacherQr;
  final int createdBy;
  final String createdAt;
  final String updatedAt;

  Teacher({
    required this.id,
    required this.userId,
    required this.teacherName,
    required this.teacherBirth,
    required this.teacherGender,
    required this.teacherPosition,
    this.teacherImage,
    required this.teacherAddress,
    required this.teacherPhone,
    required this.teacherStatus,
    required this.teacherLeader,
    required this.teacherQr,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      teacherName: json['teacher_name'] ?? '',
      teacherBirth: json['teacher_birth'] ?? '',
      teacherGender: json['teacher_gender'] ?? 0,
      teacherPosition: json['teacher_position'] ?? '',
      teacherImage: json['teacher_image'],
      teacherAddress: json['teacher_address'] ?? '',
      teacherPhone: json['teacher_phone'] ?? '',
      teacherStatus: json['teacher_status'] ?? 0,
      teacherLeader: json['teacher_leader'] ?? 0,
      teacherQr: json['teacher_qr'] ?? '',
      createdBy: json['created_by'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'teacher_name': teacherName,
      'teacher_birth': teacherBirth,
      'teacher_gender': teacherGender,
      'teacher_position': teacherPosition,
      'teacher_image': teacherImage,
      'teacher_address': teacherAddress,
      'teacher_phone': teacherPhone,
      'teacher_status': teacherStatus,
      'teacher_leader': teacherLeader,
      'teacher_qr': teacherQr,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class UserController extends GetxController {
  static const String baseUrl = 'https://khayalstudio.com/siraj/api';
  
  // Observable variables
  var user = Rxn<User>();
  var teacher = Rxn<Teacher>();
  var isLoggedIn = false.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserFromStorage();
  }

  // Set user from QR login response
  Future<void> setUserFromQRLogin(Map<String, dynamic> qrResponse) async {
    try {
      isLoading.value = true;
      
      // Create user from QR response with token info
      user.value = User.fromQRResponse(qrResponse);
      
      // Fetch complete profile data from /profile endpoint
      await fetchProfileData();
      
      isLoggedIn.value = true;
      await saveUserToStorage();
      
    } catch (e) {
      print('Error setting user from QR login: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ في تحميل بيانات المستخدم',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch profile data from new /profile endpoint
  Future<void> fetchProfileData() async {
    try {
      if (user.value?.accessToken == null) return;
      
      final response = await http.get(
  Uri.parse('$baseUrl/profile'),
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${user.value!.accessToken}',
  },
);


      print('Profile response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Check if user array exists and has data
        if (data['user'] != null && data['user'] is List && data['user'].isNotEmpty) {
          final userData = data['user'][0]; // Get first user from array
          
          // Update user with complete profile data while preserving token info
          user.value = User.fromProfileResponse(
            userData,
            user.value!.accessToken,
            user.value!.tokenType,
          );
          
          print('Profile data loaded for user: ${user.value?.name} (Role: ${user.value?.role})');
          
          // If user is a teacher or leader, fetch teacher-specific data if needed
          if (user.value?.role == 'leader' || user.value?.role == 'teacher') {
            await fetchTeacherData(user.value!.id);
          }
          
        } else {
          print('No user data found in profile response');
          Get.snackbar(
            'خطأ',
            'لم يتم العثور على بيانات المستخدم',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        print('Failed to fetch profile data: ${response.statusCode}');
        print('Response body: ${response.body}');
        
        // Handle unauthorized access
        if (response.statusCode == 401) {
          Get.snackbar(
            'انتهت صلاحية الجلسة',
            'يرجى تسجيل الدخول مرة أخرى',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          await logout();
          return;
        }
        
        Get.snackbar(
          'تحذير',
          'فشل في تحميل بيانات الملف الشخصي',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      Get.snackbar(
        'خطأ',
        'خطأ في تحميل بيانات الملف الشخصي',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Fetch teacher data (keep existing method for teacher-specific data)
  Future<void> fetchTeacherData(int teacherId) async {
    try {
      if (user.value?.accessToken == null) return;
      
      final response = await http.get(
        Uri.parse('$baseUrl/teacher/$teacherId'),
        headers: {
          'Authorization': '${user.value!.tokenType} ${user.value!.accessToken}',
          'Accept': 'application/json',
        },
      );
      print('Teacher response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['teacher'] != null) {
          teacher.value = Teacher.fromJson(data['teacher']);
          print('Teacher data loaded: ${teacher.value?.teacherName}');
        }
      } else {
        print('Failed to fetch teacher data: ${response.statusCode}');
        // Don't show error for teacher data as it might not exist for all users
      }
    } catch (e) {
      print('Error fetching teacher data: $e');
      // Don't show error snackbar for teacher data
    }
  }

  // Refresh profile data
  Future<void> refreshProfile() async {
    if (isAuthenticated) {
      isLoading.value = true;
      await fetchProfileData();
      isLoading.value = false;
    }
  }

  // Save user data to SharedPreferences
  Future<void> saveUserToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (user.value != null) {
        await prefs.setString('user', json.encode(user.value!.toJson()));
      }
      if (teacher.value != null) {
        await prefs.setString('teacher', json.encode(teacher.value!.toJson()));
      }
      await prefs.setBool('isLoggedIn', isLoggedIn.value);
    } catch (e) {
      print('Error saving user to storage: $e');
    }
  }

  // Load user data from SharedPreferences
  Future<void> loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      final teacherJson = prefs.getString('teacher');
      final savedLoginStatus = prefs.getBool('isLoggedIn') ?? false;

      if (userJson != null && savedLoginStatus) {
        final userData = json.decode(userJson);
        user.value = User.fromJson(userData);
        
        if (teacherJson != null) {
          final teacherData = json.decode(teacherJson);
          teacher.value = Teacher.fromJson(teacherData);
        }
        
        isLoggedIn.value = true;
        print('User loaded from storage: ${user.value?.name} (${user.value?.role})');
      }
    } catch (e) {
      print('Error loading user from storage: $e');
    }
  }

  // Clear user data
  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      await prefs.remove('teacher');
      await prefs.setBool('isLoggedIn', false);
      
      user.value = null;
      teacher.value = null;
      isLoggedIn.value = false;
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Call logout API if needed
      if (user.value?.accessToken != null) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Authorization': '${user.value!.tokenType} ${user.value!.accessToken}',
            'Accept': 'application/json',
          },
        );
      }
    } catch (e) {
      print('Logout API error: $e');
    } finally {
      await clearUserData();
      Get.offAll(LoginScreen());
    }
  }

  // Get authorization headers for body-based auth
  Map<String, dynamic> get authBody {
    if (user.value?.accessToken != null) {
      return {
        'access_token': user.value!.accessToken,
      };
    }
    return {};
  }

  // Get authorization headers for header-based auth (for legacy endpoints)
  Map<String, String> get authHeaders {
    if (user.value?.accessToken != null) {
      return {
        'Authorization': '${user.value!.tokenType} ${user.value!.accessToken}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
    }
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  // Check if user is authenticated
  bool get isAuthenticated => isLoggedIn.value && user.value != null && user.value!.accessToken != null;

  // Get user role
  String get userRole => user.value?.role ?? '';

  // Check if user is leader
  bool get isLeader => userRole == 'leader';

  // Check if user is teacher
  bool get isTeacher => userRole == 'teacher';

  // Check if user is student
  bool get isStudent => userRole == 'student';

  // Get display name (prefer teacher name if available, otherwise user name)
  String get displayName {
    if (teacher.value?.teacherName.isNotEmpty == true) {
      return teacher.value!.teacherName;
    }
    return user.value?.name ?? '';
  }

  // Get teacher image URL
  String? get teacherImageUrl {
    if (teacher.value?.teacherImage != null) {
      return 'https://khayalstudio.com/siraj/public/${teacher.value!.teacherImage}';
    }
    return null;
  }

  // Generic API call method with body-based auth
  Future<http.Response?> apiCall({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    bool useHeaderAuth = false, // Flag to use header auth for legacy endpoints
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      Map<String, String> headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      
      Map<String, dynamic>? requestBody = body ?? {};

      // Add authentication
      if (useHeaderAuth) {
        // Use header-based auth for legacy endpoints
        if (user.value?.accessToken != null) {
          headers['Authorization'] = '${user.value!.tokenType} ${user.value!.accessToken}';
        }
      } else {
        // Use body-based auth for new endpoints
        if (user.value?.accessToken != null) {
          requestBody.addAll(authBody);
        }
      }

      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: json.encode(requestBody),
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: json.encode(requestBody),
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      // Handle token expiration
      if (response.statusCode == 401) {
        Get.snackbar(
          'انتهت صلاحية الجلسة',
          'يرجى تسجيل الدخول مرة أخرى',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        await logout();
        return null;
      }

      return response;
    } catch (e) {
      print('API call error: $e');
      Get.snackbar(
        'خطأ في الشبكة',
        'تحقق من الاتصال بالإنترنت وحاول مرة أخرى',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }
}