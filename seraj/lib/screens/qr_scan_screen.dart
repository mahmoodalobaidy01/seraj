import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:seraj/controllers/login_controller.dart';

import '../controllers/app_controller.dart';
import 'main_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with WidgetsBindingObserver {
  MobileScannerController controller = MobileScannerController();
  LoginController loginController = LoginController();
  bool isProcessing = false;
  bool hasPermission = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes (pause/resume) for camera
    if (state == AppLifecycleState.resumed) {
      controller.start();
    } else if (state == AppLifecycleState.inactive) {
      controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.white);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            errorBuilder: (context, error, child) {
              return Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error,
                        color: Colors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Camera Error: ${error.errorCode}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              );
            },
            onDetect: (capture) async {
              if (isProcessing) return;

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                isProcessing = true;

                // Add haptic feedback or sound if needed
                // HapticFeedback.mediumImpact();

                final qrCode = barcodes.first.rawValue!;
                final appController = Get.find<AppController>();
                final success = await loginController.loginWithQR(qrCode);
                print("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");

                print(success);

                if (success) {
                  print("ssssssssssssssssssssssssssssssss");

                  print(qrCode);
                  Get.offAll(() => const MainScreen());
                } else {
                  isProcessing = false;
                  Get.snackbar(
                    'Invalid QR Code',
                    'Please try again',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                    margin: const EdgeInsets.only(
                        bottom: 20.0, left: 20.0, right: 20.0),
                  );
                }
              }
            },
          ),
          Container(
              // decoration: ShaderMask(
              //   shaderCallback: (Rect bounds) {
              //     return LinearGradient(
              //       begin: Alignment.topCenter,
              //       end: Alignment.bottomCenter,
              //       colors: [
              //         Colors.black.withOpacity(0.6),
              //         Colors.transparent,
              //         Colors.transparent,
              //         Colors.black.withOpacity(0.6),
              //       ],
              //       stops: const [0.0, 0.2, 0.8, 1.0],
              //     ).createShader(bounds);
              //   },
              //   blendMode: BlendMode.srcOver,
              //   child: Container(
              //     color: Colors.transparent,
              //   ),
              // ),
              ),
          // Scanner overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Guidance text
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Position the QR code within the frame',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
