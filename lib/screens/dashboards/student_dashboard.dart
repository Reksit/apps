import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/dashboard_app_bar.dart';
import '../../widgets/dashboard_drawer.dart';
import '../../widgets/feature_tile.dart';
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
  void _navigateToFeature(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
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
            const SizedBox(height: 24),
            
            // Features Grid
            Text(
              'Features',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
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
    );
  }
}