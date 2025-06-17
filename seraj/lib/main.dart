import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seraj/controllers/auth_controller.dart';
import 'package:seraj/screens/login_screen.dart';
import 'package:seraj/screens/main_screen.dart';

void main() {
  Get.put(AuthController());
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
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // Start animation
    _animationController.forward();

    // Check login status
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    // Wait for splash screen effect
    await Future.delayed(const Duration(seconds: 3));

    // Check if user is logged in and token is valid
    final isValid = await authController.checkTokenValidity();

    if (isValid) {
      // User is logged in with valid token, go to main screen
      Get.offAll(() => const MainScreen());
    } else {
      print(isValid);
      // User is not logged in or token is invalid, go to login screen
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo - Replace with your logo
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _buildLogo(),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // App Name
                    const Text(
                      'SERAJ',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // School Name
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Text(
                        'مدرسة نور الهدى الابتدائية الاهلية',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Loading Indicator
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Loading Text
                    const Text(
                      'جاري التحقق من حالة تسجيل الدخول...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget _buildLogo() {
  //   // Option 1: Use Image.asset for local logo
  //   // Make sure to add your logo file to assets folder and declare it in pubspec.yaml

  //   return Image.asset(
  //     'assets/images/logo.png', // Replace with your logo path
  //     width: 150,
  //     height: 150,
  //     fit: BoxFit.cover,

  //   );

  //   // Option 2: Use Image.network for online logo
  //   /*
  //   return Image.network(
  //     'https://your-website.com/logo.png', // Replace with your logo URL
  //     width: 150,
  //     height: 150,
  //     fit: BoxFit.cover,
  //     loadingBuilder: (context, child, loadingProgress) {
  //       if (loadingProgress == null) return child;
  //       return const Center(
  //         child: CircularProgressIndicator(
  //           color: Color(0xFF87CEEB),
  //           strokeWidth: 2,
  //         ),
  //       );
  //     },
  //     errorBuilder: (context, error, stackTrace) {
  //       return const Icon(
  //         Icons.school,
  //         color: Color(0xFF87CEEB),
  //         size: 80,
  //       );
  //     },
  //   );
  //   */

  //   // Option 3: Default icon (current implementation)
  //   return Container(
  //     width: 150,
  //     height: 150,
  //     color: Colors.white,
  //     child: const Icon(
  //       Icons.school,
  //       color: Color(0xFF87CEEB),
  //       size: 80,
  //     ),
  //   );
  // }
  Widget _buildLogo() {
    // Option 1: Logo with alpha/transparency, no circle
    return Opacity(
      opacity:
          1, // Adjust transparency (0.0 = fully transparent, 1.0 = fully opaque)
      child: Image.asset(
        'assets/images/logo.png', // Replace with your logo path
        width: 150,
        height: 150,
        fit: BoxFit.contain, // Maintains aspect ratio
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.school,
            color: Colors.white,
            size: 80,
          );
        },
      ),
    );
  }
}
