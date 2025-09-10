import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/dashboard_drawer.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/notification_bell.dart';
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

class _StudentDashboardState extends State<StudentDashboard> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showWelcomeSection = true;

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
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _scrollController.addListener(_onScroll);
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    final scrollPosition = _scrollController.offset;
    const threshold = 100.0;
    
    if (scrollPosition > threshold && _showWelcomeSection) {
      setState(() {
        _showWelcomeSection = false;
      });
    } else if (scrollPosition <= threshold && !_showWelcomeSection) {
      setState(() {
        _showWelcomeSection = true;
      });
    }
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
  
  void _showProfileMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          value: 'profile',
          child: ListTile(
            leading: const Icon(Icons.person, size: 20),
            title: const Text('Profile'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        PopupMenuItem(
          value: 'security',
          child: ListTile(
            leading: const Icon(Icons.security, size: 20),
            title: const Text('Security'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        PopupMenuItem(
          value: 'signout',
          child: ListTile(
            leading: const Icon(Icons.logout, size: 20),
            title: const Text('Sign Out'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
      ],
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ).then((value) {
      if (value != null) {
        _handleMenuAction(value);
      }
    });
  }
  
  void _handleMenuAction(String action) {
    switch (action) {
      case 'profile':
        _onTabSelected(0); // Navigate to profile tab
        break;
      case 'security':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PasswordChangeScreen()),
        );
        break;
      case 'signout':
        context.read<AuthProvider>().signOut();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.textPrimaryColor,
        elevation: 0,
        leading: null,
        automaticallyImplyLeading: false,
        actions: [
          // Notifications moved to far left as requested
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: NotificationBell(),
          ),
          const Spacer(),
          
          // Profile Avatar with popup menu
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => _showProfileMenu(context),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primaryColor,
                  backgroundImage: user?.profilePicture != null 
                      ? NetworkImage(user!.profilePicture!)
                      : null,
                  child: user?.profilePicture == null 
                      ? Text(
                          user?.name.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
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
          // Welcome Section and Navigation Tabs - with collapsing behavior
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _showWelcomeSection ? null : 0,
            child: Column(
              children: [
                // Welcome Section
                AnimatedOpacity(
                  opacity: _showWelcomeSection ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
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
                            GestureDetector(
                              onTap: () => _onTabSelected(0), // Navigate to profile tab
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                backgroundImage: user?.profilePicture != null 
                                    ? NetworkImage(user!.profilePicture!)
                                    : null,
                                child: user?.profilePicture == null 
                                    ? const Icon(Icons.school, color: Colors.white, size: 24)
                                    : null,
                              ),
                            ),
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
                ),
                
                // Quick Stats (only show on profile tab)
                if (_selectedIndex == 0) ...[
                  AnimatedOpacity(
                    opacity: _showWelcomeSection ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      children: [
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
                    ),
                  ),
                ],
                
                // Navigation Tabs - collapsible
                AnimatedOpacity(
                  opacity: _showWelcomeSection ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _tabs.take(5).asMap().entries.map((entry) {
                          final index = entry.key;
                          final tab = entry.value;
                          final isSelected = index == _selectedIndex;
                          
                          return GestureDetector(
                            onTap: () => _onTabSelected(index),
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSelected ? tab.selectedIcon : tab.icon,
                                    size: 18,
                                    color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    tab.title,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
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
        currentIndex: _selectedIndex < 5 ? _selectedIndex : 0,
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