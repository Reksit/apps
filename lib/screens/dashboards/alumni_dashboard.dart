import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/dashboard_app_bar.dart';
import '../../widgets/dashboard_drawer.dart';
import '../../widgets/stats_card.dart';
import '../features/alumni_profile_screen.dart';
import '../features/alumni_directory_screen.dart';
import '../features/job_board_screen.dart';
import '../features/events_screen.dart';
import '../features/alumni_event_request_screen.dart';
import '../features/user_chat_screen.dart';
import '../features/password_change_screen.dart';

class AlumniDashboard extends StatefulWidget {
  const AlumniDashboard({super.key});

  @override
  State<AlumniDashboard> createState() => _AlumniDashboardState();
}

class _AlumniDashboardState extends State<AlumniDashboard> {
  int _selectedIndex = 0;

  final List<DashboardTab> _tabs = [
    DashboardTab(
      title: 'Profile',
      icon: Icons.person_outlined,
      selectedIcon: Icons.person,
      screen: const AlumniProfileScreen(),
    ),
    DashboardTab(
      title: 'Directory',
      icon: Icons.people_outlined,
      selectedIcon: Icons.people,
      screen: const AlumniDirectoryScreen(),
    ),
    DashboardTab(
      title: 'Jobs',
      icon: Icons.work_outlined,
      selectedIcon: Icons.work,
      screen: const JobBoardScreen(),
    ),
    DashboardTab(
      title: 'Events',
      icon: Icons.event_outlined,
      selectedIcon: Icons.event,
      screen: const EventsScreen(),
    ),
    DashboardTab(
      title: 'Request Event',
      icon: Icons.add_circle_outlined,
      selectedIcon: Icons.add_circle,
      screen: const AlumniEventRequestScreen(),
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
        title: 'Alumni Dashboard',
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
                  colors: [AppTheme.secondaryColor, AppTheme.secondaryLightColor],
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
                          'Welcome back, Alumni!',
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
                    'Connect with current students and fellow alumni. Share your experience, find opportunities, and give back to the community.',
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
                      title: 'Network',
                      value: '25',
                      subtitle: 'Connections',
                      icon: Icons.people,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Mentoring',
                      value: '8',
                      subtitle: 'Students Helped',
                      icon: Icons.school,
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
                      title: 'Opportunities',
                      value: '3',
                      subtitle: 'Jobs Posted',
                      icon: Icons.work,
                      color: AppTheme.accentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Events',
                      value: '2',
                      subtitle: 'Organized',
                      icon: Icons.event,
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
        selectedItemColor: AppTheme.secondaryColor,
        unselectedItemColor: AppTheme.textTertiaryColor,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: _tabs.map((tab) => BottomNavigationBarItem(
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