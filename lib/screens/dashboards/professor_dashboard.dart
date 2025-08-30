import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/dashboard_app_bar.dart';
import '../../widgets/dashboard_drawer.dart';
import '../../widgets/feature_tile.dart';
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
                  color: AppTheme.successColor,
                  onTap: () => _navigateToFeature(const ProfessorProfileScreen()),
                ),
                FeatureTile(
                  title: 'My Assessments',
                  subtitle: 'View created tests',
                  icon: Icons.quiz,
                  color: AppTheme.primaryColor,
                  onTap: () => _navigateToFeature(const MyAssessmentsScreen()),
                ),
                FeatureTile(
                  title: 'Create Assessment',
                  subtitle: 'Design new tests',
                  icon: Icons.add_circle,
                  color: AppTheme.accentColor,
                  onTap: () => _navigateToFeature(const CreateAssessmentScreen()),
                ),
                FeatureTile(
                  title: 'Assessment Insights',
                  subtitle: 'Student analytics',
                  icon: Icons.analytics,
                  color: AppTheme.warningColor,
                  onTap: () => _navigateToFeature(const AssessmentInsightsScreen()),
                ),
                FeatureTile(
                  title: 'Events',
                  subtitle: 'Campus events',
                  icon: Icons.event,
                  color: AppTheme.secondaryColor,
                  onTap: () => _navigateToFeature(const EventsScreen()),
                ),
                FeatureTile(
                  title: 'Messages',
                  subtitle: 'Chat with students',
                  icon: Icons.chat,
                  color: AppTheme.primaryColor,
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