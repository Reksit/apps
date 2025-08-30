import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/dashboard_app_bar.dart';
import '../../widgets/dashboard_drawer.dart';
import '../../widgets/stats_card.dart';
import '../features/ai_assessment_screen.dart';
import '../features/class_assessments_screen.dart';
import '../features/task_management_screen.dart';
import '../features/events_screen.dart';
import '../features/job_board_screen.dart';
import '../features/alumni_directory_screen.dart';
import '../features/ai_chat_screen.dart';
import '../features/user_chat_screen.dart';
import '../features/resume_manager_screen.dart';
import '../features/student_profile_screen.dart';
import '../features/password_change_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<DashboardTab> _tabs = [
    DashboardTab(
      title: 'Profile',
      icon: Icons.person_outlined,
      selectedIcon: Icons.person,
    ),
    DashboardTab(
      title: 'Resume',
      icon: Icons.description_outlined,
      selectedIcon: Icons.description,
    ),
    DashboardTab(
      title: 'AI Practice',
      icon: Icons.psychology_outlined,
      selectedIcon: Icons.psychology,
    ),
    DashboardTab(
      title: 'Assessments',
      icon: Icons.quiz_outlined,
      selectedIcon: Icons.quiz,
    ),
    DashboardTab(
      title: 'Tasks',
      icon: Icons.task_outlined,
      selectedIcon: Icons.task,
    ),
    DashboardTab(
      title: 'Events',
      icon: Icons.event_outlined,
      selectedIcon: Icons.event,
    ),
    DashboardTab(
      title: 'Jobs',
      icon: Icons.work_outlined,
      selectedIcon: Icons.work,
    ),
    DashboardTab(
      title: 'Alumni',
      icon: Icons.school_outlined,
      selectedIcon: Icons.school,
    ),
    DashboardTab(
      title: 'AI Chat',
      icon: Icons.smart_toy_outlined,
      selectedIcon: Icons.smart_toy,
    ),
    DashboardTab(
      title: 'Messages',
      icon: Icons.chat_outlined,
      selectedIcon: Icons.chat,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    
    return Scaffold(
      appBar: DashboardAppBar(
        title: 'Student Dashboard',
        user: user,
      ),
      drawer: DashboardDrawer(
        user: user,
        onPasswordChange: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PasswordChangeScreen()),
          );
        },
      ),
      body: Column(
        children: [
          // Welcome Section
          if (_selectedIndex == 0) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryLightColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.school, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Welcome back, ${user?.name ?? 'Student'}!',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ready to enhance your learning with AI-powered assessments, connect with alumni, and achieve your career goals.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            // Quick Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'AI Assessments',
                      value: '12',
                      subtitle: 'Completed',
                      icon: Icons.psychology,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Class Tests',
                      value: '8',
                      subtitle: 'This Semester',
                      icon: Icons.quiz,
                      color: AppTheme.successColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Active Tasks',
                      value: '5',
                      subtitle: 'In Progress',
                      icon: Icons.task,
                      color: AppTheme.accentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Alumni Network',
                      value: '150+',
                      subtitle: 'Available',
                      icon: Icons.people,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: [
                const StudentProfileScreen(),
                const ResumeManagerScreen(),
                const AIAssessmentScreen(),
                const ClassAssessmentsScreen(),
                const TaskManagementScreen(),
                const EventsScreen(),
                const JobBoardScreen(),
                const AlumniDirectoryScreen(),
                const AIChatScreen(),
                const UserChatScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textTertiaryColor,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: _tabs.take(5).map((tab) => BottomNavigationBarItem(
          icon: Icon(tab.icon),
          activeIcon: Icon(tab.selectedIcon),
          label: tab.title,
        )).toList(),
      ),
    );
  }
}

class DashboardTab {
  final String title;
  final IconData icon;
  final IconData selectedIcon;

  DashboardTab({
    required this.title,
    required this.icon,
    required this.selectedIcon,
  });
}