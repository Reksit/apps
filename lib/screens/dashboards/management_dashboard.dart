import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/dashboard_app_bar.dart';
import '../../widgets/dashboard_drawer.dart';
import '../../widgets/stats_card.dart';
import '../features/dashboard_stats_screen.dart';
import '../features/alumni_verification_screen.dart';
import '../features/event_management_screen.dart';
import '../features/student_heatmap_screen.dart';
import '../features/alumni_directory_screen.dart';
import '../features/job_board_screen.dart';
import '../features/user_chat_screen.dart';
import '../features/password_change_screen.dart';

class ManagementDashboard extends StatefulWidget {
  const ManagementDashboard({super.key});

  @override
  State<ManagementDashboard> createState() => _ManagementDashboardState();
}

class _ManagementDashboardState extends State<ManagementDashboard> {
  int _selectedIndex = 0;

  final List<DashboardTab> _tabs = [
    DashboardTab(
      title: 'Overview',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      screen: const DashboardStatsScreen(),
    ),
    DashboardTab(
      title: 'Alumni Verification',
      icon: Icons.verified_user_outlined,
      selectedIcon: Icons.verified_user,
      screen: const AlumniVerificationScreen(),
    ),
    DashboardTab(
      title: 'Event Management',
      icon: Icons.event_outlined,
      selectedIcon: Icons.event,
      screen: const EventManagementScreen(),
    ),
    DashboardTab(
      title: 'Student Activity',
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
      screen: const StudentHeatmapScreen(),
    ),
    DashboardTab(
      title: 'Alumni Network',
      icon: Icons.people_outlined,
      selectedIcon: Icons.people,
      screen: const AlumniDirectoryScreen(),
    ),
    DashboardTab(
      title: 'Job Portal',
      icon: Icons.work_outlined,
      selectedIcon: Icons.work,
      screen: const JobBoardScreen(),
    ),
    DashboardTab(
      title: 'Messages',
      icon: Icons.chat_outlined,
      selectedIcon: Icons.chat,
      screen: const UserChatScreen(),
    ),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    
    return Scaffold(
      appBar: DashboardAppBar(
        title: 'Management Dashboard',
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
                  colors: [AppTheme.accentColor, Color(0xFF8B5CF6)],
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
                      const Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Management Portal',
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
                    'Monitor student performance, verify alumni, and oversee the entire assessment system.',
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
                      title: 'Students',
                      value: '1,250',
                      subtitle: 'Enrolled',
                      icon: Icons.people,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Alumni',
                      value: '45',
                      subtitle: 'Pending Approval',
                      icon: Icons.verified_user,
                      color: AppTheme.warningColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Tab Content
          Expanded(
            child: _tabs[_selectedIndex].screen,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.accentColor,
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
  final Widget screen;

  DashboardTab({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.screen,
  });
}