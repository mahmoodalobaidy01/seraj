import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seraj/controllers/auth_controller.dart';
import 'package:seraj/screens/exam_screen.dart';
import 'package:seraj/screens/homework_screen.dart';
import 'send_scientific_notification_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Refresh profile data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authController.isAuthenticated) {
        authController.refreshProfile();
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
              authController.refreshProfile();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Obx(() {
        final user = authController.user.value;
        final isLoading = authController.isLoading.value;

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
                  await authController.refreshProfile();
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
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
                        authController.displayName.isNotEmpty
                            ? authController.displayName
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
                              Get.to(() => SendScientificNotificationScreen(
                                  user: authController));
                            },
                          ),
                          // الاختبارات
                          _buildOptionCard(
                            icon: Icons.calculate,
                            title: 'الاختبارات',
                            color: const Color(0xFFFF6B6B),
                            onTap: () {
                              // Navigate to homework screen with teacher ID
                              if (authController.teacherId != null) {
                                Get.to(() => ExamScreen(
                                    teacherId: authController.teacherId!));
                              } else {
                                Get.snackbar(
                                  'خطأ',
                                  'معرف المعلم غير متوفر',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
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
                              // Navigate to homework screen with teacher ID
                              if (authController.teacherId != null) {
                                Get.to(() => HomeworkScreen(
                                    teacherId: authController.teacherId!));
                              } else {
                                Get.snackbar(
                                  'خطأ',
                                  'معرف المعلم غير متوفر',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
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
                      // if (user.email.isNotEmpty)
                      //   Container(
                      //     width: double.infinity,
                      //     padding: const EdgeInsets.all(16),
                      //     margin: const EdgeInsets.only(bottom: 20),
                      //     decoration: BoxDecoration(
                      //       color: Colors.white.withOpacity(0.9),
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         const Text(
                      //           'معلومات المستخدم',
                      //           style: TextStyle(
                      //             fontSize: 16,
                      //             fontWeight: FontWeight.bold,
                      //             color: Color(0xFF2E7D7A),
                      //           ),
                      //         ),
                      //         const SizedBox(height: 8),
                      //         Row(
                      //           children: [
                      //             const Icon(Icons.email,
                      //                 size: 16, color: Colors.grey),
                      //             const SizedBox(width: 8),
                      //             Expanded(
                      //               child: Text(
                      //                 user.email,
                      //                 style: const TextStyle(
                      //                   fontSize: 14,
                      //                   color: Colors.grey,
                      //                 ),
                      //                 overflow: TextOverflow.ellipsis,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //         const SizedBox(height: 4),
                      //         Row(
                      //           children: [
                      //             const Icon(Icons.person,
                      //                 size: 16, color: Colors.grey),
                      //             const SizedBox(width: 8),
                      //             Text(
                      //               'ID: ${user.id}',
                      //               style: const TextStyle(
                      //                 fontSize: 14,
                      //                 color: Colors.grey,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ],
                      //     ),
                      //   ),

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

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Obx(() {
            final user = authController.user.value;
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  top: 50, bottom: 20, left: 16, right: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF87CEEB), Color(0xFF5DADE2)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  // Profile Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF87CEEB),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // User Name
                  Text(
                    user?.name ?? 'اسم المستخدم',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  // Role Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      _getRoleDisplayName(user?.role ?? ''),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.info_outline,
                  title: 'معلومات الاستاذ',
                  iconColor: Colors.grey,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to teacher info
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.quiz,
                  title: 'الاختبارات',
                  iconColor: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    if (authController.teacherId != null) {
                      Get.to(() =>
                          ExamScreen(teacherId: authController.teacherId!));
                    }
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.send,
                  title: 'إرسال تبليغ علمي',
                  iconColor: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() =>
                        SendScientificNotificationScreen(user: authController));
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.menu_book,
                  title: 'الواجبات البيتية',
                  iconColor: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    if (authController.teacherId != null) {
                      Get.to(() =>
                          HomeworkScreen(teacherId: authController.teacherId!));
                    }
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.campaign,
                  title: 'إرسال تبليغ إداري',
                  iconColor: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to administrative notification
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.notifications,
                  title: 'التبليغات الإدارية المستلمة',
                  iconColor: Colors.cyan,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to received notifications
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.chat_bubble,
                  title: 'المراسلة',
                  iconColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to messages
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.public,
                  title: 'الأخبار',
                  iconColor: Colors.teal,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to news
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.library_books,
                  title: 'المكتبة',
                  iconColor: Colors.brown,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to library
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.school,
                  title: 'الامتحانات و الدرجات',
                  iconColor: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to exams and grades
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.group,
                  title: 'طلابي',
                  iconColor: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to my students
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.event_available,
                  title: 'الغيابات',
                  iconColor: Colors.grey,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to absences
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.calendar_month,
                  title: 'الجدول الشهري',
                  iconColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to monthly schedule
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.computer,
                  title: 'الدروس الالكترونية',
                  iconColor: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to e-lessons
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.calendar_view_week,
                  title: 'الجدول الأسبوعي',
                  iconColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to weekly schedule
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.notifications_active,
                  title: 'التبليغات العلمية المرسلة',
                  iconColor: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to sent scientific notifications
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.description,
                  title: 'التبليغات الإدارية المرسلة',
                  iconColor: Colors.yellow.shade700,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to sent administrative notifications
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.support,
                  title: 'الدعم الفني',
                  iconColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to technical support
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.edit_note,
                  title: 'حكمة اليوم',
                  iconColor: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to daily wisdom
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'الإعدادات',
                  iconColor: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to settings
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.exit_to_app,
                  title: 'تسجيل الخروج',
                  iconColor: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutConfirmation(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.archive,
                  title: 'أرشيف السنوات',
                  iconColor: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to years archive
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.info,
                  title: 'عن التطبيق',
                  iconColor: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    // Show about dialog
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      dense: true,
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
        return 'مشرف الصف';
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
              authController.logout();
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
