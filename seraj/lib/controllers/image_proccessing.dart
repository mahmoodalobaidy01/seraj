import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seraj/controllers/app_controller.dart';

import '../screens/main_screen.dart';

class QRImageProcessingScreen extends StatefulWidget {
  final String imagePath;

  const QRImageProcessingScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  State<QRImageProcessingScreen> createState() =>
      _QRImageProcessingScreenState();
}

class _QRImageProcessingScreenState extends State<QRImageProcessingScreen> {
  bool isProcessing = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    try {
      // Display image first and simulate processing for demo
      await Future.delayed(const Duration(seconds: 2));

      // Simulate finding a QR code for demo purposes
      final qrCode = "SERAJ:123|Demo User|demo@example.com";

      final appController = Get.find<AppController>();
      final success = await appController.login(qrCode);

      if (success) {
        Get.offAll(() => const MainScreen());
      } else {
        setState(() {
          isProcessing = false;
          hasError = true;
          errorMessage = 'Invalid QR code';
        });
      }
    } catch (e) {
      setState(() {
        isProcessing = false;
        hasError = true;
        errorMessage = 'Error processing image: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing QR Code'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(widget.imagePath),
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 30),
              if (isProcessing) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                const Text(
                  'Processing image...',
                  style: TextStyle(fontSize: 16),
                ),
              ] else if (hasError) ...[
                Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 20),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text('Go Back'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => _processImage(),
                  child: const Text('Try Again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
