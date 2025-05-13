import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/login_screen.dart';

class AppController extends GetxController {
  var isLoading = false.obs;
  var user = Rxn<User>();

  get http => null;

  // Mock login for testing when API isn't available
  Future<bool> login(String qrCode) async {
    try {
      isLoading.value = true;

      // For testing: Check if QR code starts with "SERAJ:"
      if (qrCode.startsWith("SERAJ:")) {
        // Extract user info from QR code
        final userData = qrCode.substring(6);
        final parts = userData.split('|');

        if (parts.length >= 3) {
          // Create a user from the QR data
          user.value = User(
            id: parts[0],
            name: parts[1],
            email: parts[2],
          );
          return true;
        }

        // If no mock data is detected, try real API
        final response = await http
            .post(
          Uri.parse('https://api.example.com/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'qrCode': qrCode}),
        )
            .timeout(const Duration(seconds: 5), onTimeout: () {
          throw TimeoutException('Connection timeout. Please try again.');
        });

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          user.value = User.fromJson(data['user']);
          return true;
        } else {
          Get.snackbar(
            'Login Failed',
            'Invalid QR code or server error',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return false;
        }
      }

      // For demo purposes: Always allow login with any QR code
      user.value = User(
        id: '123',
        name: 'Demo User',
        email: 'demo@example.com',
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Connection error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    user.value = null;
    Get.offAll(() => const LoginScreen());
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}

class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
