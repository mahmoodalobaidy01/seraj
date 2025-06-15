import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seraj/screens/login_screen.dart';

class AuthUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final String accessToken;
  final String tokenType;
  final int? variableId;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;

  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.accessToken,
    required this.tokenType,
    this.variableId,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory AuthUser.fromQRResponse(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] ?? 0,
      name: '',
      email: '',
      role: json['role'] ?? '',
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      variableId: json['variable_id'],
    );
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      variableId: json['variable_id'],
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  factory AuthUser.fromProfileResponse(Map<String, dynamic> json, String accessToken, String tokenType, int? variableId) {
    return AuthUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      accessToken: accessToken,
      tokenType: tokenType,
      variableId: variableId,
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
      'variable_id': variableId,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class AuthController extends GetxController {
  static const String baseUrl = 'https://khayalstudio.com/siraj/api';
  
  // Observable variables
  var user = Rxn<AuthUser>();
  var isLoggedIn = false.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserFromStorage();
  }
  

  // Get authorization headers
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
  bool get isAuthenticated => isLoggedIn.value && user.value != null && user.value!.accessToken.isNotEmpty;

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

  // Get teacher/variable ID
  int? get teacherId => user.value?.variableId;

  // Set user from QR login response
  Future<void> setUserFromQRLogin(Map<String, dynamic> qrResponse) async {
    try {
      isLoading.value = true;
      
      // Create user from QR response with token info
      user.value = AuthUser.fromQRResponse(qrResponse);
      
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

  // Fetch profile data from /profile endpoint
  Future<void> fetchProfileData() async {
    try {
      if (user.value?.accessToken == null) return;
      
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: authHeaders,
      );

      print('Profile response: ${response.body}');
      print('Profile response: ${authHeaders}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['user'] != null && data['user'].isNotEmpty) {
          final userData = data['user'];
          final teacherId = data['teacher_id'];
          
          // Update user with complete profile data while preserving token info
          user.value = AuthUser.fromProfileResponse(
            userData,
            user.value!.accessToken,
            user.value!.tokenType,
            teacherId
          );
          
          print('Profile data loaded for user: ${user.value?.name} (Role: ${user.value?.role}) ID: ${user.value?.variableId}');
          
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
      } else if (response.statusCode == 401) {
        Get.snackbar(
          'انتهت صلاحية الجلسة',
          'يرجى تسجيل الدخول مرة أخرى',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        await logout();
      } else {
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
  // Add this method to your existing AuthController class

// Check if stored token is still valid
// Check if stored token is still valid
Future<bool> checkTokenValidity() async {
  try {
    // First check if we have a user stored locally
    if (!isAuthenticated) {
      print('No user authenticated locally');
      return false;
    }

    print('Checking token validity for user: ${user.value?.name}');
    print('User ID: ${user.value?.id}');
    
    // Make API call to check token validity with ID in body
    final response = await http.post(
      Uri.parse('$baseUrl/check'),
      headers: {
        'Authorization': '${user.value!.tokenType} ${user.value!.accessToken}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'id': user.value!.id,
      }),
    );

    print('Token check response status: ${response.statusCode}');
    print('Token check response body: ${response.body}');
    print('Token check headers sent: ${response.request?.headers}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Check if response indicates token is valid
      if (data.check == true || data['valid'] == true || data['status'] == true) {
        print('Token is valid');
        return true;
      } else {
        print('Token is invalid according to response: $data');
        await clearUserData();
        return false;
      }
    } else if (response.statusCode == 401) {
      print('Token expired or unauthorized');
      await clearUserData();
      return false;
    } else {
      print('Unexpected response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      // For other errors, assume token might still be valid but there's a network issue
      // You can change this behavior based on your needs
      return true;
    }
  } catch (e) {
    print('Error checking token validity: $e');
    // On network error, assume token is still valid if we have it stored
    // You can change this behavior based on your needs
    return isAuthenticated;
  }
}

// Enhanced loadUserFromStorage method with better error handling
@override
Future<void> loadUserFromStorage() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    final savedLoginStatus = prefs.getBool('isLoggedIn') ?? false;

    print('Loading user from storage...');
    print('Saved login status: $savedLoginStatus');
    print('User JSON exists: ${userJson != null}');

    if (userJson != null && savedLoginStatus) {
      final userData = json.decode(userJson);
      user.value = AuthUser.fromJson(userData);
      isLoggedIn.value = true;
      
      print('User loaded from storage: ${user.value?.name} (${user.value?.role}) ID: ${user.value?.variableId}');
      print('Access token exists: ${user.value?.accessToken?.isNotEmpty == true}');
    } else {
      print('No valid user data found in storage');
      user.value = null;
      isLoggedIn.value = false;
    }
  } catch (e) {
    print('Error loading user from storage: $e');
    // Clear corrupted data
    await clearUserData();
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
          headers: authHeaders,
        );
      }
    } catch (e) {
      print('Logout API error: $e');
    } finally {
      await clearUserData();
      Get.offAll(() => LoginScreen());
    }
  }

  // Generic API call method with authentication
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

  // Simplified API GET method
  Future<http.Response?> get(String endpoint) async {
    return await apiCall(endpoint: endpoint, method: 'GET');
  }

  // Simplified API POST method
  Future<http.Response?> post(String endpoint, {Map<String, dynamic>? body}) async {
    return await apiCall(endpoint: endpoint, method: 'POST', body: body);
  }

  // Simplified API PUT method
  Future<http.Response?> put(String endpoint, {Map<String, dynamic>? body}) async {
    return await apiCall(endpoint: endpoint, method: 'PUT', body: body);
  }

  // Simplified API DELETE method
  Future<http.Response?> delete(String endpoint) async {
    return await apiCall(endpoint: endpoint, method: 'DELETE');
  }
}