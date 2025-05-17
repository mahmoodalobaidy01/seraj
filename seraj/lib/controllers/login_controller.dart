import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:seraj/screens/main_screen.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;

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
        print(response.body);
        Get.snackbar('Login Success', 'Welcome, test',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        Get.offAll(() => const MainScreen());

        return true;
        // Navigate or store token here
      } else {
        Get.snackbar('Login Failed', data['message'] ?? 'Unknown error',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Request failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
