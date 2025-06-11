import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import 'send_scientific_notification_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    // Refresh profile data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userController.isAuthenticated) {
        userController.refreshProfile();
      }
    });
  }

  @override
  void dispose() {
    // Clean up any subscriptions or timers here if needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB), // Light blue background
      appBar: AppBar(
        title: const Text(
          'مدرسة نور الهدى الابتدائية الاهلية',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF87CEEB),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              userController.refreshProfile();
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Add menu functionality
            },
          ),
        ],
      ),
      body: Obx(() {
        final user = userController.user.value;
        final isLoading = userController.isLoading.value;

        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        return user == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'المستخدم غير مسجل الدخول',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Get.offAndToNamed('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF87CEEB),
                      ),
                      child: const Text('تسجيل الدخول'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                color: const Color(0xFF87CEEB),
                onRefresh: () async {
                  await userController.refreshProfile();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Profile Avatar
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D7A),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getRoleColor(user.role),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getRoleDisplayName(user.role),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Display Name
                      Text(
                        userController.displayName.isNotEmpty 
                            ? userController.displayName 
                            : 'المستخدم',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      
                      // Grid of Options
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.9,
                        children: [
                          // إرسال تبليغ علمي
                          _buildOptionCard(
                            icon: Icons.send,
                            title: 'إرسال تبليغ علمي',
                            color: const Color(0xFF4DD0E1),
                            onTap: () {
                              Get.to(() =>  SendScientificNotificationScreen(user: userController ));
                              
                            },
                          ),
                          // الاختبارات
                          _buildOptionCard(
                            icon: Icons.calculate,
                            title: 'الاختبارات',
                            color: const Color(0xFFFF6B6B),
                            onTap: () {
                              // Navigate to tests
                            },
                          ),
                          // إرسال تبليغ إداري
                          _buildOptionCard(
                            icon: Icons.campaign,
                            title: 'إرسال تبليغ إداري',
                            color: const Color(0xFF4FC3F7),
                            onTap: () {
                              // Navigate to administrative notification
                            },
                          ),
                          // الواجبات البيتية
                          _buildOptionCard(
                            icon: Icons.menu_book,
                            title: 'الواجبات البيتية',
                            color: const Color(0xFF90A4AE),
                            onTap: () {
                              // Navigate to homework
                            },
                          ),
                          // المراسلة
                          _buildOptionCard(
                            icon: Icons.chat_bubble,
                            title: 'المراسلة',
                            color: const Color(0xFFE57373),
                            badgeCount: 9,
                            onTap: () {
                              // Navigate to messages
                            },
                          ),
                          // التبليغات الإدارية المستلمة
                          _buildOptionCard(
                            icon: Icons.notifications,
                            title: 'التبليغات الإدارية المستلمة',
                            color: const Color(0xFF4DD0E1),
                            onTap: () {
                              // Navigate to received notifications
                            },
                          ),
                          // الدروس الالكترونية
                          _buildOptionCard(
                            icon: Icons.computer,
                            title: 'الدروس الالكترونية',
                            color: const Color(0xFF81C784),
                            onTap: () {
                              // Navigate to e-lessons
                            },
                          ),
                          // الغيابات
                          _buildOptionCard(
                            icon: Icons.assignment,
                            title: 'الغيابات',
                            color: const Color(0xFFD4A574),
                            onTap: () {
                              // Navigate to absences
                            },
                          ),
                          // التبليغات الإدارية المرسلة
                          _buildOptionCard(
                            icon: Icons.description,
                            title: 'التبليغات الإدارية المرسلة',
                            color: const Color(0xFFFFD54F),
                            onTap: () {
                              // Navigate to sent administrative notifications
                            },
                          ),
                          // التبليغات العلمية المرسلة
                          _buildOptionCard(
                            icon: Icons.notifications_active,
                            title: 'التبليغات العلمية المرسلة',
                            color: const Color(0xFFFFB74D),
                            onTap: () {
                              // Navigate to sent scientific notifications
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      
                      // User Info Card
                      if (user.email.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'معلومات المستخدم',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D7A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.email, 
                                    size: 16, 
                                    color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      user.email,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.person, 
                                    size: 16, 
                                    color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    'ID: ${user.id}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      
                      // Logout Button
                      ElevatedButton.icon(
                        onPressed: () => _showLogoutConfirmation(context),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          'تسجيل الخروج',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
      }),
    );
  }

  // Get role color
  Color _getRoleColor(String role) {
    switch (role) {
      case 'leader':
        return const Color(0xFFFF5722);
      case 'teacher':
        return const Color(0xFF4CAF50);
      case 'student':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF607D8B);
    }
  }

  // Get role display name
  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'leader':
        return 'مدير المدرسة';
      case 'teacher':
        return 'معلم';
      case 'student':
        return 'طالب';
      default:
        return 'مستخدم';
    }
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required Color color,
    Color iconColor = Colors.white,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 28,
                    ),
                  ),
                  if (badgeCount != null)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : badgeCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
              userController.logout();
            },
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}