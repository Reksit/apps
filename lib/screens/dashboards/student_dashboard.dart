import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/dashboard_drawer.dart';
import '../../widgets/feature_tile.dart';
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
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showWelcomeSection = true;
  
  void _navigateToFeature(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
  
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
        _navigateToFeature(const StudentProfileScreen());
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
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Welcome Section - with collapsing animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: _showWelcomeSection ? null : 0,
                child: SliverToBoxAdapter(
                  child: AnimatedOpacity(
                    opacity: _showWelcomeSection ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
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
                                onTap: () => _navigateToFeature(const StudentProfileScreen()),
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
                ),
              ),
              
              // Features Grid
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Features',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                        children: [
                          FeatureTile(
                            title: 'My Profile',
                            subtitle: 'Manage your profile',
                            icon: Icons.person,
                            color: AppTheme.primaryColor,
                            onTap: () => _navigateToFeature(const StudentProfileScreen()),
                          ),
                          FeatureTile(
                            title: 'Resume Manager',
                            subtitle: 'Upload & manage resumes',
                            icon: Icons.description,
                            color: AppTheme.accentColor,
                            onTap: () => _navigateToFeature(const ResumeManagerScreen()),
                          ),
                          FeatureTile(
                            title: 'AI Practice',
                            subtitle: 'AI-powered assessments',
                            icon: Icons.psychology,
                            color: AppTheme.primaryColor,
                            onTap: () => _navigateToFeature(const AIAssessmentScreen()),
                          ),
                          FeatureTile(
                            title: 'Class Tests',
                            subtitle: 'Professor assessments',
                            icon: Icons.quiz,
                            color: AppTheme.successColor,
                            onTap: () => _navigateToFeature(const ClassAssessmentsScreen()),
                          ),
                          FeatureTile(
                            title: 'Task Manager',
                            subtitle: 'AI roadmaps & goals',
                            icon: Icons.task,
                            color: AppTheme.warningColor,
                            onTap: () => _navigateToFeature(const TaskManagementScreen()),
                          ),
                          FeatureTile(
                            title: 'Events',
                            subtitle: 'Campus events',
                            icon: Icons.event,
                            color: AppTheme.secondaryColor,
                            onTap: () => _navigateToFeature(const EventsScreen()),
                          ),
                          FeatureTile(
                            title: 'Job Board',
                            subtitle: 'Career opportunities',
                            icon: Icons.work,
                            color: AppTheme.accentColor,
                            onTap: () => _navigateToFeature(const JobBoardScreen()),
                          ),
                          FeatureTile(
                            title: 'Alumni Network',
                            subtitle: 'Connect with alumni',
                            icon: Icons.school,
                            color: AppTheme.secondaryColor,
                            onTap: () => _navigateToFeature(const AlumniDirectoryScreen()),
                          ),
                          FeatureTile(
                            title: 'AI Assistant',
                            subtitle: 'Chat with AI',
                            icon: Icons.smart_toy,
                            color: AppTheme.primaryColor,
                            onTap: () => _navigateToFeature(const AIChatScreen()),
                          ),
                          FeatureTile(
                            title: 'Messages',
                            subtitle: 'Chat with peers',
                            icon: Icons.chat,
                            color: AppTheme.successColor,
                            onTap: () => _navigateToFeature(const UserChatScreen()),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}