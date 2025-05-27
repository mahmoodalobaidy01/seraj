import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';

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
    // No need to fetch data here since UserController handles it
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
        final teacher = userController.teacher.value;
        final isLoading = userController.isLoading.value;

        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        return user == null
            ? const Center(
                child: Text(
                  'المستخدم غير مسجل الدخول',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : SingleChildScrollView(
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
                      child: userController.teacherImageUrl != null
                          ? ClipOval(
                              child: Image.network(
                                userController.teacherImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 60,
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 60,
                            ),
                    ),
                    const SizedBox(height: 20),
                    // Teacher Position
                    Text(
                      teacher?.teacherPosition ?? 'الاستاذة',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Teacher Name
                    Text(
                      teacher?.teacherName ?? user?.name ?? 'المستخدم',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Grid of Options
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.1,
                      children: [
                        _buildOptionCard(
                          icon: Icons.send,
                          title: 'إرسال تبليغ علمي',
                          color: const Color(0xFF4CAF50),
                          onTap: () {
                            // Navigate to scientific notification
                          },
                        ),
                        _buildOptionCard(
                          icon: Icons.calculate,
                          title: 'الاختبارات',
                          color: const Color(0xFFFF9800),
                          onTap: () {
                            // Navigate to tests
                          },
                        ),
                        _buildOptionCard(
                          icon: Icons.campaign,
                          title: 'إرسال تبليغ إداري',
                          color: const Color(0xFF2196F3),
                          onTap: () {
                            // Navigate to administrative notification
                          },
                        ),
                        _buildOptionCard(
                          icon: Icons.assignment,
                          title: 'الواجبات البيتية',
                          color: const Color(0xFF607D8B),
                          onTap: () {
                            // Navigate to homework
                          },
                        ),
                        _buildOptionCard(
                          icon: Icons.chat,
                          title: 'المراسلة',
                          color: const Color(0xFFE91E63),
                          badgeCount: 3,
                          onTap: () {
                            // Navigate to messages
                          },
                        ),
                        _buildOptionCard(
                          icon: Icons.notifications,
                          title: 'التبليغات الإدارية المستلمة',
                          color: const Color(0xFF00BCD4),
                          onTap: () {
                            // Navigate to received notifications
                          },
                        ),
                        _buildOptionCard(
                          icon: Icons.school,
                          title: 'الدروس الالكترونية',
                          color: const Color(0xFF9C27B0),
                          onTap: () {
                            // Navigate to e-lessons
                          },
                        ),
                        _buildOptionCard(
                          icon: Icons.event_note,
                          title: 'الغيابات',
                          color: const Color(0xFF795548),
                          onTap: () {
                            // Navigate to absences
                          },
                        ),
                        _buildOptionCard(
                          icon: Icons.description,
                          title: 'التبليغات الإدارية المرسلة',
                          color: const Color(0xFFFFEB3B),
                          iconColor: Colors.black87,
                          onTap: () {
                            // Navigate to sent administrative notifications
                          },
                        ),
                        _buildOptionCard(
                          icon: Icons.notifications_active,
                          title: 'التبليغات العلمية المرسلة',
                          color: const Color(0xFFFF5722),
                          onTap: () {
                            // Navigate to sent scientific notifications
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
              );
      }),
    );
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
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 32,
                  ),
                ),
                if (badgeCount != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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