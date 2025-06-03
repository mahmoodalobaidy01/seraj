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
  final int? variableId; // 👈 New field

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
    this.variableId, // 👈 Include in constructor
  });

  factory User.fromQRResponse(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: '',
      email: '',
      role: json['role'] ?? '',
      accessToken: json['access_token'],
      tokenType: json['token_type'] ?? 'Bearer',
      variableId: json['variable_id']?? null, // 👈 Add here
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
      variableId: json['variable_id']?? null, // 👈 Add here
    );
  }

  factory User.fromProfileResponse(Map<String, dynamic> json, String? accessToken, String? tokenType , int? variable_id) {
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
      variableId:variable_id??null, // 👈 Add here
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
      'variable_id': variableId, // 👈 Add here
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
    int? variableId, // 👈 Add here
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
      variableId: variableId ?? this.variableId, // 👈 Add here
    );
  }
}


class UserController extends GetxController {
  static const String baseUrl = 'https://khayalstudio.com/siraj/api';
  
  // Observable variables
  var user = Rxn<User>();
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

  // Fetch profile data from /profile endpoint using GET method with token in header
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
        if (data['user'] != null && data['user'].isNotEmpty) {
          final userData = data['user']; // Get first user from array
          final teacher_id = data['teacher_id'];
          print(teacher_id);
          
          // Update user with complete profile data while preserving token info
          user.value = User.fromProfileResponse(
            userData,
            user.value!.accessToken,
            user.value!.tokenType,
            teacher_id
          );
          
          print('Profile data loaded for user: ${user.value?.name} (Role: ${user.value?.role}) ID: ${user.value?.variableId}');
          
        } else {
          print('No user data found in profile response');
          print(data['teacher_id']);

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
      final savedLoginStatus = prefs.getBool('isLoggedIn') ?? false;

      if (userJson != null && savedLoginStatus) {
        final userData = json.decode(userJson);
        user.value = User.fromJson(userData);
        
        isLoggedIn.value = true;
        print('User loaded from storage: ${user.value?.name} (${user.value?.role}) ID: ${user.value?.variableId}');
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
      await prefs.setBool('isLoggedIn', false);
      
      user.value = null;
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
            'Authorization': 'Bearer ${user.value!.accessToken}',
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

  // Get authorization headers for header-based auth
  Map<String, String> get authHeaders {
    if (user.value?.accessToken != null) {
      return {
        'Authorization': 'Bearer ${user.value!.accessToken}',
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

  // Get display name
  String get displayName => user.value?.name ?? '';

  // Get user ID
  int get userId => user.value?.id ?? 0;

  // Generic API call method with header-based auth
  Future<http.Response?> apiCall({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      Map<String, String> headers = authHeaders;

      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
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