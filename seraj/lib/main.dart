import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Seraj',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppController extends GetxController {
  var isLoading = false.obs;
  var user = Rxn<User>();
  
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
        final response = await http.post(
          Uri.parse('https://api.example.com/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'qrCode': qrCode}),
        ).timeout(const Duration(seconds: 5), onTimeout: () {
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
            child: Obx(() => controller.isLoading.value
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
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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
                      onPressed: () => Get.to(() => const QRScannerScreen()),
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

class QRImageProcessingScreen extends StatefulWidget {
  final String imagePath;
  
  const QRImageProcessingScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<QRImageProcessingScreen> createState() => _QRImageProcessingScreenState();
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
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> with WidgetsBindingObserver {
  MobileScannerController controller = MobileScannerController();
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
                final success = await appController.login(qrCode);
                
                if (success) {
                  Get.offAll(() => const MainScreen());
                } else {
                  isProcessing = false;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid QR code, please try again'),
                      backgroundColor: Colors.red,
                    ),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seraj'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmation(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        final user = controller.user.value;
        
        return user == null 
            ? const Center(child: Text('User not logged in'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 45,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Text(
                        'Welcome, ${user.name}!',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.dashboard, color: Colors.blue),
                            title: Text('Dashboard'),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          ),
                          Divider(height: 1),
                          ListTile(
                            leading: Icon(Icons.history, color: Colors.orange),
                            title: Text('Recent Activity'),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          ),
                          Divider(height: 1),
                          ListTile(
                            leading: Icon(Icons.settings, color: Colors.grey),
                            title: Text('Settings'),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quick Actions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildQuickAction(Icons.description, 'Reports'),
                                _buildQuickAction(Icons.people, 'Users'),
                                _buildQuickAction(Icons.notifications, 'Alerts'),
                                _buildQuickAction(Icons.help, 'Help'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
      }),
    );
  }
  
  Widget _buildQuickAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon, 
            color: Colors.blue.shade700,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
  
  void _showLogoutConfirmation(BuildContext context, AppController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
              controller.logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}