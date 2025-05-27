// login_controller.dart (Updated)
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:seraj/screens/main_screen.dart';
import 'user_controller.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;
  final UserController userController = Get.put(UserController());

  Future<bool> loginWithQR(String cred) async {
    isLoading.value = true;

    final url = Uri.parse('https://khayalstudio.com/siraj/api/qr');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'credentials': cred}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['access_token'] != null) {
        print('QR Login Response: ${response.body}');
        
        // Set user data in UserController
        await userController.setUserFromQRLogin(data);
        
        Get.snackbar(
          'تم تسجيل الدخول بنجاح',
          'مرحباً ${userController.user.value?.name ?? 'بك'}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        // Navigate to main screen
        Get.offAll(() => const MainScreen());
        return true;
      } else {
        Get.snackbar(
          'فشل تسجيل الدخول',
          data['message'] ?? 'خطأ غير معروف',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في الطلب: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}