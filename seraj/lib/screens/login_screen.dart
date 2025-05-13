import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/app_controller.dart';
import '../controllers/image_proccessing.dart';
import 'qr_scan_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppController());

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade800, Colors.blue.shade500],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Obx(
              () => controller.isLoading.value
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 20),
                        Text(
                          'Logging in...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        )
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 100,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'SERAJ',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Scan QR code to login',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 50),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue.shade800,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text(
                            'Scan QR Code Now',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () =>
                              Get.to(() => const QRScannerScreen()),
                        ),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          icon: const Icon(Icons.image, color: Colors.white70),
                          label: const Text(
                            'Upload Image with QR Code',
                            style: TextStyle(color: Colors.white70),
                          ),
                          onPressed: () => _uploadQRCodeImage(controller),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _uploadQRCodeImage(AppController controller) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        Get.to(() => QRImageProcessingScreen(imagePath: pickedFile.path));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
