import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/dashboard_app_bar.dart';
import '../../widgets/dashboard_drawer.dart';
import '../../widgets/stats_card.dart';
import '../features/professor_profile_screen.dart';
import '../features/create_assessment_screen.dart';
import '../features/my_assessments_screen.dart';
import '../features/assessment_insights_screen.dart';
import '../features/events_screen.dart';
import '../features/user_chat_screen.dart';
import '../features/password_change_screen.dart';

class ProfessorDashboard extends StatefulWidget {
  const ProfessorDashboard({super.key});

  @override
  State<ProfessorDashboard> createState() => _ProfessorDashboardState();
}

class _ProfessorDashboardState extends State<ProfessorDashboard> {
  int _selectedIndex = 0;

  final List<DashboardTab> _tabs = [
    DashboardTab(
      title: 'Profile',
      icon: Icons.person_outlined,
      selectedIcon: Icons.person,
      screen: const ProfessorProfileScreen(),
    ),
    DashboardTab(
      title: 'My Assessments',
      icon: Icons.quiz_outlined,
      selectedIcon: Icons.quiz,
      screen: const MyAssessmentsScreen(),
    ),
    DashboardTab(
      title: 'Create Assessment',
      icon: Icons.add_circle_outlined,
      selectedIcon: Icons.add_circle,
      screen: const CreateAssessmentScreen(),
    ),
    DashboardTab(
      title: 'Insights',
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
      screen: const AssessmentInsightsScreen(),
    ),
    DashboardTab(
      title: 'Events',
      icon: Icons.event_outlined,
      selectedIcon: Icons.event,
      screen: const EventsScreen(),
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
        title: 'Professor Dashboard',
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
                  colors: [AppTheme.successColor, Color(0xFF10B981)],
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
                          'Welcome back, Professor!',
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
                    'Create assessments, monitor student performance, and engage with your students.',
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
                      title: 'Assessments',
                      value: '15',
                      subtitle: 'Created',
                      icon: Icons.quiz,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Students',
                      value: '120',
                      subtitle: 'Enrolled',
                      icon: Icons.people,
                      color: AppTheme.successColor,
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
        selectedItemColor: AppTheme.successColor,
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