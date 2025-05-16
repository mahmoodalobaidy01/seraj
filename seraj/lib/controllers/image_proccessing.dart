// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import '../controllers/login_controller.dart';

// class QRImageProcessingScreen extends StatefulWidget {
//   final String imagePath;

//   const QRImageProcessingScreen({Key? key, required this.imagePath})
//       : super(key: key);

//   @override
//   State<QRImageProcessingScreen> createState() =>
//       _QRImageProcessingScreenState();
// }

// class _QRImageProcessingScreenState extends State<QRImageProcessingScreen> {
//   final loginController = Get.put(LoginController());
//   bool isProcessing = true;
//   String status = "Processing QR code...";
//   String debugLog = "";

//   @override
//   void initState() {
//     super.initState();
//     _processQRCode();
//   }

//   Future<void> _processQRCode() async {
//     try {
//       _log("Starting QR processing");

//       // Check if file exists
//       final File file = File(widget.imagePath);
//       if (!await file.exists()) {
//         _updateStatus("Error: Image file not found", isError: true);
//         return;
//       }

//       final fileSize = await file.length();
//       _log("File size: $fileSize bytes");

//       // Try scanning with mobile_scanner
//       _updateStatus("Scanning QR code...");
//       await _scanWithMobileScanner(widget.imagePath);
//     } catch (e) {
//       _log("Error: $e");
//       _updateStatus("Error processing QR code", isError: true);
//     }
//   }

//   Future<void> _scanWithMobileScanner(String imagePath) async {
//     try {
//       _log("Using mobile_scanner to scan image");

//       // Create mobile scanner controller
//       final controller = MobileScannerController();

//       // Analyze the image file
//       final bool success = await controller.analyzeImage(imagePath);

//       if (success) {
//         // Get the barcodes from the controller
//         final List<Barcode> barcodes = controller.barcodes as List<Barcode>;

//         if (barcodes.isNotEmpty) {
//           // Extract the QR code content
//           final String? qrContent = barcodes.first.rawValue;

//           if (qrContent != null && qrContent.isNotEmpty) {
//             _log("QR code detected successfully!");
//             await _processQRContent(qrContent);
//             return;
//           }
//         }
//       }

//       // If no QR code detected
//       _updateStatus("No QR code detected in the image", isError: true);
//     } catch (e) {
//       _log("Mobile scanner error: $e");
//       _updateStatus("QR scanning failed", isError: true);
//     }
//   }

//   // Process the QR content once detected
//   Future<void> _processQRContent(String qrContent) async {
//     _updateStatus("QR code detected! Logging in...");

//     // Mask content for privacy in logs
//     String maskedContent = qrContent;
//     if (qrContent.length > 20) {
//       maskedContent =
//           '${qrContent.substring(0, 10)}...${qrContent.substring(qrContent.length - 10)}';
//     }
//     _log("QR Content (masked): $maskedContent");

//     try {
//       await loginController.loginWithQR(qrContent);
//       _updateStatus("Login successful!", isSuccess: true);
//     } catch (e) {
//       _log("Login error: $e");
//       _updateStatus("Login failed: $e", isError: true);
//     }
//   }

//   // Update status with optional error handling
//   void _updateStatus(String message,
//       {bool isError = false, bool isSuccess = false}) {
//     setState(() {
//       status = message;
//       isProcessing = !(isError || isSuccess);
//     });

//     if (isError) {
//       Get.snackbar(
//         'Error',
//         message,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 5),
//       );
//     } else if (isSuccess) {
//       Get.snackbar(
//         'Success',
//         message,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//     }

//     _log(message);
//   }

//   // Add to debug log
//   void _log(String message) {
//     print("QR Debug: $message");
//     setState(() {
//       debugLog += "\n$message";
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blue.shade800,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               if (isProcessing)
//                 const CircularProgressIndicator(color: Colors.white),
//               const SizedBox(height: 24),
//               Text(
//                 status,
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 32),
//               if (!isProcessing)
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () => Get.back(),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         foregroundColor: Colors.blue.shade800,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 24, vertical: 12),
//                       ),
//                       child: const Text('Back', style: TextStyle(fontSize: 16)),
//                     ),
//                     const SizedBox(width: 16),
//                     ElevatedButton(
//                       onPressed: _processQRCode,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 24, vertical: 12),
//                       ),
//                       child: const Text('Try Again',
//                           style: TextStyle(fontSize: 16)),
//                     ),
//                   ],
//                 ),
//               const SizedBox(height: 24),
//               Expanded(
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.black54,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: SingleChildScrollView(
//                     child: Text(
//                       "Debug Log:$debugLog",
//                       style: const TextStyle(
//                           color: Colors.white70,
//                           fontSize: 12,
//                           fontFamily: "monospace"),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
